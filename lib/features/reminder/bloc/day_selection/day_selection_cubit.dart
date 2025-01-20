import '/core/core.dart';
import '../../models/days/days_enum.dart';
import '../picker_extend/picker_extend_cubit.dart';
import '../remind_time/remind_time_cubit.dart';
import '../reminder/reminder_bloc.dart';

final allDays = Days.values;

class DaySelectionCubit extends Cubit<List<Days>> {
  DaySelectionCubit() : super([]);

  void initializeDays(List<Days> days) {
    emit(List.from(days));
  }

  void selectOneByOne(Days selectedDay, BuildContext context) {
    final bool isSelected = state.contains(selectedDay);
    final List<Days> updatedDays = List.from(state);

    if (isSelected) {
      updatedDays.remove(selectedDay);
    } else {
      updatedDays.add(selectedDay);
    }

    emit(updatedDays);

    // İlk gün seçildiğinde default saat 12:00
    if (updatedDays.length == 1 && !isSelected) {
      context.read<RemindTimeCubit>().updateTime(DateTime.now().copyWith(hour: 12, minute: 0));
    }

    // Hiç gün seçili değilse zamanı sıfırla
    if (updatedDays.isEmpty) {
      context.read<RemindTimeCubit>().updateTime(null);
      context.read<PickerExtendCubit>().setValue(false);
    }

    // Update ReminderBloc with new days
    context.read<ReminderBloc>().add(UpdateReminderDaysEvent(days: updatedDays));
  }

  void selectAll() {
    final updatedDays = allDays.toList();
    emit(updatedDays);

    // İlk kez gün seçiliyorsa default saat 12:00
  }

  void deselectAll() {
    emit([]);
    // Tüm günleri ve zamanı sıfırla
  }
}
