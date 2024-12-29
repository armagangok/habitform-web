import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'add_habit_event.dart';
part 'add_habit_state.dart';

class AddHabitBloc extends Bloc<AddHabitEvent, AddHabitState> {
  AddHabitBloc() : super(AddHabitInitial()) {
    on<AddHabitEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
