import 'dart:core';

import '/core/core.dart';
import '/models/models.dart';
import '../../widgets/add_reminder.dart';

part 'reminder_time_state.dart';

class ReminderCubit extends Cubit<ReminderTimeState> {
  ReminderCubit() : super(ReminderTimeCubitInitial());

  final ReminderModel reminderModel = ReminderModel();

  final allDays = Days.values;
  Set<Days> selectedDays = {}; // Seçilen günler için bir Set kullanıyoruz.

  void updateReminderModel(ReminderModel? reminder) {
    debugPrint("${reminder?.reminderTime}");
    emit(
      SelectTimeCubitInitial(
        reminderModel: reminderModel.copyWith(
          days: reminder?.days,
          reminderTime: reminder?.reminderTime,
        ),
      ),
    );
  }
}
