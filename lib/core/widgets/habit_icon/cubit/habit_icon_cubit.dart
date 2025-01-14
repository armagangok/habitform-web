import '../../../core.dart';

part 'habit_icon_state.dart';

class HabitEmojiCubit extends Cubit<HabitIconState> {
  HabitEmojiCubit() : super(HabitIconInitial(emoji: null));

  void pickIcon(String? iconData) {
    emit(HabitIconPicked(emoji: iconData));
  }
}
