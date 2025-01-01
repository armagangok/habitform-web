import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

part 'reminder_model.g.dart';
// ignore_for_file: public_member_api_docs, sort_constructors_first

@HiveType(typeId: 3)
class ReminderModel extends HiveObject {
  @HiveField(0)
  final String? reminderTime;

  @HiveField(1)
  final List<String>? days;

  ReminderModel({
    this.reminderTime,
    this.days,
  });

  ReminderModel copyWith({
    String? reminderTime,
    List<String>? days,
  }) {
    return ReminderModel(
      reminderTime: reminderTime ?? this.reminderTime,
      days: days ?? this.days,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'reminderTime': reminderTime,
      'days': days?.toList(),
    };
  }

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      reminderTime: map['reminderTime'] != null ? map['reminderTime'] as String : null,
      days: map['days'] != null ? List<String>.from((map['days'] as List<String>)) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ReminderModel.fromJson(String source) => ReminderModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'ReminderModel(reminderTime: $reminderTime, days: $days)';
}
