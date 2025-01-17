import '/core/core.dart';
import '../reminder/reminder_bloc.dart';

class RemindTimeCubit extends Cubit<DateTime?> {
  RemindTimeCubit() : super(DateTime.now().copyWith(hour: 12, minute: 0, second: 0));

  void updateTime(DateTime? date, BuildContext context) {
    emit(date);

    context.read<ReminderBloc>().add(UpdateReminderTimeEvent(time: state));
  }

  void initializeTime(DateTime? date) {
    if (date == null) return;
    emit(state);
  }
}
