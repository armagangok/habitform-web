import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

import '../core.dart';

class CustomEmojiPicker extends StatelessWidget {
  final void Function(Category?, Emoji)? onEmojiSelected;

  const CustomEmojiPicker({super.key, this.onEmojiSelected});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minSize: 0,
      child: Text(
        LocaleKeys.common_pick_your_emoji.tr(),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      onPressed: () => _showEmojiPicker(context),
    );
  }

  void _showEmojiPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          side: BorderSide(color: context.theme.dividerColor.withAlpha(75)),
        ),
        child: CupertinoPageScaffold(
          navigationBar: SheetHeader(
            title: LocaleKeys.common_pick_your_emoji.tr(),
          ),
          child: SafeArea(
            child: SizedBox(
              height: context.height(0.5),
              child: EmojiPicker(
                onEmojiSelected: onEmojiSelected,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
