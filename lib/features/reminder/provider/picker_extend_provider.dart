import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'picker_extend_state.dart';

final pickerExtendProvider = NotifierProvider<PickerExtendNotifier, PickerExtendState>(() {
  return PickerExtendNotifier();
});

class PickerExtendNotifier extends Notifier<PickerExtendState> {
  @override
  PickerExtendState build() {
    return const PickerExtendState();
  }

  void toggleExtend() {
    state = state.copyWith(
      isExtended: !state.isExtended,
    );
  }

  void extend() {
    state = state.copyWith(isExtended: true);
  }

  void collapse() {
    state = state.copyWith(isExtended: false);
  }
}
