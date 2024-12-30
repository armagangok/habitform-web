import 'dart:convert';

import 'package:flutter/foundation.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first

class ReminderModel {
  final String? reminderTime;
  final Set<String>? days;

  ReminderModel({
    this.reminderTime,
    this.days,
  });

  ReminderModel copyWith({
    String? reminderTime,
    Set<String>? days,
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
      days: map['days'] != null ? Set<String>.from((map['days'] as Set<String>)) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ReminderModel.fromJson(String source) => ReminderModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'ReminderModel(reminderTime: $reminderTime, days: $days)';

  @override
  bool operator ==(covariant ReminderModel other) {
    if (identical(this, other)) return true;

    return other.reminderTime == reminderTime && setEquals(other.days, days);
  }

  @override
  int get hashCode => reminderTime.hashCode ^ days.hashCode;
}
