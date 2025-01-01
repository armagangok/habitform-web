import 'package:hive_flutter/hive_flutter.dart';

import 'habit_model.dart';

part 'chained_habit_model.g.dart';

@HiveType(typeId: 1)
class ChainedHabit extends HiveObject {
  @HiveField(0)
  final String chainName;
  @HiveField(1)
  final String? description;
  @HiveField(2)
  final Habit? firstHabit;
  @HiveField(3)
  final Habit mainHabit;
  @HiveField(4)
  final Habit? secondHabit;

  bool isAllCompleted;
  final List<DateTime> completionDates;

  ChainedHabit({
    required this.chainName,
    this.description,
    this.firstHabit,
    required this.mainHabit,
    this.secondHabit,
    this.isAllCompleted = false,
    this.completionDates = const [],
  });

  ChainedHabit copyWith({
    String? chainName,
    String? description,
    Habit? firstHabit,
    Habit? mainHabit,
    Habit? secondHabit,
    bool? isAllCompleted,
    List<DateTime>? completionDates,
  }) {
    return ChainedHabit(
      chainName: chainName ?? this.chainName,
      description: description ?? this.description,
      firstHabit: firstHabit ?? this.firstHabit,
      mainHabit: mainHabit ?? this.mainHabit,
      secondHabit: secondHabit ?? this.secondHabit,
      isAllCompleted: isAllCompleted ?? this.isAllCompleted,
      completionDates: completionDates ?? this.completionDates,
    );
  }
}
