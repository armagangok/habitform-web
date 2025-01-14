part of 'habit_icon_cubit.dart';

@immutable
sealed class HabitIconState {
  late final String? emoji;
}

final class HabitIconInitial extends HabitIconState {
  @override
  final String? emoji;

  HabitIconInitial({this.emoji});
}

final class HabitIconPicked extends HabitIconState {
  @override
  final String? emoji;

  HabitIconPicked({this.emoji});
}
