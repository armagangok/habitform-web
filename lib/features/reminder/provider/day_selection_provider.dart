import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/days/days_enum.dart';
import 'day_selection_state.dart';

final daySelectionProvider = NotifierProvider<DaySelectionNotifier, DaySelectionState>(() {
  return DaySelectionNotifier();
});

class DaySelectionNotifier extends Notifier<DaySelectionState> {
  @override
  DaySelectionState build() {
    return const DaySelectionState();
  }

  void toggleDay(Days day) {
    final currentDays = state.selectedDays;
    if (currentDays.contains(day)) {
      state = state.copyWith(
        selectedDays: currentDays.where((d) => d != day).toList(),
      );
    } else {
      state = state.copyWith(
        selectedDays: [...currentDays, day],
      );
    }
  }

  void setDays(List<Days> days) {
    state = state.copyWith(selectedDays: days);
  }

  void clearDays() {
    state = state.copyWith(selectedDays: []);
  }

  bool isDaySelected(Days day) {
    return state.selectedDays.contains(day);
  }
}
