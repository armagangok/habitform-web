import 'package:flutter/services.dart';

import '/core/core.dart';
import '/models/single_habit/habit_model.dart';
import '/services/single_habit/i_single_habit_service.dart';
import '../../helper/habit_sorter.dart';

part 'single_habit_event.dart';
part 'single_habit_state.dart';

class SingleHabitBloc extends Bloc<SingleHabitEvent, SingleHabitState> {
  final IHabitService habitService;

  SingleHabitBloc({required this.habitService}) : super(SingleHabitInitial()) {
    on<FetchSingleHabitEvent>(_onFetchHabits);
    on<IdleSingleHabitEvent>(_idle);
    on<SaveSingleHabitEvent>(_saveNewHabit);
    on<DeleteSingleHabitEvent>(_deleteHabit);
    on<UpdateHabitForSelectedDayEvent>(_updateHabitForSelectedDay);
    on<UpdateSingleHabitEvent>(_onUpdateHabit);
  }

  Future<void> _onFetchHabits(FetchSingleHabitEvent event, Emitter<SingleHabitState> emit) async {
    try {
      emit(SingleHabitLoading());
      final habits = await habitService.getAllHabits();
      sortHabitsByReminderTime(habits);
      emit(SingleHabitsFetched(habits));
    } on PlatformException catch (e, s) {
      debugPrint('Error fetching habits: $e\nStack trace: $s');
      emit(SingleHabitFetchError(e.message ?? "An error occurred while fetching habits"));
    } catch (e, s) {
      debugPrint('Unexpected error fetching habits: $e\nStack trace: $s');
      emit(SingleHabitFetchError("An unexpected error occurred"));
    }
  }

  Future<void> _saveNewHabit(SaveSingleHabitEvent event, Emitter<SingleHabitState> emit) async {
    try {
      emit(SingleHabitLoading());
      await habitService.addData(event.habit);
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

  Future<void> _deleteHabit(DeleteSingleHabitEvent event, Emitter<SingleHabitState> emit) async {
    try {
      await habitService.deleteHabit(event.habit.id);
      add(FetchSingleHabitEvent());
    } on PlatformException catch (e, s) {
      LogHelper.shared.debugPrint('Unexpected error saving habit: $e');
      LogHelper.shared.debugPrint('Stack trace: $s');
      emit(SingleHabitSaveError(e.message ?? "An error occurred while deleting the habit"));
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

  Future<void> _updateHabitForSelectedDay(UpdateHabitForSelectedDayEvent event, Emitter<SingleHabitState> emit) async {
    try {
      final DateTime selectedDate = event.dateToSaveOrRemove;

      // Get or create the updated completion dates list
      final updatedCompletionDates = event.habit.completionDates?.map((date) {
            return DateTime(date.year, date.month, date.day);
          }).toList() ??
          [];

      // If the selected date is already in the list, remove it; otherwise, add it
      if (updatedCompletionDates.any((date) => date.year == selectedDate.year && date.month == selectedDate.month && date.day == selectedDate.day)) {
        updatedCompletionDates.removeWhere((date) => date.year == selectedDate.year && date.month == selectedDate.month && date.day == selectedDate.day);
      } else {
        updatedCompletionDates.add(selectedDate);
      }

      final updatedHabit = event.habit.copyWith(completionDates: updatedCompletionDates);

      await habitService.updateHabit(updatedHabit);
      add(FetchSingleHabitEvent());
    } catch (e) {
      // Handle errors as before
    }
  }

  Future<void> _onUpdateHabit(UpdateSingleHabitEvent event, Emitter<SingleHabitState> emit) async {
    try {
      emit(SingleHabitLoading());
      await habitService.updateHabit(event.habit);
      add(FetchSingleHabitEvent());
    } catch (e) {
      emit(SingleHabitSaveError(e.toString()));
    }
  }
}
