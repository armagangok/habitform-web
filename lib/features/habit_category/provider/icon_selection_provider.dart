import 'package:flutter_riverpod/flutter_riverpod.dart';

final iconSelectionProvider = StateNotifierProvider.autoDispose<IconSelectionNotifier, String?>((ref) {
  return IconSelectionNotifier();
});

class IconSelectionNotifier extends StateNotifier<String?> {
  IconSelectionNotifier() : super(null);

  void selectIcon(String iconString) {
    state = iconString;
  }

  void reset() {
    state = null;
  }

  void setInitialIcon(String? icon) {
    state = icon;
  }
}
