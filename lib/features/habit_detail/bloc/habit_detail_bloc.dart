import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '/models/habit/habit_model.dart';

part 'habit_detail_event.dart';
part 'habit_detail_state.dart';

class HabitDetailBloc extends Bloc<HabitDetailEvent, HabitDetailState> {
  HabitDetailBloc() : super(HabitDetailInitial()) {
    on<InitializeHabitDetailEvent>(_onInitialize);
    on<UpdateHabitDetailEvent>(_onUpdate);
  }

  void _onInitialize(InitializeHabitDetailEvent event, Emitter<HabitDetailState> emit) {
    emit(HabitDetailLoaded(habit: event.habit));
  }

  void _onUpdate(UpdateHabitDetailEvent event, Emitter<HabitDetailState> emit) {
    if (state is HabitDetailLoaded) {
      emit(HabitDetailLoaded(habit: event.habit));
    }
  }
}
