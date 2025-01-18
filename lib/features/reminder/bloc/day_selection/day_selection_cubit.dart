import '../remind_time/remind_time_cubit.dart';
import '/core/core.dart';
import '../../models/days/days_enum.dart';
import '../reminder/reminder_bloc.dart';

final allDays = Days.values;

class DaySelectionCubit extends Cubit<List<Days>> {
  DaySelectionCubit() : super([]);

  void initializeDays(List<Days> days) {
    emit(List.from(days));
  }

  void selectOneByOne(Days selectedDay, BuildContext context) {
    final bool isSelected = state.contains(selectedDay);

    if (isSelected) {
      emit(List.from(state)..remove(selectedDay));
    } else {
      emit(List.from(state)..add(selectedDay));
      // Set default time to 14:00 when a day is selected
      context.read<RemindTimeCubit>().updateTime(DateTime.now().copyWith(hour: 12, minute: 0));
    }
  }

  void selectAll(BuildContext context) {
    emit(List.from(state..clear())..addAll(allDays));
    // Set default time to 14:00 when all days are selected
    context.read<RemindTimeCubit>().updateTime(DateTime.now().copyWith(hour: 12, minute: 0));
  }

  void deselectAll(BuildContext context) {
    emit([]);
    // Tüm günleri ve zamanı sıfırla
    context.read<ReminderBloc>()
      ..add(UpdateReminderDaysEvent(days: null))
      ..add(UpdateReminderTimeEvent(time: null));
  }
}
