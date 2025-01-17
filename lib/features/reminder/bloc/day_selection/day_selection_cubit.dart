import '/core/core.dart';
import '../../models/days/days_enum.dart';
import '../reminder/reminder_bloc.dart';

final allDays = Days.values;

class DaySelectionCubit extends Cubit<List<Days>> {
  DaySelectionCubit() : super([]);

  void initializeDays(List<Days> days) {
    emit(List.from(days));
  }

  void selectOneByOne(Days selectedDay) {
    final bool isSelected = state.contains(selectedDay);

    if (isSelected) {
      emit(List.from(state)..remove(selectedDay));
    } else {
      emit(List.from(state)..add(selectedDay));
    }
  }

  void selectAll() {
    emit(List.from(state..clear())..addAll(allDays));
  }

  void deselectAll(BuildContext context) {
    emit([]);
    // Tüm günleri ve zamanı sıfırla
    context.read<ReminderBloc>()
      ..add(UpdateReminderDaysEvent(days: null))
      ..add(UpdateReminderTimeEvent(time: null));
  }
}
