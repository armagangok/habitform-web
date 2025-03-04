import 'package:hive_flutter/hive_flutter.dart';

part 'habit_status.g.dart';

@HiveType(typeId: 7)
enum HabitStatus {
  @HiveField(0)
  active,

  @HiveField(1)
  archived,
}
