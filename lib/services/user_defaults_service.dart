import 'package:habitrise/core/core.dart';

import '../models/user_defaults/user_defaults.dart';

final class UserDefaultsService {
  UserDefaultsService._();
  static final UserDefaultsService _instance = UserDefaultsService._();
  static UserDefaultsService get instance => _instance;

  Future<UserDefaults?> getUserDefaults() async {
    final userDefaults = HiveHelper.shared.getData<UserDefaults>(
      HiveBoxes.userDefaultsBox,
      'userDefaults',
    );
    return userDefaults;
  }

  Future<void> setUserDefaults(UserDefaults userDefaults) async {
    await HiveHelper.shared.putData(
      HiveBoxes.userDefaultsBox,
      HiveKeys.userDefaultsKey,
      userDefaults,
    );
  }
}
