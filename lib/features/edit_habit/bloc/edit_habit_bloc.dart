import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/habit/habit_model.dart';
import '../../habits/bloc/habit_bloc.dart';

part 'edit_habit_event.dart';
part 'edit_habit_state.dart';

class EditHabitBloc extends Bloc<IEditHabitEvent, EditHabitState> {
  final HabitBloc _singleHabitBloc;

  EditHabitBloc(this._singleHabitBloc) : super(EditHabitInitial()) {
    on<UpdateEditHabitEvent>(_onUpdateHabit);
  }

  Future<void> _onUpdateHabit(UpdateEditHabitEvent event, Emitter<EditHabitState> emit) async {
    emit(EditHabitLoading());
    try {
      _singleHabitBloc.add(UpdateHabitEvent(habit: event.habit));
      emit(EditHabitSuccess());
    } catch (e) {
      emit(EditHabitFailure(error: e.toString()));
    }
  }
}
