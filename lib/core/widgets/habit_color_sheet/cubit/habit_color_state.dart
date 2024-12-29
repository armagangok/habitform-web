part of 'habit_color_cubit.dart';

@immutable
sealed class HabitColorState {
  late final Color? color;
}

final class HabitColorInitial extends HabitColorState {
  final Color? color;

  HabitColorInitial(this.color);
}

final class HabitColorPicked extends HabitColorState {
  final Color? color;

  HabitColorPicked(this.color);
}
