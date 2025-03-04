import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../../models/habit/habit_status.dart';
import '../../../models/models.dart';
import '../../../services/local_habit_service.dart';
import '../../home/provider/home_provider.dart';
import '../../reminder/service/reminder_service.dart';
import 'archivated_habits_state.dart';

final archivedHabitsProvider = AutoDisposeAsyncNotifierProvider<ArchivedHabitsNotifier, ArchivedHabitsState>(() {
  return ArchivedHabitsNotifier();
});

class ArchivedHabitsNotifier extends AutoDisposeAsyncNotifier<ArchivedHabitsState> {
  final LocalHabitService _habitService = LocalHabitService.instance;

  @override
  Future<ArchivedHabitsState> build() async {
    return fetchArchivedHabits();
  }

  Future<ArchivedHabitsState> fetchArchivedHabits() async {
    try {
      final archivedHabits = await _habitService.getArchivedHabits();

      return ArchivedHabitsState(
        archivedHabits: archivedHabits,
        isLoading: false,
      );
    } catch (e) {
      return ArchivedHabitsState(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> unarchiveHabit(String habitId) async {
    state = AsyncValue.data(state.value!.copyWith(isLoading: true));

    try {
      // Arşivden çıkarılmadan önce alışkanlık bilgilerini al
      final archivedHabit = state.value!.archivedHabits.firstWhere(
        (habit) => habit.id == habitId,
        orElse: () => throw Exception('Habit not found'),
      );

      // Alışkanlığı arşivden çıkar
      await _habitService.unarchiveHabit(habitId);

      // Arşivden çıkarılan alışkanlığın hatırlatıcısını yeniden oluştur
      if (archivedHabit.reminderModel != null) {
        await ReminderService.createReminderNotification(
          archivedHabit.reminderModel!,
          archivedHabit.habitName,
          LocaleKeys.reminder_habit_reminder_message.tr(),
        );
      }

      final updatedState = await fetchArchivedHabits();

      state = AsyncValue.data(updatedState.copyWith(
        successMessage: LocaleKeys.archived_habits_unarchive_success.tr(),
      ));

      ref.read(homeProvider.notifier).fetchHabits();
    } catch (e) {
      state = AsyncValue.data(state.value!.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> deleteArchivedHabit(Habit habit) async {
    state = AsyncValue.data(state.value!.copyWith(isLoading: true));

    try {
      // Alışkanlığı kalıcı olarak sil
      await _habitService.permanentlyDeleteHabit(habit.id);

      // Silinen alışkanlığı listeden kaldır
      final updatedHabits = state.value!.archivedHabits.where((h) => h.id != habit.id).toList();

      state = AsyncValue.data(ArchivedHabitsState(
        archivedHabits: updatedHabits,
        successMessage: LocaleKeys.archived_habits_marked_for_deletion.tr(),
      ));
    } catch (e) {
      state = AsyncValue.data(state.value!.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> recoverArchivedHabit(Habit habit) async {
    state = AsyncValue.data(state.value!.copyWith(isLoading: true));

    try {
      final updatedHabit = habit.copyWith(
        status: HabitStatus.archived,
      );
      await _habitService.updateArchivedHabit(updatedHabit);

      final updatedHabits = state.value!.archivedHabits.map((h) {
        return h.id == habit.id ? updatedHabit : h;
      }).toList();

      state = AsyncValue.data(
        ArchivedHabitsState(
          archivedHabits: updatedHabits,
          successMessage: "Habit recovered",
        ),
      );
    } catch (e) {
      state = AsyncValue.data(state.value!.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }
}
