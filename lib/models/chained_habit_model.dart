import 'habit_model.dart';

class ChainedHabit {
  final String chainName;
  final String? description;
  final Habit? firstHabit;
  final Habit mainHabit;
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
