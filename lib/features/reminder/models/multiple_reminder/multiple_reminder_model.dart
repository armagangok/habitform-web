// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:hive_flutter/hive_flutter.dart';

import '../days/days_enum.dart';

part 'multiple_reminder_model.g.dart';

@HiveType(typeId: 77)
class MultipleReminderModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final List<DateTime> reminderTimes;

  @HiveField(2)
  final List<Days>? days;

  MultipleReminderModel({
    required this.id,
    required this.reminderTimes,
    this.days,
  });

  MultipleReminderModel copyWith({
    int? id,
    List<DateTime>? reminderTimes,
    List<Days>? days,
  }) {
    return MultipleReminderModel(
      id: id ?? this.id,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      days: days ?? this.days,
    );
  }

  @override
  String toString() => 'MultipleReminderModel(id: $id, reminderTimes: $reminderTimes, days: $days)';

  factory MultipleReminderModel.fromJson(Map<String, dynamic> json) {
    return MultipleReminderModel(
      id: json['id'],
      reminderTimes: (json['reminderTimes'] as List<dynamic>?)?.map((e) => DateTime.parse(e as String)).toList() ?? [],
      days: json['days'] != null ? List<Days>.from(json['days'].map((e) => Days.values[e])) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reminderTimes': reminderTimes.map((e) => e.toIso8601String()).toList(),
      'days': days?.map((e) => e.index).toList(),
    };
  }

  factory MultipleReminderModel.fromMap(Map<String, dynamic> map) {
    return MultipleReminderModel(
      id: map['id'],
      reminderTimes: (map['reminderTimes'] as List<dynamic>?)?.map((e) => DateTime.parse(e as String)).toList() ?? [],
      days: map['days'] != null ? List<Days>.from(map['days'].map((e) => Days.values[e])) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reminderTimes': reminderTimes.map((e) => e.toIso8601String()).toList(),
      'days': days?.map((e) => e.index).toList(),
    };
  }

  // Helper method to check if this is a valid multiple reminder
  bool get isValid => reminderTimes.isNotEmpty;

  // Helper method to get sorted reminder times
  List<DateTime> get sortedReminderTimes {
    final sorted = List<DateTime>.from(reminderTimes);
    sorted.sort((a, b) => a.hour * 60 + a.minute - (b.hour * 60 + b.minute));
    return sorted;
  }
}
