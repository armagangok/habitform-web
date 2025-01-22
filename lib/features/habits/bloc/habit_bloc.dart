import 'package:flutter/services.dart';

import '/core/core.dart';
import '../../../models/habit/habit_model.dart';
import '../../../services/services.dart';
import '../../reminder/service/reminder_service.dart';
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
      emit(HabitsFetched(habits));
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
      emit(SingleHabitSaveError(e.message ?? "An error occurred while deleting the habit"));
    } catch (e, s) {
      LogHelper.shared.debugPrint('Unexpected error deleting habit: $e');
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
      emit(SingleHabitLoading());
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
      emit(HabitsFetched(habits));
    } catch (e, s) {
      LogHelper.shared.debugPrint('Error updating habit: $e');
      LogHelper.shared.debugPrint('Stack trace: $s');
      emit(SingleHabitSaveError(e.toString()));
    }
  }

  Future<void> _onUpdateHabit(UpdateHabitEvent event, Emitter<HabitState> emit) async {
    try {
      emit(SingleHabitLoading());

      // Önce eski reminder'ı kontrol et ve iptal et
      final oldHabit = (await habitService.getAllHabits()).firstWhere(
        (h) => h.id == event.habit.id,
        orElse: () => event.habit,
      );

      if (oldHabit.reminderModel != null) {
        await ReminderService.cancelReminderNotification(oldHabit.reminderModel!.id);
      }

      // Yeni reminder'ı ayarla
      if (event.habit.reminderModel != null && event.habit.reminderModel!.days != null && event.habit.reminderModel!.days!.isNotEmpty && event.habit.reminderModel!.reminderTime != null) {
        await ReminderService.createReminderNotification(
          event.habit.reminderModel!,
          event.habit.habitName,
          "Time to complete your habit!",
        );
      }

      await habitService.updateHabit(event.habit);
      add(FetchHabitEvent());
    } catch (e, s) {
      LogHelper.shared.debugPrint('$e');
      LogHelper.shared.debugPrint('$s');
      emit(SingleHabitSaveError(e.toString()));
    }
  }
}
