import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../../models/models.dart';
import '../../../services/habit_service/habit_service_interface.dart';
import '../../home/provider/home_provider.dart';
import '../../purchase/providers/purchase_provider.dart';
import '../../purchase/widgets/purchase_dialog.dart';
import '../../reminder/models/reminder/reminder_model.dart';
import '../../reminder/service/reminder_service.dart';
import 'archivated_habits_state.dart';

final archivedHabitsProvider = AutoDisposeAsyncNotifierProvider<ArchivedHabitsNotifier, ArchivedHabitsState>(() {
  return ArchivedHabitsNotifier();
});

class ArchivedHabitsNotifier extends AutoDisposeAsyncNotifier<ArchivedHabitsState> {
  @override
  Future<ArchivedHabitsState> build() async {
    return fetchArchivedHabits();
  }

  Future<ArchivedHabitsState> fetchArchivedHabits() async {
    try {
      final archivedHabits = await habitService.getArchivedHabits();

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

  Future<bool> canUnarchiveHabit() async {
    final subscriptionState = ref.read(purchaseProvider);
    return subscriptionState.valueOrNull?.isSubscriptionActive ?? false;
  }

  Future<void> unarchiveHabit(String habitId) async {
    state = AsyncValue.data(state.value!.copyWith(isLoading: true));

    try {
      // Pro kontrolü yap
      final isPro = await canUnarchiveHabit();
      if (!isPro) {
        showUnlockProDialog();
        return;
      }

      // Arşivden çıkarılmadan önce alışkanlık bilgilerini al
      final archivedHabit = state.value!.archivedHabits.firstWhere(
        (habit) => habit.id == habitId,
        orElse: () => throw Exception('Habit not found'),
      );

      // Alışkanlığı arşivden çıkar
      await habitService.unarchiveHabit(habitId);

      // Arşivden çıkarılan alışkanlığın hatırlatıcısını yeniden oluştur (emoji + isim)
      if (archivedHabit.reminderModel != null) {
        final emoji = archivedHabit.emoji ?? '';
        final title = emoji.isNotEmpty ? '$emoji ${archivedHabit.habitName}' : archivedHabit.habitName;
        await ReminderService.createReminderNotification(
          archivedHabit.reminderModel!,
          title,
          LocaleKeys.reminder_personalized_body.tr(namedArgs: {'habit': title}),
        );
      }

      // Update home page state properly
      await ref.read(homeProvider.notifier).refreshHabits();

      final updatedState = await fetchArchivedHabits();

      state = AsyncValue.data(updatedState.copyWith(
        successMessage: LocaleKeys.archived_habits_unarchive_success.tr(),
      ));
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
      // Cancel any remaining reminder notifications before deleting
      await ReminderService.cancelAllReminderNotifications(habit.reminderModel);

      // Alışkanlığı kalıcı olarak sil
      await habitService.permanentlyDeleteHabit(habit.id);

      // Silinen alışkanlığı listeden kaldır
      final updatedHabits = state.value!.archivedHabits.where((h) => h.id != habit.id).toList();

      // Trigger a reschedule of all remaining notifications to ensure archived habit's notifications are removed
      await _rescheduleAllNotifications();

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

  void toggleSelectionMode() {
    state = AsyncValue.data(state.value!.copyWith(
      isSelectionMode: !state.value!.isSelectionMode,
      selectedHabitIds: state.value!.isSelectionMode ? {} : state.value!.selectedHabitIds,
    ));
  }

  void toggleHabitSelection(String habitId) {
    final currentSelected = Set<String>.from(state.value!.selectedHabitIds);
    if (currentSelected.contains(habitId)) {
      currentSelected.remove(habitId);
    } else {
      currentSelected.add(habitId);
    }

    state = AsyncValue.data(state.value!.copyWith(
      selectedHabitIds: currentSelected,
    ));
  }

  Future<void> deleteSelectedHabits() async {
    if (state.value!.selectedHabitIds.isEmpty) return;

    state = AsyncValue.data(state.value!.copyWith(isLoading: true));

    try {
      final selectedHabits = state.value!.archivedHabits.where((habit) => state.value!.selectedHabitIds.contains(habit.id)).toList();

      // Cancel notifications and delete each selected habit
      for (final habit in selectedHabits) {
        await ReminderService.cancelAllReminderNotifications(habit.reminderModel);
        await habitService.permanentlyDeleteHabit(habit.id);
      }

      // Remove deleted habits from the list
      final updatedHabits = state.value!.archivedHabits.where((habit) => !state.value!.selectedHabitIds.contains(habit.id)).toList();

      // Trigger a reschedule of all remaining notifications to ensure archived habits' notifications are removed
      await _rescheduleAllNotifications();

      state = AsyncValue.data(ArchivedHabitsState(
        archivedHabits: updatedHabits,
        isSelectionMode: false,
        selectedHabitIds: {},
        successMessage: LocaleKeys.archived_habits_delete_selected_success.tr(namedArgs: {'count': selectedHabits.length.toString()}),
      ));
    } catch (e) {
      state = AsyncValue.data(state.value!.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  void selectAllHabits() {
    final allHabitIds = state.value!.archivedHabits.map((habit) => habit.id).toSet();
    state = AsyncValue.data(state.value!.copyWith(selectedHabitIds: allHabitIds));
  }

  void clearSelection() {
    state = AsyncValue.data(state.value!.copyWith(selectedHabitIds: {}));
  }

  /// Reschedule all notifications to ensure archived habits' notifications are removed
  Future<void> _rescheduleAllNotifications() async {
    try {
      // Get all active habits and their reminders
      final activeHabits = await habitService.getHabits();
      final activeReminders = <ReminderModel>[];

      for (final habit in activeHabits) {
        if (habit.reminderModel != null && habit.reminderModel!.hasAnyReminders) {
          activeReminders.add(habit.reminderModel!);
        }
      }

      // Reschedule all notifications with only active habits (localized generic title/body)
      if (activeReminders.isNotEmpty) {
        await ReminderService.rescheduleAllNotifications(
          activeReminders,
          LocaleKeys.subscription_habitReminderTitle.tr(),
          LocaleKeys.habit_timeToCompleteYourHabit.tr(),
        );
        LogHelper.shared.debugPrint('Rescheduled notifications for ${activeReminders.length} active reminders');
      }
    } catch (e) {
      LogHelper.shared.debugPrint('Error rescheduling notifications: $e');
    }
  }
}
