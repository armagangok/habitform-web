import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'habit_icon_state.dart';

class HabitIconCubit extends Cubit<HabitIconState> {
  HabitIconCubit() : super(HabitIconInitial());
}
