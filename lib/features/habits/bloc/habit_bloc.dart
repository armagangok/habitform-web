import 'package:flutter/services.dart';

import '/core/core.dart';
import '../../../core/helpers/in_app_review/in_app_review.dart';
import '../../../models/habit/habit_model.dart';
import '../../../services/services.dart';
import '../../reminder/service/reminder_service.dart';
import '../helper/habit_sorter.dart';

part 'habit_event.dart';
part 'habit_state.dart';

class HabitBloc extends Bloc<HabitEvent, HabitState> {
  final IHabitService habitService;

  HabitBloc({required this.habitService}) : super(HabitInitial()) {
    on<FetchHabitEvent>(_onFetchHabits);
    on<IdleHabitEvent>(_idle);
    on<SaveHabitEvent>(_saveNewHabit);
    on<DeleteHabitEvent>(_deleteHabit);
    on<UpdateHabitForSelectedDayEvent>(_updateHabitForSelectedDay);
    on<UpdateHabitEvent>(_onUpdateHabit);
  }

  Future<void> _onFetchHabits(FetchHabitEvent event, Emitter<HabitState> emit) async {
    try {
      emit(HabitLoading());
      final habits = await habitService.getAllHabits();
      sortHabitsByReminderTime(habits);
      emit(HabitsFetched(habits));
    } on PlatformException catch (e, s) {
      debugPrint('Error fetching habits: $e\nStack trace: $s');
      emit(HabitFetchError(e.message ?? "An error occurred while fetching habits"));
    } catch (e, s) {
      debugPrint('Unexpected error fetching habits: $e\nStack trace: $s');
      emit(HabitFetchError("An unexpected error occurred"));
    }
  }

  Future<void> _saveNewHabit(SaveHabitEvent event, Emitter<HabitState> emit) async {
    try {
      emit(HabitLoading());
      await habitService.addData(event.habit);

      emit(HabitSaveSuccess("${event.habit.habitName}: Habit saved successfully"));

      // Fetch the updated list of habits
      add(FetchHabitEvent());

      await InAppReviewHelper.shared.requestReview();
    } on PlatformException catch (e, s) {
      LogHelper.shared.debugPrint('Error saving habit: $e');
      LogHelper.shared.debugPrint('Stack trace: $s');
      emit(HabitSaveError(e.message ?? "An error occurred while saving the habit"));
    } catch (e, s) {
      LogHelper.shared.debugPrint('Unexpected error saving habit: $e');
      LogHelper.shared.debugPrint('Stack trace: $s');
      emit(HabitSaveError("An unexpected error occurred"));
    }
  }

  Future<void> _deleteHabit(DeleteHabitEvent event, Emitter<HabitState> emit) async {
    try {
      // Önce reminder'ı iptal et
      if (event.habit.reminderModel != null) {
        await ReminderService.cancelReminderNotification(event.habit.reminderModel!.id);
      }

      // Sonra habit'i sil
      await habitService.deleteHabit(event.habit.id);
      add(FetchHabitEvent());
    } on PlatformException catch (e, s) {
      LogHelper.shared.debugPrint('Error deleting habit: $e');
      LogHelper.shared.debugPrint('Stack trace: $s');
      emit(HabitSaveError(e.message ?? "An error occurred while deleting the habit"));
    } catch (e, s) {
      LogHelper.shared.debugPrint('Unexpected error deleting habit: $e');
      LogHelper.shared.debugPrint('Stack trace: $s');
      emit(HabitSaveError("An unexpected error occurred"));
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
      // Don't emit loading state here as it causes UI flicker
      LogHelper.shared.debugPrint('Updating habit for selected day: ${event.dateToSaveOrRemove}');
      LogHelper.shared.debugPrint('Original habit: ${event.habit}');
      LogHelper.shared.debugPrint('Current completion dates: ${event.habit.completionDates}');

      final DateTime selectedDate = event.dateToSaveOrRemove;

      // Get the current habit from storage to ensure we have the latest data
      final currentHabit = HiveHelper.shared.getData<Habit>(HiveBoxes.habitBox, event.habit.id) ?? event.habit;
      LogHelper.shared.debugPrint('Current habit from storage: $currentHabit');

      // Get or create the updated completion dates list
      final updatedCompletionDates = currentHabit.completionDates?.map((date) => DateTime(date.year, date.month, date.day)).toList() ?? [];

      // If the selected date is already in the list, remove it; otherwise, add it
      if (updatedCompletionDates.any((date) => date.isSameDayWith(selectedDate))) {
        LogHelper.shared.debugPrint('Removing date from completion dates');
        updatedCompletionDates.removeWhere((date) => date.isSameDayWith(selectedDate));
      } else {
        LogHelper.shared.debugPrint('Adding date to completion dates');
        updatedCompletionDates.add(selectedDate);
      }

      final updatedHabit = currentHabit.copyWith(completionDates: updatedCompletionDates);
      LogHelper.shared.debugPrint('Updated habit before save: $updatedHabit');
      LogHelper.shared.debugPrint('Updated completion dates: ${updatedHabit.completionDates}');

      await habitService.updateHabit(updatedHabit);

      // Fetch updated habits and emit new state
      final habits = await habitService.getAllHabits();
      LogHelper.shared.debugPrint('Fetched habits after update: $habits');
      sortHabitsByReminderTime(habits);

      // Emit the fetched state directly without going through loading
      emit(HabitsFetched(habits));

      await InAppReviewHelper.shared.requestReview();
    } catch (e, s) {
      LogHelper.shared.debugPrint('Error updating habit: $e');
      LogHelper.shared.debugPrint('Stack trace: $s');
      emit(HabitSaveError(e.toString()));
    }
  }

  Future<void> _onUpdateHabit(UpdateHabitEvent event, Emitter<HabitState> emit) async {
    try {
      emit(HabitLoading());

      // Get the current habit from storage
      final currentHabit = HiveHelper.shared.getData<Habit>(HiveBoxes.habitBox, event.habit.id);
      LogHelper.shared.debugPrint('Current habit from storage before update: $currentHabit');

      // Cancel old reminder if exists
      try {
        if (currentHabit?.reminderModel != null) {
          LogHelper.shared.debugPrint('Cancelling old reminder: ${currentHabit?.reminderModel}');
          await ReminderService.cancelReminderNotification(currentHabit!.reminderModel!.id);
        }
      } catch (e) {
        LogHelper.shared.debugPrint('Error cancelling old reminder: $e');
      }

      // Set up new reminder if exists
      try {
        final reminderModel = event.habit.reminderModel;
        final days = reminderModel?.days;
        final reminderTime = reminderModel?.reminderTime;

        LogHelper.shared.debugPrint('New reminder details - Model: $reminderModel, Days: $days, Time: $reminderTime');

        if (reminderModel != null && days != null && days.isNotEmpty && reminderTime != null) {
          LogHelper.shared.debugPrint('Setting up new reminder notification');
          await ReminderService.createReminderNotification(
            reminderModel,
            event.habit.habitName,
            LocaleKeys.habit_timeToCompleteYourHabit.tr(),
          );
        }
      } catch (e) {
        LogHelper.shared.debugPrint('Error setting up new reminder: $e');
      }

      // Update the habit in storage
      try {
        LogHelper.shared.debugPrint('Updating habit in storage: ${event.habit}');
        await habitService.updateHabit(event.habit);
      } catch (e) {
        LogHelper.shared.debugPrint('Error updating habit in storage: $e');
        rethrow; // Re-throw to be caught by outer catch block
      }

      // Fetch updated habits
      add(FetchHabitEvent());

      await InAppReviewHelper.shared.requestReview();
    } catch (e, s) {
      LogHelper.shared.debugPrint('Error in _onUpdateHabit: $e');
      LogHelper.shared.debugPrint('Stack trace: $s');
      emit(HabitSaveError(e.toString()));
    }
  }
}
