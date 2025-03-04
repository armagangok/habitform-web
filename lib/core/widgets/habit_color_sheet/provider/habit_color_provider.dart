import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final colorProvider = AutoDisposeNotifierProvider<HabitColorNotifier, Color?>(() {
  return HabitColorNotifier();
});

class HabitColorNotifier extends AutoDisposeNotifier<Color?> {
  @override
  Color? build() => null;

  void pickColor(Color? color) => state = color;
}
