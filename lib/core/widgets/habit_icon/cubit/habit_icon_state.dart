part of 'habit_icon_cubit.dart';

@immutable
sealed class HabitIconState {
  late final IconData? iconData;
}

final class HabitIconInitial extends HabitIconState {
  @override
  final IconData? iconData;

  HabitIconInitial({this.iconData});
}

final class HabitIconPicked extends HabitIconState {
  @override
  final IconData? iconData;

  HabitIconPicked({this.iconData});
}
