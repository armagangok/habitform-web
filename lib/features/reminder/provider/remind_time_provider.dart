import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'remind_time_state.dart';

final remindTimeProvider = NotifierProvider<RemindTimeNotifier, RemindTimeState>(() {
  return RemindTimeNotifier();
});

class RemindTimeNotifier extends Notifier<RemindTimeState> {
  @override
  RemindTimeState build() {
    return const RemindTimeState();
  }

  void setTime(DateTime? time) {
    state = state.copyWith(time: time);
  }

  void clearTime() {
    state = state.copyWith(time: null);
  }
}
