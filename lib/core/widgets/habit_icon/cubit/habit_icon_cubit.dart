import '../../../core.dart';

part 'habit_icon_state.dart';

class HabitIconCubit extends Cubit<HabitIconState> {
  HabitIconCubit() : super(HabitIconInitial(iconData: null));

  void pickIcon(IconData? iconData) {
    emit(HabitIconPicked(iconData: iconData));
  }
}
