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
      reminderTime: time,
      days: days ?? this.days,
    );
  }

  @override
  String toString() => 'ReminderModel(id: $id, reminderTime: $reminderTime, days: $days)';

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'],
      reminderTime: json['reminderTime'] != null ? DateTime.parse(json['reminderTime'] as String) : null,
      days: json['days'] != null ? List<Days>.from(json['days'].map((e) => Days.values[e])) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reminderTime': reminderTime?.toIso8601String(),
      'days': days?.map((e) => e.index).toList(),
    };
  }

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'],
      reminderTime: map['reminderTime'] != null ? DateTime.parse(map['reminderTime'] as String) : null,
      days: map['days'] != null ? List<Days>.from(map['days'].map((e) => Days.values[e])) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reminderTime': reminderTime?.toIso8601String(),
      'days': days?.map((e) => e.index).toList(),
    };
  }
}
