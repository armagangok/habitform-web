import '/core/core.dart';
import '/core/helpers/notifications/notification_helper.dart';
import '../../../../core/widgets/flushbar_widget.dart';
import '../../models/days/days_enum.dart';
import '../../models/reminder/reminder_model.dart';
import '../../service/reminder_service.dart';
import '../day_selection/day_selection_cubit.dart';
import '../picker_extend/picker_extend_cubit.dart';
import '../remind_time/remind_time_cubit.dart';

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
    final timeFromPicker = event.context.read<RemindTimeCubit>().state;
    final initialReminder = event.reminder;

    if (initialReminder != null) {
      final selectedDays = initialReminder.days ?? [];
      final reminderTime = initialReminder.reminderTime;

      final reminder = initialReminder.copyWith(days: selectedDays, time: reminderTime ?? timeFromPicker);

      event.context.read<DaySelectionCubit>().initializeDaySelection(selectedDays);
      event. context.read<RemindTimeCubit>().initializeTime(reminderTime);

      if (selectedDays.isEmpty) {
        event.context.read<PickerExtendCubit>().initialize(false);
      } else {
        event. context.read<PickerExtendCubit>().initialize(true);
      }

      emit(ReminderSelectionState(reminder: reminder));
    } else {
      final reminderModelToInitialize = ReminderModel(
        id: UuidHelper.uidInt,
        days: [],
        reminderTime: timeFromPicker,
      );

      emit(ReminderSelectionState(reminder: reminderModelToInitialize));

      LogHelper.shared.debugPrint('$reminderModelToInitialize');
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

  Future<void> updateDays(UpdateReminderDaysEvent event, Emitter<ReminderState> emit) async {}

  Future<void> updateTime(UpdateReminderTimeEvent event, Emitter<ReminderState> emit) async {}
}
