import '../../../core.dart';

part 'habit_color_state.dart';

class HabitColorCubit extends Cubit<HabitColorState> {
  HabitColorCubit() : super(HabitColorInitial(null));

  void pickColor(Color? color) {
    emit(HabitColorPicked(color));
  }
}
