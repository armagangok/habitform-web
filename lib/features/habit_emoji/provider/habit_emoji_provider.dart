import 'package:flutter_riverpod/flutter_riverpod.dart';

final habitEmojiProvider = AutoDisposeNotifierProvider<HabitEmojiNotifier, String?>(() {
  return HabitEmojiNotifier();
});

class HabitEmojiNotifier extends AutoDisposeNotifier<String?> {
  @override
  String? build() => null;

  void pickEmoji(String? emoji) {
    state = emoji;
  }
}
