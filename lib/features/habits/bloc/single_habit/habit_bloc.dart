import 'package:flutter/services.dart';

import '/core/core.dart';
import '/models/habit_model.dart';
import '/services/single_habit/i_single_habit_service.dart';

part 'habit_event.dart';
part 'habit_state.dart';

class SingleHabitBloc extends Bloc<SingleHabitEvent, SingleHabitState> {
  final IHabitService habitService;

  SingleHabitBloc({required this.habitService}) : super(SingleHabitInitial()) {
    on<FetchSingleHabitEvent>(_onFetchHabits);
    on<IdleSingleHabitEvent>(_idle);
    on<SaveSingleHabitEvent>(_saveNewHabit);
  }

  Future<void> _onFetchHabits(
    FetchSingleHabitEvent event,
    Emitter<SingleHabitState> emit,
  ) async {
    try {
      emit(SingleHabitLoading());
      final habits = await habitService.getAllHabits();
      emit(HabitsFetched(habits));
    } on PlatformException catch (e, s) {
      debugPrint('Error fetching habits: $e\nStack trace: $s');
      emit(SingleHabitFetchError(e.message ?? "An error occurred while fetching habits"));
    } catch (e, s) {
      debugPrint('Unexpected error fetching habits: $e\nStack trace: $s');
      emit(SingleHabitFetchError("An unexpected error occurred"));
    }
  }

  Future<void> _saveNewHabit(
    SaveSingleHabitEvent event,
    Emitter<SingleHabitState> emit,
  ) async {
    try {
      emit(SingleHabitLoading());
      await habitService.insertHabit(event.habit);
      emit(SingleHabitSaveSuccess("${event.habit.habitName}: Habit saved successfully"));

      // Fetch the updated list of habits
      add(FetchSingleHabitEvent());
    } on PlatformException catch (e, s) {
      LogHelper.shared.debugPrint('Error saving habit: $e');
      LogHelper.shared.debugPrint('Stack trace: $s');
      emit(SingleHabitSaveError(e.message ?? "An error occurred while saving the habit"));
    } catch (e, s) {
      LogHelper.shared.debugPrint('Unexpected error saving habit: $e');
      LogHelper.shared.debugPrint('Stack trace: $s');
      emit(SingleHabitSaveError("An unexpected error occurred"));
    }
  }

  Future<void> _idle(
    IdleSingleHabitEvent event,
    Emitter<SingleHabitState> emit,
  ) async {
    // No action needed for idle event
  }
}
