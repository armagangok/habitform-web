import '/core/core.dart';
import '/core/helpers/notifications/notification_helper.dart';
import '/core/widgets/flushbar_widget.dart';
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
    on<SetReminderEvent>((event, emit) {
      emit(ReminderSelectionState(reminder: event.reminder));
    });
  }

  void initializeReminderData(ReminderModel? initialReminder, BuildContext context) {
    final timeFromPicker = context.read<RemindTimeCubit>().state;

    if (initialReminder != null) {
      final selectedDays = initialReminder.days ?? [];
      final reminderTime = initialReminder.reminderTime;

      final reminder = initialReminder.copyWith(days: selectedDays, time: reminderTime ?? timeFromPicker);

      context.read<DaySelectionCubit>();

      context.read<DaySelectionCubit>().initializeDaySelection(selectedDays);
      context.read<RemindTimeCubit>().initializeTime(reminderTime);

      if (selectedDays.isEmpty) {
        context.read<PickerExtendCubit>().initialize(false);
      } else {
        context.read<PickerExtendCubit>().initialize(true);
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

  Future<void> scheduleReminder(String taskName, String body) async {
    final ReminderModel? reminderModel = state.reminder;
    try {
      if (reminderModel != null) {
        final uuid = UuidHelper.uidInt;
        final reminder = reminderModel.copyWith(id: uuid);
        await ReminderService.createReminderNotification(
          reminder,
          taskName,
          body,
        );
      }
    } catch (e, s) {
      LogHelper.shared.debugPrint('$e');
      LogHelper.shared.debugPrint('$s');
    }
  }

  Future<void> deleteReminder(ReminderModel? reminder, BuildContext context) async {
    try {
      await NotificationHelper.shared.cancelReminderNotifications(reminder);

      emit(ReminderSelectionState(reminder: null));

      context.read<PickerExtendCubit>().initialize(false);

      context.read<DaySelectionCubit>().initializeDaySelection([]);

      AppFlushbar.shared.successFlushbar("LocaleKeys.reminderDeletedSuccesfully.tr()");
    } catch (e) {
      AppFlushbar.shared.errorFlushbar("LocaleKeys.opsAnErrorOccured.tr()");
    }
  }

  void updateDaysInReminder(List<Days>? selectedDays) {
    final reminder = state.reminder?.copyWith(days: selectedDays);

    emit(ReminderSelectionState(reminder: reminder));
  }

  void updateReminderTime(DateTime? selectedTime) {
    final reminder = state.reminder?.copyWith(time: selectedTime);

    emit(ReminderSelectionState(reminder: reminder));
  }
}
