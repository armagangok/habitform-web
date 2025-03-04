import 'package:easy_localization/easy_localization.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'user_goal_enum.g.dart';

@HiveType(typeId: 2)
enum UserGoal {
  @HiveField(0)
  betterProductivity,
  @HiveField(1)
  buildRoutine,
  @HiveField(2)
  breakBadHabits,
  @HiveField(3)
  getHealthier,
  @HiveField(4)
  timeManagement,
  @HiveField(5)
  reduceStress,
  @HiveField(6)
  other;

  String get title {
    switch (this) {
      case UserGoal.betterProductivity:
        return 'onboarding.goals.better_productivity'.tr();
      case UserGoal.buildRoutine:
        return 'onboarding.goals.build_routine'.tr();
      case UserGoal.breakBadHabits:
        return 'onboarding.goals.break_bad_habits'.tr();
      case UserGoal.getHealthier:
        return 'onboarding.goals.get_healthier'.tr();
      case UserGoal.timeManagement:
        return 'onboarding.goals.time_management'.tr();
      case UserGoal.reduceStress:
        return 'onboarding.goals.reduce_stress'.tr();
      case UserGoal.other:
        return 'onboarding.goals.other'.tr();
    }
  }

  static List<UserGoal> get allGoals => [
        betterProductivity,
        buildRoutine,
        breakBadHabits,
        getHealthier,
        timeManagement,
        reduceStress,
        other,
      ];
}
