import 'package:flutter/services.dart';

import '/core/core.dart';
import '../../../models/habit/habit_model.dart';
import '../../../services/services.dart';
import '../helper/habit_sorter.dart';

part 'habit_event.dart';
part 'habit_state.dart';

class HabitBloc extends Bloc<HabitEvent, HabitState> {
  final IHabitService habitService;

  HabitBloc({required this.habitService}) : super(SingleHabitInitial()) {
    on<FetchHabitEvent>(_onFetchHabits);
    on<IdleHabitEvent>(_idle);
    on<SaveHabitEvent>(_saveNewHabit);
    on<DeleteHabitEvent>(_deleteHabit);
    on<UpdateHabitForSelectedDayEvent>(_updateHabitForSelectedDay);
    on<UpdateHabitEvent>(_onUpdateHabit);
  }

  Future<void> _onFetchHabits(FetchHabitEvent event, Emitter<HabitState> emit) async {
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

  Future<void> _saveNewHabit(SaveHabitEvent event, Emitter<HabitState> emit) async {
    try {
      emit(SingleHabitLoading());
      await habitService.addData(event.habit);
      emit(SingleHabitSaveSuccess("${event.habit.habitName}: Habit saved successfully"));

      // Fetch the updated list of habits
      add(FetchHabitEvent());
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

  Future<void> _deleteHabit(DeleteHabitEvent event, Emitter<HabitState> emit) async {
    try {
      await habitService.deleteHabit(event.habit.id);
      add(FetchHabitEvent());
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
    IdleHabitEvent event,
    Emitter<HabitState> emit,
  ) async {
    // No action needed for idle event
  }

  Future<void> _updateHabitForSelectedDay(UpdateHabitForSelectedDayEvent event, Emitter<HabitState> emit) async {
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
      add(FetchHabitEvent());
    } catch (e, s) {
      LogHelper.shared.debugPrint('$e');
      LogHelper.shared.debugPrint('$s');
    }
  }

  Future<void> _onUpdateHabit(UpdateHabitEvent event, Emitter<HabitState> emit) async {
    try {
      emit(SingleHabitLoading());
      await habitService.updateHabit(event.habit);
      add(FetchHabitEvent());
    } catch (e, s) {
      LogHelper.shared.debugPrint('$e');
      LogHelper.shared.debugPrint('$s');
      emit(SingleHabitSaveError(e.toString()));
    }
  }
}
