import 'package:hive_flutter/hive_flutter.dart';

import '/models/models.dart';
import '../../../features/reminder/models/days/days_enum.dart';
import '../../../features/reminder/models/reminder/reminder_model.dart';
import '../../../models/app_defaults/app_defaults.dart';
import '../../../models/completion_entry/completion_entry.dart';
import '../../../models/habit/habit_model.dart';
import '../../../models/habit/habit_status.dart';
import '../../../models/user_defaults/user_defaults.dart';
import '../../core.dart';

class HiveHelper {
  const HiveHelper._();
  static const shared = HiveHelper._();

  Future<void> initializeHive() async {
    LogHelper.shared.debugPrint('Initializing Hive...');
    await Hive.initFlutter();

    // Register adapters
    LogHelper.shared.debugPrint('Registering Hive adapters...');
    _registerAdapters();

    // Open boxes
    LogHelper.shared.debugPrint('Opening Hive boxes...');
    await Future.wait([
      Hive.openBox<Habit>(HiveBoxes.habitBox),
      Hive.openBox<Habit>(HiveBoxes.archivedHabitBox),
      Hive.openBox<UserDefaults>(HiveBoxes.userDefaultsBox),
      Hive.openBox<String?>(HiveBoxes.habitRiseDefaults),
      Hive.openBox<String?>(HiveBoxes.themeBox),
    ]);
    LogHelper.shared.debugPrint('Hive initialization completed successfully');
  }

  void _registerAdapters() {
    try {
      Hive.registerAdapter(HabitStatusAdapter());
      Hive.registerAdapter(HabitAdapter());
      Hive.registerAdapter(ReminderModelAdapter());
      Hive.registerAdapter(DaysAdapter());
      Hive.registerAdapter(AppDefaultsAdapter());
      Hive.registerAdapter(CompletionEntryAdapter());
      Hive.registerAdapter(UserDefaultsAdapter());

      LogHelper.shared.debugPrint('All Hive adapters registered successfully');
    } catch (e, stack) {
      LogHelper.shared.debugPrint('Error registering Hive adapters: $e');
      LogHelper.shared.debugPrint('Stack trace: $stack');
      rethrow;
    }
  }

  T? getData<T>(String boxName, String key) {
    try {
      final box = Hive.box<T>(boxName);
      return box.get(key);
    } catch (e, stack) {
      LogHelper.shared.debugPrint('Error getting data from Hive box $boxName: $e');
      LogHelper.shared.debugPrint('Stack trace: $stack');
      return null;
    }
  }

  Future<void> setData<T>(String boxName, String key, T value) async {
    try {
      final box = Hive.box<T>(boxName);
      await box.put(key, value);
      await box.flush();
    } catch (e, stack) {
      LogHelper.shared.debugPrint('Error setting data in Hive box $boxName: $e');
      LogHelper.shared.debugPrint('Stack trace: $stack');
      rethrow;
    }
  }

  // Sadece gerektiğinde çağrılacak metod
  Future<void> clearAllBoxes() async {
    try {
      await Hive.deleteBoxFromDisk(HiveBoxes.habitBox);
      await Hive.deleteBoxFromDisk(HiveBoxes.themeBox);
      await Hive.deleteBoxFromDisk(HiveBoxes.userDefaultsBox);
      await Hive.deleteBoxFromDisk(HiveBoxes.habitRiseDefaults);
    } catch (e) {
      LogHelper.shared.debugPrint('Error clearing boxes: $e');
    }
  }

  Future<void> deleteData<T>(String boxName, dynamic key) async {
    var box = Hive.box<T>(boxName);
    await box.delete(key);
    await box.flush();
  }

  Future<void> deleteDataAt<T>(String boxName, int index) async {
    var box = Hive.box<T>(boxName);
    await box.deleteAt(index);
    await box.flush();
  }

  Future<void> deleteAll<T>(String boxName, Iterable<dynamic> keys) async {
    var box = Hive.box<T>(boxName);
    await box.deleteAll(keys);
    await box.flush();
  }

  Future<void> putData<T>(String boxName, dynamic key, T data) async {
    var box = Hive.box<T>(boxName);
    await box.put(key, data);
    await box.flush();
  }

  Future<void> putAllData<T>(String boxName, Map<dynamic, T> data) async {
    var box = Hive.box<T>(boxName);
    await box.putAll(data);
    await box.flush();
  }

  Future<List<T>> getAll<T>(String boxName) async {
    try {
      LogHelper.shared.debugPrint('Getting all data from box: $boxName');
      var box = Hive.box<T>(boxName);
      final values = box.values.toList();
      LogHelper.shared.debugPrint('Successfully retrieved ${values.length} items from $boxName');
      return values;
    } catch (e, stack) {
      LogHelper.shared.debugPrint('Error getting all data from box $boxName: $e');
      LogHelper.shared.debugPrint('Stack trace: $stack');
      return [];
    }
  }

  Future<int> addData<T>(String boxName, T dataToAdd) async {
    var box = Hive.box<T>(boxName);
    final result = box.add(dataToAdd);
    await box.flush();
    return result;
  }

  Future<void> clearBox<T>(String boxName) async {
    var box = Hive.box<T>(boxName);
    await box.clear();
    await box.flush();
  }

  Future<void> putDataAt<T>(String boxName, T dataToAdd, int index) async {
    var box = Hive.box<T>(boxName);
    await box.putAt(index, dataToAdd);
    await box.flush();
  }

  Future<void> flushBox<T>(String boxName) async {
    try {
      var box = Hive.box<T>(boxName);
      await box.flush();
      LogHelper.shared.debugPrint('Successfully flushed box: $boxName');
    } catch (e, stack) {
      LogHelper.shared.debugPrint('Error flushing box $boxName: $e');
      LogHelper.shared.debugPrint('Stack trace: $stack');
      rethrow;
    }
  }
}
