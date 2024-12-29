import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '/models/habit_model.dart';
import '/services/habit_service.dart';

part 'habit_event.dart';
part 'habit_state.dart';

class SingleHabitBloc extends Bloc<SingleHabitEvent, SingleHabitState> {
  final habitService = HabitService();

  SingleHabitBloc() : super(HabitInitial()) {
    on<FetchHabitsEvent>(_onFetchHabits);
    on<IdleHabitEvent>(_idle);
    on<SaveHabitsEvent>(_saveHabit);
  }

  Future<void> _onFetchHabits(FetchHabitsEvent event, Emitter<SingleHabitState> emit) async {
    try {
      emit(HabitsLoading());
      final response = await habitService.fetchHabits();
      emit(HabitsFetched(response));
    } on PlatformException catch (e, s) {
      debugPrint(s.toString());
      emit(HabitsFetchError(e.message ?? "An error occurred while fetching habits"));
    }
  }

  Future<void> _idle(IdleHabitEvent event, Emitter<SingleHabitState> emit) async {}

  Future<void> _saveHabit(SaveHabitsEvent event, Emitter<SingleHabitState> emit) async {}
}
