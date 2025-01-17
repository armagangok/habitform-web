import '/core/core.dart';

class RemindTimeCubit extends Cubit<DateTime?> {
  RemindTimeCubit() : super(DateTime.now().copyWith(hour: 12, minute: 0, second: 0));

  void updateTime(DateTime? date) {
    emit(date);
  }

  void initializeTime(DateTime? date) {
    if (date == null) return;
    emit(date);
  }
}
