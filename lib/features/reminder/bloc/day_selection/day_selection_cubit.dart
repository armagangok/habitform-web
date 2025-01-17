import '/core/core.dart';
import '../../models/days/days_enum.dart';

final allDays = Days.values;

class DaySelectionCubit extends Cubit<List<Days>> {
  DaySelectionCubit() : super([]);

  void selectOneByOne(Days selectedDay) {
    final bool isSelected = state.contains(selectedDay);

    if (isSelected) {
      // Yeni bir liste oluştur ve mevcut listedeki seçilen günü çıkar
      emit(List.from(state)..remove(selectedDay));
    } else {
      // Yeni bir liste oluştur ve seçilen günü ekle
      emit(List.from(state)..add(selectedDay));
    }
  }

  void selectAll() {
    emit(List.from(state..clear())..addAll(allDays));
  }

  void deselectAll() {
    emit(List.from(state..clear()));
  }
}
