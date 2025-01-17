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
      final selectedDays = initialReminder.days ?? [];
      final reminderTime = initialReminder.reminderTime;
      final reminder = initialReminder.copyWith(days: selectedDays, time: reminderTime);
      emit(ReminderSelectionState(reminder: reminder));
    } else {
      final reminderModelToInitialize = ReminderModel(
        id: UuidHelper.uidInt,
        days: [],
        reminderTime: DateTime.now().copyWith(hour: 12, minute: 0, second: 0),
      );
      emit(ReminderSelectionState(reminder: reminderModelToInitialize));
    }
  }

  Future<void> scheduleReminder(ScheduleReminderEvent event, Emitter<ReminderState> emit) async {
    final ReminderModel? reminder = state.reminder;
    try {
      if (reminder != null) {
        ReminderService.cancelReminderNotification(reminder.id);
        await ReminderService.createReminderNotification(
          reminder,
          event.title,
          event.body,
        );
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
        final cancelState = CancelReminderState();
        emit(cancelState);
        AppFlushbar.shared.successFlushbar("Reminder cancelled successfuly");
      }
    } catch (e) {
      LogHelper.shared.debugPrint('$e');
    }
  }

  Future<void> updateDays(UpdateReminderDaysEvent event, Emitter<ReminderState> emit) async {
    if (event.days == null || event.days!.isEmpty) {
      emit(ReminderStateInitial());
      return;
    }

    final currentReminder = state.reminder ??
        ReminderModel(
          id: UuidHelper.uidInt,
          days: [],
          reminderTime: DateTime.now().copyWith(hour: 12, minute: 0, second: 0),
        );

    final updatedReminder = currentReminder.copyWith(days: event.days);
    emit(ReminderSelectionState(reminder: updatedReminder));
  }

  Future<void> updateTime(UpdateReminderTimeEvent event, Emitter<ReminderState> emit) async {
    if (event.time == null) {
      emit(ReminderStateInitial());
      return;
    }

    final currentReminder = state.reminder ??
        ReminderModel(
          id: UuidHelper.uidInt,
          days: [],
          reminderTime: event.time,
        );

    final updatedReminder = currentReminder.copyWith(time: event.time);
    emit(ReminderSelectionState(reminder: updatedReminder));
  }
}
