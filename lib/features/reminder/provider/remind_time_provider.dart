import 'package:flutter_riverpod/flutter_riverpod.dart';

final remindTimeProvider = AutoDisposeNotifierProvider<RemindTimeNotifier, DateTime?>(() {
  return RemindTimeNotifier();
});

class RemindTimeNotifier extends AutoDisposeNotifier<DateTime?> {
  @override
  DateTime? build() => null;

  void setTime(DateTime? time) => state = time;

  void clearTime() => state = null;
}
