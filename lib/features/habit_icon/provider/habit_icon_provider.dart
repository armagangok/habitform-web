import 'package:flutter_riverpod/flutter_riverpod.dart';

final iconProvider = AutoDisposeNotifierProvider<HabitIconNotifier, String?>(() {
  return HabitIconNotifier();
});

class HabitIconNotifier extends AutoDisposeNotifier<String?> {
  @override
  String? build() => null;

  void pickIcon(String? iconData) {
    state = iconData;
  }
}
