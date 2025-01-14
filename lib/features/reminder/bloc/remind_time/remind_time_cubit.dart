import '/core/core.dart';
import '../reminder/reminder_bloc.dart';

class RemindTimeCubit extends Cubit<DateTime> {
  RemindTimeCubit() : super(DateTime.now());

  void updateTime(DateTime date, BuildContext context) {
    emit(date);

    context.read<ReminderBloc>().updateReminderTime(state);
  }

  void initializeTime(DateTime? date) {
    if (date == null) return;
    emit(state);
  }
}
