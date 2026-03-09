import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/models/completion_entry/completion_entry.dart';
import '/models/habit/habit_model.dart';
import '/models/sync_status.dart';
import '/models/user_defaults/user_defaults.dart';

final syncServiceProvider = Provider<SyncService>((ref) => SyncService());

class SyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'habitformdatabase');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _habitsCollection => _firestore.collection('users').doc(_userId).collection('habits');

  Future<void> syncHabit(Habit habit) async {
    LogHelper.shared.debugPrint('🔄 SyncService.syncHabit called for ${habit.id}. Current userId: $_userId');
    if (_userId == null) {
      LogHelper.shared.debugPrint('⚠️ Sync skipped: _userId is null. User not logged in?');
      return;
    }

    final user = _auth.currentUser;
    final defaults = HiveHelper.shared.getData<UserDefaults>(HiveBoxes.userDefaultsBox, HiveKeys.userDefaultsKey);
    final isPro = defaults?.isPro ?? false;

    // Determine if user signed in via a social provider (Apple, Google)
    // Social provider users are already trusted — no email verification needed.
    final isSocialProvider = user != null && user.providerData.any((p) => p.providerId == 'apple.com' || p.providerId == 'google.com');

    // Guard: Block sync ONLY for email/password users who haven't verified their email yet
    // and are not Pro subscribers. Social users and Pro users always sync.
    if (user != null && !user.isAnonymous && !isSocialProvider && !user.emailVerified && !isPro) {
      LogHelper.shared.debugPrint('⚠️ Sync skipped: Email not verified for ${user.email} (email/password account, not Pro).');
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

      await _habitsCollection.doc(habit.id).set(habitData);
      LogHelper.shared.debugPrint('✅ Synced habit ${habit.id} to Firestore');
    } catch (e, stack) {
      LogHelper.shared.debugPrint('❌ Error syncing habit ${habit.id}: $e\n$stack');
      rethrow;
    }
  }

  Future<List<Habit>> fetchRemoteHabits() async {
    if (_userId == null) return [];

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
