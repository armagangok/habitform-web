import 'package:flutter/services.dart';

import '/core/core.dart';
import '/services/single_habit/i_single_habit_service.dart';
import '../../../../models/single_habit/habit_model.dart';

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

  Future<void> _updateHabitForSelectedDay(UpdateHabitForSelectedDayEvent event, Emitter<SingleHabitState> emit) async {
    try {
      // Şu anki tarihi sadece yıl, ay ve gün olarak al
      final today = DateTime(event.selectedDate.year, event.selectedDate.month, event.selectedDate.day);

      // completionDates listesini al veya yeni bir liste oluştur
      final updatedCompletionDates = event.habit.completionDates?.map((date) {
            // ISO formatındaki string tarihleri DateTime'e çevir
            final parsedDate = DateTime.parse(date);
            return DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
          }).toList() ??
          [];

      // Eğer tarih zaten listede varsa kaldır, yoksa ekle
      if (updatedCompletionDates.contains(today)) {
        updatedCompletionDates.remove(today); // Tarihi kaldır
      } else {
        updatedCompletionDates.add(today); // Tarihi ekle
      }

      // Listeyi tekrar ISO 8601 formatına çevir
      final updatedCompletionDatesStrings = updatedCompletionDates.map((date) => date.toIso8601String()).toList();

      // Yeni completionDates listesi ile Habit nesnesini güncelle
      final updatedHabit = event.habit.copyWith(completionDates: updatedCompletionDatesStrings);

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
