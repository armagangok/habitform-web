import 'package:hive_flutter/hive_flutter.dart';

import '/models/models.dart';
import '../../../features/reminder/models/days/days_enum.dart';
import '../../../features/reminder/models/reminder/reminder_model.dart';
import '../../../models/app_defaults/app_defaults.dart';
import '../../../models/preferences/user_defaults.dart';
import '../../core.dart';

class HiveHelper {
  const HiveHelper._();
  static const shared = HiveHelper._();

  Future<void> initializeHive() async {
    await Hive.initFlutter();
    await _initBoxes();
  }

  Future<void> _initBoxes() async {
    try {
      Hive.registerAdapter(DaysAdapter());
      Hive.registerAdapter(ReminderModelAdapter());
      Hive.registerAdapter(HabitAdapter());
      Hive.registerAdapter(UserDefaultsAdapter());
      Hive.registerAdapter(AppDefaultsAdapter());

      await Hive.openBox<Habit>(HiveBoxes.habitBox);
      await Hive.openBox<String?>(HiveBoxes.themeBox);
      await Hive.openBox<UserDefaults?>(HiveBoxes.userDeafultsBox);
      await Hive.openBox<AppDefaults?>(HiveBoxes.habitRiseDefaults);
    } catch (e) {
      LogHelper.shared.debugPrint('$e');
    }
  }

  T? getData<T>(String boxName, dynamic key) {
    var box = Hive.box<T>(boxName);
    return box.get(key);
  }

  Future<void> deleteData<T>(String boxName, dynamic key) async {
    var box = Hive.box<T>(boxName);
    await box.delete(key);
  }

  Future<void> deleteDataAt<T>(String boxName, int index) async {
    var box = Hive.box<T>(boxName);
    await box.deleteAt(index);
  }

  Future<void> deleteAll<T>(String boxName, Iterable<dynamic> keys) async {
    var box = Hive.box<T>(boxName);
    await box.deleteAll(keys);
  }

  Future<void> putData<T>(String boxName, dynamic key, T data) async {
    var box = Hive.box<T>(boxName);
    await box.put(key, data);
  }

  Future<void> putAllData<T>(String boxName, Map<dynamic, T> data) async {
    var box = Hive.box<T>(boxName);
    await box.putAll(data);
  }

  Future<List<T>> getAll<T>(String boxName) async {
    var box = Hive.box<T>(boxName);
    return box.values.toList();
  }

  Future<int> addData<T>(String boxName, T dataToAdd) async {
    var box = Hive.box<T>(boxName);
    return box.add(dataToAdd);
  }

  Future<void> clearBox<T>(String boxName) async {
    var box = Hive.box<T>(boxName);
    await box.clear();
  }

  Future<void> putDataAt<T>(String boxName, T dataToAdd, int index) async {
    var box = Hive.box<T>(boxName);
    await box.putAt(index, dataToAdd);
  }
}
