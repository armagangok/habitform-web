import 'package:hive_flutter/hive_flutter.dart';

part 'days_enum.g.dart';

@HiveType(typeId: 8)
enum Days {
  @HiveField(0)
  mon,
  @HiveField(1)
  tue,
  @HiveField(2)
  wed,
  @HiveField(3)
  thu,
  @HiveField(4)
  fri,
  @HiveField(5)
  sat,
  @HiveField(6)
  sun,
}