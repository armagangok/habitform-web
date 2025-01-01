import 'package:flutter/services.dart';

import '/core/core.dart';
import '/models/habit_model.dart';
import '/services/single_habit/i_single_habit_service.dart';

part 'single_habit_event.dart';
part 'single_habit_state.dart';

class SingleHabitBloc extends Bloc<SingleHabitEvent, SingleHabitState> {
  final IHabitService habitService;

  SingleHabitBloc({required this.habitService}) : super(SingleHabitInitial()) {
    on<FetchSingleHabitEvent>(_onFetchHabits);
    on<IdleSingleHabitEvent>(_idle);
    on<SaveSingleHabitEvent>(_saveNewHabit);
    on<DeleteSingleHabitEvent>(_deleteHabit);
    on<UpdateHabitForTodayEvent>(_updateHabitForToday);
    on<UpdateHabitForSelectedDayEvent>(_updateHabitForSelectedDay);
  }

  Future<void> _onFetchHabits(FetchSingleHabitEvent event, Emitter<SingleHabitState> emit) async {
    try {
      emit(SingleHabitLoading());
      final habits = await habitService.getAllHabits();
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

  Future<void> _updateHabitForToday(UpdateHabitForTodayEvent event, Emitter<SingleHabitState> emit) async {
    try {
      // Şu anki tarihi al ve sadece yıl, ay ve gün bilgilerini kullan
      final currentDate = DateTime.now();
      final currentDateOnly = DateTime(currentDate.year, currentDate.month, currentDate.day);
      // completionDates listesini al veya yeni bir liste oluştur
      final updatedCompletionDates = event.habit.completionDates ?? [];
      // Listedeki tarihleri sadece yıl, ay ve gün bilgilerine indirge
      final existingDatesOnly = updatedCompletionDates.map((dateString) {
        final date = DateTime.parse(dateString);
        return DateTime(date.year, date.month, date.day);
      }).toList();
      // Eğer tarih zaten listede varsa kaldır, yoksa ekle
      if (existingDatesOnly.contains(currentDateOnly)) {
        // Tarihi bul ve kaldır
        final index = existingDatesOnly.indexOf(currentDateOnly);
        updatedCompletionDates.removeAt(index);
      } else {
        // Tarihi ISO 8601 formatında ekle
        updatedCompletionDates.add(currentDate.toIso8601String());
      }
      // Yeni completionDates listesi ile Habit nesnesini güncelle
      final updatedHabit = event.habit.copyWith(completionDates: updatedCompletionDates);

      await habitService.updateHabit(updatedHabit);
      add(FetchSingleHabitEvent());
    } on PlatformException catch (e, s) {
      LogHelper.shared.debugPrint('Unexpected error updating habit: $e');
      LogHelper.shared.debugPrint('Stack trace: $s');
      emit(SingleHabitSaveError(e.message ?? "An error occurred while updating the habit"));
    } catch (e, s) {
      LogHelper.shared.debugPrint('Unexpected error updating habit: $e');
      LogHelper.shared.debugPrint('Stack trace: $s');
      emit(SingleHabitSaveError("An error occurred while updating the habit"));
    }
  }

  Future<void> _updateHabitForSelectedDay(UpdateHabitForSelectedDayEvent event, Emitter<SingleHabitState> emit) async {
    try {
      // Şu anki tarihi ISO 8601 formatında al
      final currentDate = event.selectedDate.toIso8601String();

      // completionDates listesini al veya yeni bir liste oluştur
      final updatedCompletionDates = event.habit.completionDates ?? [];

      // Eğer tarih zaten listede varsa kaldır, yoksa ekle
      if (updatedCompletionDates.contains(currentDate)) {
        updatedCompletionDates.remove(currentDate); // Tarihi kaldır
      } else {
        updatedCompletionDates.add(currentDate); // Tarihi ekle
      }

      // Yeni completionDates listesi ile Habit nesnesini güncelle
      final updatedHabit = event.habit.copyWith(completionDates: updatedCompletionDates);

      // Güncelleme olayını tetikle
      await habitService.updateHabit(updatedHabit);
      add(FetchSingleHabitEvent());
    } on PlatformException catch (e, s) {
      LogHelper.shared.debugPrint('Unexpected error updating habit: $e');
      LogHelper.shared.debugPrint('Stack trace: $s');
      emit(SingleHabitSaveError(e.message ?? "An error occurred while updating the habit"));
    } catch (e, s) {
      LogHelper.shared.debugPrint('Unexpected error updating habit: $e');
      LogHelper.shared.debugPrint('Stack trace: $s');
      emit(SingleHabitSaveError("An error occurred while updating the habit"));
    }
  }
}
