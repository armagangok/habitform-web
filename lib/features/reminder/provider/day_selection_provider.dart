import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/days/days_enum.dart';

final daySelectionProvider = AutoDisposeNotifierProvider<DaySelectionNotifier, List<Days>>(() {
  return DaySelectionNotifier();
});

class DaySelectionNotifier extends AutoDisposeNotifier<List<Days>> {
  @override
  List<Days> build() => [];

  void toggleDay(Days day) {
    final currentDays = state;
    if (currentDays.contains(day)) {
      state = currentDays.where((d) => d != day).toList();
    } else {
      state = [...currentDays, day];
    }
  }

  void setDays(List<Days> days) {
    state = days;
  }

  void clearDays() {
    state = [];
  }

  bool isDaySelected(Days day) {
    return state.contains(day);
  }
}
