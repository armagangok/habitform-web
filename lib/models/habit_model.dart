// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:habitrise/models/models.dart';

class Habit {
  Habit({
    required this.id,
    required this.habitName,
    this.habitDescription,
    required this.completeTime,
    this.icon,
    this.reminderModel,
    this.isCompletedToday = false,
  });

  final String id;
  final String habitName;
  final String? habitDescription;
  final String? completeTime;
  final String? icon;
  bool isCompletedToday;
  final ReminderModel? reminderModel;
  List<String>? completionDates;

  Habit copyWith({
    String? id,
    String? habitName,
    String? habitDescription,
    String? completeTime,
    String? icon,
    ReminderModel? reminderModel,
  }) {
    return Habit(
      id: id ?? this.id,
      habitName: habitName ?? this.habitName,
      habitDescription: habitDescription ?? this.habitDescription,
      completeTime: completeTime ?? this.completeTime,
      icon: icon ?? this.icon,
      reminderModel: reminderModel ?? this.reminderModel,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'habitName': habitName,
      'habitDescription': habitDescription,
      'completeTime': completeTime,
      'icon': icon,
      'reminderModel': reminderModel?.toJson(),
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    print(map["reminderModel"].runtimeType);
    return Habit(
      id: map['id'] as String,
      habitName: map['habitName'] as String,
      habitDescription: map['habitDescription'] != null ? map['habitDescription'] as String : null,
      completeTime: map['completeTime'],
      icon: map['icon'] != null ? map['icon'] as String : null,
      reminderModel: map['reminderModel'] != null ? ReminderModel.fromMap(jsonDecode(map['reminderModel'])) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Habit.fromJson(String source) => Habit.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Habit(id: $id, habitName: $habitName, habitDescription: $habitDescription, completeTime: $completeTime, icon: $icon, reminderModel: $reminderModel)';
  }

  @override
  bool operator ==(covariant Habit other) {
    if (identical(this, other)) return true;

    return other.id == id && other.habitName == habitName && other.habitDescription == habitDescription && other.completeTime == completeTime && other.icon == icon && other.reminderModel == reminderModel;
  }

  @override
  int get hashCode {
    return id.hashCode ^ habitName.hashCode ^ habitDescription.hashCode ^ completeTime.hashCode ^ icon.hashCode ^ reminderModel.hashCode;
  }
}
