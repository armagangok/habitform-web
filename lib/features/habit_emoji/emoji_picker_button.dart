import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';

class EmojiPickerButton extends ConsumerWidget {
  final String? selectedIcon;
  final Function(String?)? onEmojiSelected;

  const EmojiPickerButton({
    super.key,
    this.selectedIcon,
    this.onEmojiSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayIcon = selectedIcon ?? '📝';

    return SizedBox(
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomButton(
            onPressed: () {
              context.hideKeyboard();

              navigator.navigateTo(
                path: KRoute.emojiPage,
                data: {
                  'selectedIcon': selectedIcon,
                  'onIconSelected': onEmojiSelected,
                },
              );
            },
            child: Container(
              height: 140,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.theme.scaffoldBackgroundColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey.withValues(alpha: .7),
                  width: .5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.25),
                    spreadRadius: 15,
                    blurRadius: 20,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Text(
                displayIcon,
                style: const TextStyle(fontSize: 80, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
