import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/models/completion_entry/completion_entry.dart';
import '/models/habit/habit_model.dart';
import '/models/sync_status.dart';
import '/models/revenue_cat_device_record/revenue_cat_device_record.dart';
import '/models/user_defaults/user_defaults.dart';

final syncServiceProvider = Provider<SyncService>((ref) => SyncService());

class SyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'habitformdatabase');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _habitsCollection => _firestore.collection('users').doc(_userId).collection('habits');

  bool _isProSubscriber() {
    final defaults = HiveHelper.shared.getData<UserDefaults>(HiveBoxes.userDefaultsBox, HiveKeys.userDefaultsKey);
    return defaults?.isPro ?? false;
  }

  Future<void> syncHabit(Habit habit) async {
    LogHelper.shared.debugPrint('🔄 SyncService.syncHabit called for ${habit.id}. Current userId: $_userId');
    if (_userId == null) {
      LogHelper.shared.debugPrint('⚠️ Sync skipped: _userId is null. User not logged in?');
      return;
    }

    if (!_isProSubscriber()) {
      LogHelper.shared.debugPrint('⚠️ Sync skipped: Cloud habit sync requires Pro.');
      return;
    }

    try {
      final habitData = habit.toJson();

      // Freezed generated toJson might not automatically serialize nested custom objects.
      // We manually ensure they are converted to Maps.
      if (habit.reminderModel != null) {
        habitData['reminderModel'] = habit.reminderModel!.toJson();
      }

      if (habit.completions.isNotEmpty) {
        habitData['completions'] = habit.completions.map((key, value) => MapEntry(key, value.toJson()));
      }

      // Ensure syncStatus is synced when uploading
      habitData['syncStatus'] = SyncStatus.synced.name;
      habitData['updatedAt'] = FieldValue.serverTimestamp();

      await _habitsCollection.doc(habit.id).set(habitData);
      LogHelper.shared.debugPrint('✅ Synced habit ${habit.id} to Firestore');
    } catch (e, stack) {
      LogHelper.shared.debugPrint('❌ Error syncing habit ${habit.id}: $e\n$stack');
      rethrow;
    }
  }

  /// Updates a single completion entry under [habitId] without rewriting the whole habit document.
  /// Uses [FieldPath] so map keys work even when they contain `.` (e.g. ISO date strings).
  ///
  /// When [removeCompletionKeyIfDifferent] is set and differs from [completionMapKey], the old
  /// map entry is deleted (e.g. legacy key migration).
  Future<void> patchHabitCompletion({
    required String habitId,
    required String completionMapKey,
    required CompletionEntry entry,
    String? removeCompletionKeyIfDifferent,
  }) async {
    LogHelper.shared.debugPrint('🔄 SyncService.patchHabitCompletion called for $habitId / $completionMapKey');
    if (_userId == null) {
      LogHelper.shared.debugPrint('⚠️ Patch skipped: _userId is null.');
      return;
    }

    if (!_isProSubscriber()) {
      LogHelper.shared.debugPrint('⚠️ Patch skipped: Cloud habit sync requires Pro.');
      return;
    }

    final docRef = _habitsCollection.doc(habitId);
    final entryMap = entry.toJson();
    entryMap['syncStatus'] = SyncStatus.synced.name;

    final pathNew = FieldPath(['completions', completionMapKey]);
    final updateData = <Object, Object?>{
      pathNew: entryMap,
      'updatedAt': FieldValue.serverTimestamp(),
      'syncStatus': SyncStatus.synced.name,
    };

    if (removeCompletionKeyIfDifferent != null && removeCompletionKeyIfDifferent != completionMapKey) {
      final pathOld = FieldPath(['completions', removeCompletionKeyIfDifferent]);
      updateData[pathOld] = FieldValue.delete();
    }

    try {
      await docRef.update(updateData);
      LogHelper.shared.debugPrint('✅ Patched completion $completionMapKey on habit $habitId');
    } on FirebaseException catch (e) {
      if (_isDocumentMissingException(e)) {
        await _patchHabitCompletionWhenDocMissing(
          docRef: docRef,
          completionMapKey: completionMapKey,
          entryMap: entryMap,
        );
        LogHelper.shared.debugPrint('✅ Created/merged habit $habitId document for completion patch');
      } else {
        LogHelper.shared.debugPrint('❌ Error patching completion on habit $habitId: $e');
        rethrow;
      }
    }
  }

  bool _isDocumentMissingException(FirebaseException e) {
    final code = e.code.toLowerCase();
    return code == 'not-found' || code.contains('not-found');
  }

  /// When the habit doc does not exist yet on the server, merge only the one completion key.
  Future<void> _patchHabitCompletionWhenDocMissing({
    required DocumentReference<Map<String, dynamic>> docRef,
    required String completionMapKey,
    required Map<String, dynamic> entryMap,
  }) async {
    await docRef.set(
      <String, dynamic>{
        'completions': <String, dynamic>{
          completionMapKey: entryMap,
        },
        'updatedAt': FieldValue.serverTimestamp(),
        'syncStatus': SyncStatus.synced.name,
      },
      SetOptions(merge: true),
    );
  }

  Future<List<Habit>> fetchRemoteHabits() async {
    if (_userId == null) return [];

    if (!_isProSubscriber()) {
      LogHelper.shared.debugPrint('⚠️ fetchRemoteHabits skipped: Cloud habit sync requires Pro.');
      return [];
    }

    try {
      final snapshot = await _habitsCollection.get();
      return snapshot.docs.map((doc) => Habit.fromJson(doc.data())).toList();
    } catch (e) {
      LogHelper.shared.debugPrint('❌ Error fetching remote habits: $e');
      return [];
    }
  }

  Future<void> deleteRemoteHabit(String habitId) async {
    if (_userId == null) return;

    if (!_isProSubscriber()) {
      LogHelper.shared.debugPrint('⚠️ deleteRemoteHabit skipped: Cloud habit sync requires Pro.');
      return;
    }

    try {
      await _habitsCollection.doc(habitId).delete();
      LogHelper.shared.debugPrint('✅ Deleted habit $habitId from Firestore');
    } catch (e) {
      LogHelper.shared.debugPrint('❌ Error deleting remote habit $habitId: $e');
    }
  }

  /// Conflict resolution: LWW for habit metadata, but merge completions from both
  /// so no completion is lost when syncing across devices.
  Habit resolveConflict(Habit local, Habit remote) {
    final mergedCompletions = _mergeCompletions(local.completions, remote.completions);
    final base = (local.updatedAt == null || (remote.updatedAt != null && !local.updatedAt!.isAfter(remote.updatedAt!))) ? remote : local;
    return base.copyWith(completions: mergedCompletions);
  }

  /// Merges two completion maps: for each date key, keep the entry with isCompleted true
  /// or higher count so we never lose completion data from either device.
  Map<String, CompletionEntry> _mergeCompletions(
    Map<String, CompletionEntry> local,
    Map<String, CompletionEntry> remote,
  ) {
    final result = Map<String, CompletionEntry>.from(local);
    for (final entry in remote.entries) {
      final existing = result[entry.key];
      if (existing == null) {
        result[entry.key] = entry.value;
      } else {
        if (entry.value.isCompleted && !existing.isCompleted) {
          result[entry.key] = entry.value;
        } else if (entry.value.count > existing.count) {
          result[entry.key] = entry.value;
        } else if (!entry.value.isCompleted && existing.isCompleted) {
          result[entry.key] = existing;
        } else {
          result[entry.key] = entry.value.count >= existing.count ? entry.value : existing;
        }
      }
    }
    return result;
  }

  /// Fetches the current user document from Firestore (for subscription fallback on login).
  Future<Map<String, dynamic>?> getUserSubscription() async {
    if (_userId == null) return null;
    try {
      final doc = await _firestore.collection('users').doc(_userId).get();
      return doc.data();
    } catch (e) {
      LogHelper.shared.debugPrint('❌ Error fetching user subscription: $e');
      return null;
    }
  }

  /// Merges one install's RevenueCat + device snapshot under `revenueCatDevices[installId]`.
  Future<void> mergeRevenueCatDeviceSnapshot({
    required String installId,
    required RevenueCatDeviceRecord record,
  }) async {
    if (_userId == null) return;
    try {
      final payload = <String, dynamic>{
        'currentAppUserId': record.currentAppUserId,
        'platform': record.platform,
        'deviceModel': record.deviceModel,
        'appVersion': record.appVersion,
        'lastSyncedAt': FieldValue.serverTimestamp(),
      };
      if (record.originalAppUserId != null) {
        payload['originalAppUserId'] = record.originalAppUserId;
      }
      await _firestore.collection('users').doc(_userId!).set(
        {
          'revenueCatDevices': {
            installId: payload,
          },
        },
        SetOptions(merge: true),
      );
      LogHelper.shared.debugPrint('✅ Merged RevenueCat device snapshot for install $installId');
    } catch (e) {
      LogHelper.shared.debugPrint('❌ Error merging RevenueCat device snapshot: $e');
    }
  }

  /// Writes subscription fields to the user document (merge). Call when RevenueCat state is known.
  Future<void> updateUserSubscription(
    bool isSubscribed, {
    String? subscriptionProductId,
    String? subscriptionExpirationDate,
  }) async {
    if (_userId == null) return;
    try {
      await _firestore.collection('users').doc(_userId!).set(
        {
          'isSubscribed': isSubscribed,
          if (subscriptionProductId != null) 'subscriptionProductId': subscriptionProductId,
          if (subscriptionExpirationDate != null) 'subscriptionExpirationDate': subscriptionExpirationDate,
        },
        SetOptions(merge: true),
      );
      LogHelper.shared.debugPrint('✅ Updated user subscription in Firestore: isSubscribed=$isSubscribed');
    } catch (e) {
      LogHelper.shared.debugPrint('❌ Error updating user subscription: $e');
    }
  }

  /// Updates the global habit constellation canvas state in Firestore.
  Future<void> updateCanvasState(double scale, double offsetX, double offsetY) async {
    if (_userId == null) return;

    if (!_isProSubscriber()) {
      LogHelper.shared.debugPrint('⚠️ updateCanvasState skipped: Cloud sync requires Pro.');
      return;
    }

    try {
      await _firestore.collection('users').doc(_userId!).set(
        {
          'canvasScale': scale,
          'canvasOffsetX': offsetX,
          'canvasOffsetY': offsetY,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      LogHelper.shared.debugPrint('✅ Updated habit constellation canvas state in Firestore: scale=$scale, offset=($offsetX, $offsetY)');
    } catch (e) {
      LogHelper.shared.debugPrint('❌ Error updating canvas state in Firestore: $e');
    }
  }
}
