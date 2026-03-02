import 'package:hive_flutter/hive_flutter.dart';

import '/models/models.dart';
import '../../../features/habit_category/model/habit_category_model.dart';
import '../../../features/reminder/models/days/days_enum.dart';
import '../../../features/reminder/models/multiple_reminder/multiple_reminder_model.dart';
import '../../../features/reminder/models/reminder/reminder_model.dart';
import '../../../models/app_defaults/app_defaults.dart';
import '../../../models/habit/habit_difficulty.dart';
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
      Hive.openBox<String?>(HiveBoxes.localeBox),
    ]);
    LogHelper.shared.debugPrint('Hive initialization completed successfully');
  }

  void _registerAdapters() {
    try {
      Hive.registerAdapter(HabitStatusAdapter());

      LogHelper.shared.debugPrint('All Hive adapters registered successfully');
    } catch (e, stack) {
      LogHelper.shared.debugPrint('Error registering Hive adapters: $e\n $stack');
    }

    try {
      Hive.registerAdapter(HabitDifficultyAdapter());
      LogHelper.shared.debugPrint('HabitDifficultyAdapter registered successfully');
    } catch (e, s) {
      LogHelper.shared.debugPrint('Error registering HabitDifficultyAdapter: $e\n $s');
    }

    try {
      Hive.registerAdapter(HabitCategoryAdapter());
      LogHelper.shared.debugPrint('HabitCategoryAdapter registered successfully');
    } catch (e, s) {
      LogHelper.shared.debugPrint('Error registering HabitCategoryAdapter: $e\n $s');
    }

    try {
      Hive.registerAdapter(HabitAdapter());
      LogHelper.shared.debugPrint('HabitAdapter registered successfully');
    } catch (e, s) {
      LogHelper.shared.debugPrint('Error registering HabitAdapter: $e\n $s');
    }

    try {
      Hive.registerAdapter(ReminderModelAdapter());
      LogHelper.shared.debugPrint('ReminderModelAdapter registered successfully');
    } catch (e, s) {
      LogHelper.shared.debugPrint('Error registering ReminderModelAdapter: $e\n $s');
    }

    try {
      Hive.registerAdapter(MultipleReminderModelAdapter());
      LogHelper.shared.debugPrint('MultipleReminderModelAdapter registered successfully');
    } catch (e, s) {
      LogHelper.shared.debugPrint('Error registering MultipleReminderModelAdapter: $e\n $s');
    }

    try {
      Hive.registerAdapter(DaysAdapter());
      LogHelper.shared.debugPrint('DaysAdapter registered successfully');
    } catch (e, s) {
      LogHelper.shared.debugPrint('Error registering DaysAdapter: $e\n $s');
    }

    try {
      Hive.registerAdapter(AppDefaultsAdapter());
      LogHelper.shared.debugPrint('AppDefaultsAdapter registered successfully');
    } catch (e, s) {
      LogHelper.shared.debugPrint('Error registering AppDefaultsAdapter: $e\n $s');
    }

    try {
      Hive.registerAdapter(CompletionEntryAdapter());
      LogHelper.shared.debugPrint('CompletionEntryAdapter registered successfully');
    } catch (e, s) {
      LogHelper.shared.debugPrint('Error registering CompletionEntryAdapter: $e\n $s');
    }

    try {
      Hive.registerAdapter(UserDefaultsAdapter());
      LogHelper.shared.debugPrint('UserDefaultsAdapter registered successfully');
    } catch (e, s) {
      LogHelper.shared.debugPrint('Error registering UserDefaultsAdapter: $e\n $s');
    }

    try {
      Hive.registerAdapter(SyncStatusAdapter());
      LogHelper.shared.debugPrint('SyncStatusAdapter registered successfully');
    } catch (e, s) {
      LogHelper.shared.debugPrint('Error registering SyncStatusAdapter: $e\n $s');
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
    }
  }
}
