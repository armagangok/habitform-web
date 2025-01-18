import 'package:hive_flutter/hive_flutter.dart';

import '../../features/onboarding/enum/user_goal_enum.dart';

part 'user_defaults.g.dart';

@HiveType(typeId: 5)
class UserDefaults extends HiveObject {
  @HiveField(0)
  final String userName;

  @HiveField(1)
  List<UserGoal>? userGoals;

  UserDefaults({
    required this.userName,
    this.userGoals,
  });
}
