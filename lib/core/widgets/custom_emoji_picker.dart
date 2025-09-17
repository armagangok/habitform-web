import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

import '../core.dart';

class CustomEmojiPicker extends StatelessWidget {
  final void Function(Category?, Emoji)? onEmojiSelected;
  final Color? backgroundColor;
  final Color? indicatorColor;

  const CustomEmojiPicker({
    super.key,
    this.onEmojiSelected,
    this.backgroundColor,
    this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: 16) + EdgeInsets.symmetric(horizontal: 32),
        child: SizedBox(
          width: double.infinity,
          child: CupertinoButton.filled(
            child: Text(
              LocaleKeys.common_pick_your_emoji.tr(),
              style: context.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            onPressed: () => _showEmojiPicker(context),
          ),
        ),
      ),
    );
  }

  void _showEmojiPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => AnimatedPadding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        child: Container(
          height: context.height(0.70),
          decoration: BoxDecoration(
            color: context.theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 6,
                  width: 40,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: context.selectionHandleColor.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        LocaleKeys.common_pick_your_emoji.tr(),
                        style: context.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          LocaleKeys.common_ok.tr(),
                          style: context.titleSmall.copyWith(
                            color: context.theme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: EmojiPicker(
                      onEmojiSelected: onEmojiSelected,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
