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

  Habit({
    required this.id,
    required this.habitName,
    this.habitDescription,
    this.icon,
    this.reminderModel,
    this.completionDates,
  });

  Habit copyWith({
    String? id,
    String? habitName,
    String? habitDescription,
    String? icon,
    ReminderModel? reminderModel,
    List<String>? completionDates,
  }) {
    return Habit(
      id: id ?? this.id,
      habitName: habitName ?? this.habitName,
      habitDescription: habitDescription ?? this.habitDescription,
      icon: icon ?? this.icon,
      reminderModel: reminderModel ?? this.reminderModel,
      completionDates: completionDates ?? this.completionDates,
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
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    // Handle completionDates
    List<String>? completionDates;
    if (map['completionDates'] != null) {
      if (map['completionDates'] is List) {
        // If it's already a List, cast it to List<String>

        completionDates = List<String>.from(map['completionDates'] as List);
      } else if (map['completionDates'] is Uint8List) {
        // If it's a byte array, decode it into a String and split into a List
        completionDates = utf8.decode(map['completionDates'] as Uint8List).split(',');
      } else {
        // Handle unexpected types (e.g., log an error or throw an exception)
        debugPrint('Unexpected type for completionDates: ${map['completionDates'].runtimeType}');
        completionDates = null;
      }
    }

    return Habit(
      id: map['id'] as String,
      habitName: map['habitName'] as String,
      habitDescription: map['habitDescription'] != null ? map['habitDescription'] as String : null,
      icon: map['icon'] != null ? map['icon'] as String : null,
      reminderModel: map['reminderModel'] != null ? ReminderModel.fromMap(map['reminderModel'] as Map<String, dynamic>) : null,
      completionDates: completionDates,
    );
  }

  String toJson() => json.encode(toMap());

  factory Habit.fromJson(String source) => Habit.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Habit(id: $id, habitName: $habitName, habitDescription: $habitDescription, icon: $icon, reminderModel: $reminderModel, completionDates: $completionDates)';
  }

  @override
  bool operator ==(covariant Habit other) {
    if (identical(this, other)) return true;

    return other.id == id && other.habitName == habitName && other.habitDescription == habitDescription && other.icon == icon && other.reminderModel == reminderModel && listEquals(other.completionDates, completionDates);
  }

  @override
  int get hashCode {
    return id.hashCode ^ habitName.hashCode ^ habitDescription.hashCode ^ icon.hashCode ^ reminderModel.hashCode ^ completionDates.hashCode;
  }
}
