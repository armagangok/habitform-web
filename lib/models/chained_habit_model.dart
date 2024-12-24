import 'habit_model.dart';

class ChainedHabit {
  final String chainName;

  final Habit? firstHabit;
  final Habit mainHabit;
  final Habit? secondHabit;

  ChainedHabit({
    required this.chainName,
    this.firstHabit,
    required this.mainHabit,
    this.secondHabit,
  });
}
