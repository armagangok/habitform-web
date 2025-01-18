import '/core/core.dart';

class RemindTimeCubit extends Cubit<DateTime?> {
  RemindTimeCubit() : super(null);

  void updateTime(DateTime? date) {
    emit(date);
  }

  void initializeTime(DateTime? date) {
    if (date == null) return;
    emit(date);
  }
}
