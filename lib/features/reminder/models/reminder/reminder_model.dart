// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:hive_flutter/hive_flutter.dart';

import '../days/days_enum.dart';

part 'reminder_model.g.dart';

@HiveType(typeId: 4)
class ReminderModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final DateTime? reminderTime;

  @HiveField(2)
  final List<Days>? days;

  ReminderModel({
    required this.id,
    this.reminderTime,
    this.days,
  });

  ReminderModel copyWith({
    int? id,
    DateTime? time,
    List<Days>? days,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      reminderTime: time ?? this.reminderTime,
      days: days ?? this.days,
    );
  }

  @override
  String toString() => 'ReminderModel(id: $id, reminderTime: $reminderTime, days: $days)';
}
