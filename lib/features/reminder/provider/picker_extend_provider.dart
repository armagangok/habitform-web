import 'package:flutter_riverpod/flutter_riverpod.dart';

final pickerExtendProvider = AutoDisposeNotifierProvider<PickerExtendNotifier, bool>(() {
  return PickerExtendNotifier();
});

class PickerExtendNotifier extends AutoDisposeNotifier<bool> {
  @override
  bool build() {
    return false;
  }

  void toggleExtend() {
    state = !state;
  }

  void extend() => state = true;

  void collapse() => state = false;
}
