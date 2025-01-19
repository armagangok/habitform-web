import '/core/core.dart';
import '/core/helpers/notifications/notification_helper.dart';
import '../../../../core/widgets/flushbar_widget.dart';
import '../../models/days/days_enum.dart';
import '../../models/reminder/reminder_model.dart';
import '../../service/reminder_service.dart';

part 'reminder_event.dart';
part 'reminder_state.dart';

class ReminderBloc extends Bloc<ReminderEvent, ReminderState> {
  ReminderBloc() : super(ReminderStateInitial()) {
    on<InitializeReminderEvent>(_initializeReminderData);
    on<CancelReminderEvent>(cancelReminder);
    on<ScheduleReminderEvent>(scheduleReminder);
    on<UpdateReminderDaysEvent>(updateDays);
    on<UpdateReminderTimeEvent>(updateTime);
  }

  void _initializeReminderData(InitializeReminderEvent event, Emitter<ReminderState> emit) {
    final initialReminder = event.reminder;

    if (initialReminder != null) {
      // Eğer mevcut bir reminder varsa, aynı ID ile devam et
      emit(ReminderSelectionState(reminder: initialReminder));
    } else {
      // Yeni bir reminder oluştur
      final reminderModelToInitialize = ReminderModel(
        id: UuidHelper.uidInt,
        days: [],
        reminderTime: null,
      );
      emit(ReminderSelectionState(reminder: reminderModelToInitialize));
    }
  }

  Future<void> scheduleReminder(ScheduleReminderEvent event, Emitter<ReminderState> emit) async {
    final ReminderModel? reminder = state.reminder;
    try {
      if (reminder != null) {
        // Önce mevcut bildirimleri iptal et
        await NotificationHelper.shared.cancelReminderNotifications(reminder);

        // Eğer gün ve zaman seçili ise yeni bildirimi oluştur
        if (reminder.days != null && reminder.days!.isNotEmpty && reminder.reminderTime != null) {
          await ReminderService.createReminderNotification(
            reminder,
            event.title,
            event.body,
          );
        }
      }
    } catch (e, s) {
      LogHelper.shared.debugPrint('$e');
      LogHelper.shared.debugPrint('$s');
    }
  }

  Future<void> cancelReminder(CancelReminderEvent event, Emitter<ReminderState> emit) async {
    final reminder = event.reminder;

    try {
      if (reminder != null) {
        await NotificationHelper.shared.cancelReminderNotifications(reminder);
        // ID'yi koru ama diğer değerleri sıfırla
        final updatedReminder = reminder.copyWith(days: [], time: null);
        emit(ReminderSelectionState(reminder: updatedReminder));
        AppFlushbar.shared.successFlushbar("Reminder cancelled successfuly");
      }
    } catch (e) {
      LogHelper.shared.debugPrint('$e');
    }
  }

  Future<void> updateDays(UpdateReminderDaysEvent event, Emitter<ReminderState> emit) async {
    final currentReminder = state.reminder;

    if (event.days == null || event.days!.isEmpty) {
      // Günler boşaltılıyorsa, önce mevcut bildirimleri iptal et
      if (currentReminder != null) {
        await NotificationHelper.shared.cancelReminderNotifications(currentReminder);
      }

      // Zamanı da sıfırla ama ID'yi koru
      final updatedReminder = currentReminder?.copyWith(
            days: [],
            time: null,
          ) ??
          ReminderModel(
            id: UuidHelper.uidInt,
            days: [],
            reminderTime: null,
          );
      emit(ReminderSelectionState(reminder: updatedReminder));
      return;
    }

    // Eğer ilk defa gün seçiliyorsa ve zaman null ise, default saat 12:00
    final DateTime reminderTime = currentReminder?.reminderTime ?? DateTime.now().copyWith(hour: 12, minute: 0, second: 0);

    // Önce mevcut bildirimleri iptal et
    if (currentReminder != null) {
      await NotificationHelper.shared.cancelReminderNotifications(currentReminder);
    }

    final updatedReminder = currentReminder?.copyWith(
          days: event.days,
          time: reminderTime,
        ) ??
        ReminderModel(
          id: UuidHelper.uidInt,
          days: event.days,
          reminderTime: reminderTime,
        );

    // Yeni bildirimleri oluştur
    if (updatedReminder.days != null && updatedReminder.days!.isNotEmpty && updatedReminder.reminderTime != null) {
      await ReminderService.createReminderNotification(
        updatedReminder,
        "Habit Reminder",
        "Time to complete your habit!",
      );
    }

    emit(ReminderSelectionState(reminder: updatedReminder));
  }

  Future<void> updateTime(UpdateReminderTimeEvent event, Emitter<ReminderState> emit) async {
    final currentReminder = state.reminder;

    if (event.time == null) {
      // Zaman sıfırlanıyorsa, önce mevcut bildirimleri iptal et
      if (currentReminder != null) {
        await NotificationHelper.shared.cancelReminderNotifications(currentReminder);
      }

      // Günleri de sıfırla ama ID'yi koru
      final updatedReminder = ReminderModel(
        id: currentReminder?.id ?? UuidHelper.uidInt,
        days: [],
        reminderTime: null,
      );
      emit(ReminderSelectionState(reminder: updatedReminder));
      return;
    }

    // Önce mevcut bildirimleri iptal et
    if (currentReminder != null) {
      await NotificationHelper.shared.cancelReminderNotifications(currentReminder);
    }

    final updatedReminder = ReminderModel(
      id: currentReminder?.id ?? UuidHelper.uidInt,
      days: currentReminder?.days ?? [],
      reminderTime: event.time,
    );

    // Yeni bildirimleri oluştur
    if (updatedReminder.days != null && updatedReminder.days!.isNotEmpty && updatedReminder.reminderTime != null) {
      await ReminderService.createReminderNotification(
        updatedReminder,
        "Habit Reminder",
        "Time to complete your habit!",
      );
    }

    emit(ReminderSelectionState(reminder: updatedReminder));
  }
}
