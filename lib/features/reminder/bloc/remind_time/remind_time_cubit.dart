import '/core/core.dart';
import '../reminder/reminder_bloc.dart';

class RemindTimeCubit extends Cubit<DateTime?> {
  RemindTimeCubit() : super(null);

  void updateTime(DateTime? date, BuildContext context) {
    emit(date);

    context.read<ReminderBloc>().add(UpdateReminderTimeEvent(time: state));
  }

  void initializeTime(DateTime? date) {
    if (date == null) return;
    emit(state);
  }
}
