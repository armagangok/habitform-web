// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:hive_flutter/hive_flutter.dart';

import '../days/days_enum.dart';
import '../multiple_reminder/multiple_reminder_model.dart';

part 'reminder_model.g.dart';

@HiveType(typeId: 4)
class ReminderModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final DateTime? reminderTime;

  @HiveField(2)
  final List<Days>? days;

  @HiveField(3)
  final MultipleReminderModel? multipleReminders;

  ReminderModel({
    required this.id,
    this.reminderTime,
    this.days,
    this.multipleReminders,
  });

  ReminderModel copyWith({
    int? id,
    DateTime? time,
    List<Days>? days,
    MultipleReminderModel? multipleReminders,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      reminderTime: time,
      days: days ?? this.days,
      multipleReminders: multipleReminders ?? this.multipleReminders,
    );
  }

  @override
  String toString() => 'ReminderModel(id: $id, reminderTime: $reminderTime, days: $days, multipleReminders: $multipleReminders)';

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'],
      reminderTime: json['reminderTime'] != null ? DateTime.parse(json['reminderTime'] as String) : null,
      days: json['days'] != null ? List<Days>.from(json['days'].map((e) => Days.values[e])) : null,
      multipleReminders: json['multipleReminders'] != null ? MultipleReminderModel.fromJson(json['multipleReminders']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reminderTime': reminderTime?.toIso8601String(),
      'days': days?.map((e) => e.index).toList(),
      'multipleReminders': multipleReminders?.toJson(),
    };
  }

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'],
      reminderTime: map['reminderTime'] != null ? DateTime.parse(map['reminderTime'] as String) : null,
      days: map['days'] != null ? List<Days>.from(map['days'].map((e) => Days.values[e])) : null,
      multipleReminders: map['multipleReminders'] != null ? MultipleReminderModel.fromMap(map['multipleReminders']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reminderTime': reminderTime?.toIso8601String(),
      'days': days?.map((e) => e.index).toList(),
      'multipleReminders': multipleReminders?.toMap(),
    };
  }

  // Helper methods for multiple reminders
  bool get hasMultipleReminders => multipleReminders != null && multipleReminders!.isValid;

  bool get hasSingleReminder => reminderTime != null && !hasMultipleReminders;

  bool get hasAnyReminders => hasSingleReminder || hasMultipleReminders;

  // Get all reminder times (single or multiple)
  List<DateTime> get allReminderTimes {
    if (hasMultipleReminders) {
      return multipleReminders!.sortedReminderTimes;
    } else if (hasSingleReminder) {
      return [reminderTime!];
    }
    return [];
  }
}
