import 'package:habitrise/core/core.dart';

import '../../features/onboarding/enum/user_goal_enum.dart';
import '../../models/preferences/user_defaults.dart';

class UserDefaultsService {
  Future<void> setUserDefault(UserDefaults defaults) async {
    await HiveHelper.shared.putData<UserDefaults?>(HiveBoxes.userDeafultsBox, HiveKeys.userDefaultsKey, defaults);
  }

  Future<UserDefaults?> getUserGoals(List<UserGoal> goals) async {
    final response = HiveHelper.shared.getData<UserDefaults?>(HiveBoxes.userDeafultsBox, HiveKeys.userDefaultsKey);

    return response;
  }

  Future<void> clearUserGoals() async {
    await HiveHelper.shared.clearBox(HiveBoxes.userDeafultsBox);
  }
}
