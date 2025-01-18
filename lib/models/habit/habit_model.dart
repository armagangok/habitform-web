import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../features/reminder/models/reminder/reminder_model.dart';

part 'habit_model.g.dart';

@HiveType(typeId: 1)
class Habit extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String habitName;

  @HiveField(2)
  final String? habitDescription;

  @HiveField(3)
  final String? emoji;

  @HiveField(4)
  final ReminderModel? reminderModel;

  @HiveField(5)
  List<DateTime>? completionDates;

  @HiveField(6)
  final int colorCode;

  Habit({
    required this.id,
    required this.habitName,
    this.habitDescription,
    this.emoji,
    this.reminderModel,
    this.completionDates,
    required this.colorCode,
  });

  Habit copyWith({
    String? id,
    String? habitName,
    String? habitDescription,
    String? emoji,
    ReminderModel? reminderModel,
    List<DateTime>? completionDates,
    bool? isCompletedToday,
    int? colorCode,
  }) {
    return Habit(
      id: id ?? this.id,
      habitName: habitName ?? this.habitName,
      habitDescription: habitDescription ?? this.habitDescription,
      emoji: emoji ?? this.emoji,
      reminderModel: reminderModel ?? this.reminderModel,
      completionDates: completionDates ?? this.completionDates,
      colorCode: colorCode ?? this.colorCode,
    );
  }

  @override
  bool operator ==(covariant Habit other) {
    if (identical(this, other)) return true;

    return other.id == id && other.habitName == habitName && other.habitDescription == habitDescription && other.emoji == emoji && other.reminderModel == reminderModel && listEquals(other.completionDates, completionDates);
  }

  @override
  int get hashCode {
    return id.hashCode ^ habitName.hashCode ^ habitDescription.hashCode ^ emoji.hashCode ^ reminderModel.hashCode ^ completionDates.hashCode;
  }

  @override
  String toString() {
    return 'Habit(id: $id, habitName: $habitName, habitDescription: $habitDescription, emoji: $emoji, reminderModel: $reminderModel, completionDates: $completionDates, colorCode: $colorCode)';
  }

  bool get isCompletedToday {
    if (completionDates == null || completionDates!.isEmpty) return false;

    final today = DateTime.now();
    return completionDates!.any((dateStr) {
      final date = dateStr;
      return date.year == today.year && date.month == today.month && date.day == today.day;
    });
  }
}
