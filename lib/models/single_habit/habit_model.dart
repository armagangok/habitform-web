// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:habitrise/models/models.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'habit_model.g.dart';

@HiveType(typeId: 2)
class Habit extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String habitName;

  @HiveField(2)
  final String? habitDescription;

  @HiveField(3)
  final String? icon;

  @HiveField(4)
  final ReminderModel? reminderModel;

  @HiveField(5)
  List<String>? completionDates;

  @HiveField(6)
  bool isCompletedToday;

  Habit({
    required this.id,
    required this.habitName,
    this.habitDescription,
    this.icon,
    this.reminderModel,
    this.completionDates,
    this.isCompletedToday = false,
  });

  Habit copyWith({
    String? id,
    String? habitName,
    String? habitDescription,
    String? icon,
    ReminderModel? reminderModel,
    List<String>? completionDates,
    bool? isCompletedToday,
  }) {
    return Habit(
      id: id ?? this.id,
      habitName: habitName ?? this.habitName,
      habitDescription: habitDescription ?? this.habitDescription,
      icon: icon ?? this.icon,
      reminderModel: reminderModel ?? this.reminderModel,
      completionDates: completionDates ?? this.completionDates,
      isCompletedToday: isCompletedToday ?? this.isCompletedToday,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'habitName': habitName,
      'habitDescription': habitDescription,
      'icon': icon,
      'reminderModel': reminderModel?.toMap(),
      'completionDates': completionDates,
      'isCompletedToday': isCompletedToday,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] as String,
      habitName: map['habitName'] as String,
      habitDescription: map['habitDescription'] != null ? map['habitDescription'] as String : null,
      icon: map['icon'] != null ? map['icon'] as String : null,
      reminderModel: map['reminderModel'] != null ? ReminderModel.fromMap(map['reminderModel'] as Map<String, dynamic>) : null,
      completionDates: map['completionDates'] != null ? List<String>.from((map['completionDates'] as List<String>)) : null,
      isCompletedToday: map['isCompletedToday'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory Habit.fromJson(String source) => Habit.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Habit(id: $id, habitName: $habitName, habitDescription: $habitDescription, icon: $icon, reminderModel: $reminderModel, completionDates: $completionDates, isCompletedToday: $isCompletedToday)';
  }

  @override
  bool operator ==(covariant Habit other) {
    if (identical(this, other)) return true;

    return other.id == id && other.habitName == habitName && other.habitDescription == habitDescription && other.icon == icon && other.reminderModel == reminderModel && listEquals(other.completionDates, completionDates) && other.isCompletedToday == isCompletedToday;
  }

  @override
  int get hashCode {
    return id.hashCode ^ habitName.hashCode ^ habitDescription.hashCode ^ icon.hashCode ^ reminderModel.hashCode ^ completionDates.hashCode ^ isCompletedToday.hashCode;
  }
}
