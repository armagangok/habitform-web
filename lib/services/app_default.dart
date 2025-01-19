import 'package:habitrise/core/core.dart';

import '../models/app_defaults/app_defaults.dart';

final class AppDefaultsService {
  // Private constructor
  AppDefaultsService._();

  // Static instance
  static final AppDefaultsService _shared = AppDefaultsService._();

  // Factory constructor to provide the instance
  factory AppDefaultsService() => _shared;

  Future<void> initializeAppDefaults() async {
    final AppDefaults? result = HiveHelper.shared.getData<AppDefaults?>(
      HiveBoxes.habitRiseDefaults,
      HiveKeys.habitRiseDefaultsKeys,
    );

    if (result == null) {
      final AppDefaults appDefaults = AppDefaults(isAppOpenedFirstTime: false);
      await HiveHelper.shared.putData<AppDefaults?>(
        HiveBoxes.habitRiseDefaults,
        HiveKeys.habitRiseDefaultsKeys,
        appDefaults,
      );
    }
  }

  Future<AppDefaults?> gettAppDefault() async {
    final appDefaults = HiveHelper.shared.getData<AppDefaults?>(
      HiveBoxes.habitRiseDefaults,
      HiveKeys.habitRiseDefaultsKeys,
    );

    return appDefaults;
  }

  Future<void> saveAppDefaults(AppDefaults appDefaults) async {
    await HiveHelper.shared.putData<AppDefaults?>(
      HiveBoxes.habitRiseDefaults,
      HiveKeys.habitRiseDefaultsKeys,
      appDefaults,
    );
  }
}
