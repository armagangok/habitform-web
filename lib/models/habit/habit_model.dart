import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '/core/util/timestamp_converter.dart';
import '../../features/reminder/models/reminder/reminder_model.dart';
import '../../models/sync_status.dart';
import '../completion_entry/completion_entry.dart';
import 'habit_difficulty.dart';
import 'habit_extension.dart';
import 'habit_status.dart';

part 'habit_model.freezed.dart';
part 'habit_model.g.dart';

@freezed
@HiveType(typeId: 1)
class Habit extends HiveObject with _$Habit {
  factory Habit({
    @HiveField(0) required String id,
    @HiveField(1) required String habitName,
    @HiveField(2) String? habitDescription,
    @HiveField(3) String? emoji,
    @HiveField(4) ReminderModel? reminderModel,
    @Default(1) @HiveField(5) int dailyTarget,
    @HiveField(6) required int colorCode,
    @Default({}) @HiveField(7, defaultValue: {}) Map<String, CompletionEntry> completions,
    @TimestampConverter() @HiveField(8) DateTime? archiveDate,
    @Default(HabitStatus.active) @HiveField(10) HabitStatus status,
    @Default([]) @HiveField(11, defaultValue: []) List<String> categoryIds,
    @Default(HabitDifficulty.moderate) @HiveField(12) HabitDifficulty difficulty,
    @Default(1.0) @HiveField(13, defaultValue: 1.0) double rewardFactor,
    @TimestampConverter() @HiveField(14) DateTime? completionTime,
    @Default(SyncStatus.synced) @HiveField(15) SyncStatus syncStatus,
    @TimestampConverter() @HiveField(16) DateTime? updatedAt,
    @HiveField(17) double? constellationPosX,
    @HiveField(18) double? constellationPosY,
    @Default([]) @HiveField(19, defaultValue: []) List<String> linkedHabitIds,
  }) = _Habit;

  Habit._();

  /// Proxy methods to extension methods in [HabitUtils]
  /// Required for dynamic dispatch when objects are typed as dynamic (e.g. in [CircularHabitWidget])

  int getCountForDate(DateTime date) => HabitUtils(this).getCountForDate(date);

  CompletionEntry? getCompletionEntryForDate(DateTime date) => HabitUtils(this).getCompletionEntryForDate(date);

  double getCompletionRatioForDate(DateTime date) => HabitUtils(this).getCompletionRatioForDate(date);

  int calculateCurrentStreak() => HabitUtils(this).calculateCurrentStreak();

  factory Habit.fromJson(Map<String, dynamic> json) => _$HabitFromJson(json);
}
