import 'package:hive_flutter/adapters.dart';

import '../models/app_defaults/app_defaults.dart';

final class AppDefaultsService {
  // Private constructor
  AppDefaultsService._();

  // Static instance
  static final AppDefaultsService _shared = AppDefaultsService._();

  // Factory constructor to provide the instance
  factory AppDefaultsService() => _shared;

  static const String _boxName = 'app_defaults';
  static const String _key = 'app_defaults';

  Future<void> initializeAppDefaults() async {
    final box = await Hive.openBox(_boxName);
    if (!box.containsKey(_key)) {
      await box.put(_key, AppDefaults(isAppOpenedFirstTime: true));
    }
  }

  Future<AppDefaults?> gettAppDefault() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_key);
  }

  Future<void> saveAppDefaults(AppDefaults appDefaults) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_key, appDefaults);
  }

  Future<void> markAppAsOpened() async {
    final box = await Hive.openBox(_boxName);
    final appDefaults = box.get(_key) as AppDefaults?;
    if (appDefaults != null) {
      await box.put(_key, appDefaults.copyWith(isAppOpenedFirstTime: false));
    }
  }
}
