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
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: context.height(0.49),
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
                  color: context.theme.dividerColor.withValues(alpha: 0.4),
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
                      style: context.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minSize: 0,
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        LocaleKeys.common_ok.tr(),
                        style: context.titleSmall?.copyWith(
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
                    // config: Config(
                    //   checkPlatformCompatibility: true,
                    //   emojiViewConfig: EmojiViewConfig(
                    //     emojiSizeMax: 28 * (foundation.defaultTargetPlatform == foundation.TargetPlatform.iOS ? 1.20 : 1.0),
                    //     backgroundColor: backgroundColor ?? context.theme.scaffoldBackgroundColor,
                    //     columns: 8,
                    //     verticalSpacing: 0,
                    //     horizontalSpacing: 0,
                    //     gridPadding: EdgeInsets.zero,
                    //     recentsLimit: 28,
                    //     replaceEmojiOnLimitExceed: true,
                    //     loadingIndicator: const CupertinoActivityIndicator(),
                    //     noRecents: Text(
                    //       LocaleKeys.common_none.tr(),
                    //       style: context.bodySmall?.copyWith(
                    //         fontSize: 13,
                    //         color: context.theme.hintColor,
                    //       ),
                    //     ),
                    //     buttonMode: ButtonMode.CUPERTINO,
                    //   ),
                    //   skinToneConfig: SkinToneConfig(
                    //     dialogBackgroundColor: backgroundColor ?? context.theme.scaffoldBackgroundColor,
                    //     indicatorColor: context.theme.dividerColor,
                    //   ),
                    //   categoryViewConfig: CategoryViewConfig(
                    //     tabBarHeight: 40,
                    //     indicatorColor: indicatorColor ?? context.theme.primaryColor,
                    //     iconColor: context.theme.iconTheme.color ?? CupertinoColors.systemGrey,
                    //     iconColorSelected: context.theme.primaryColor,
                    //     backspaceColor: context.theme.iconTheme.color ?? CupertinoColors.systemGrey,
                    //     backgroundColor: backgroundColor ?? context.theme.scaffoldBackgroundColor,
                    //     categoryIcons: const CategoryIcons(),
                    //     tabIndicatorAnimDuration: const Duration(milliseconds: 300),
                    //   ),
                    //   bottomActionBarConfig: const BottomActionBarConfig(
                    //     showBackspaceButton: false,
                    //     showSearchViewButton: true,
                    //     backgroundColor: Colors.transparent,
                    //   ),
                    //   searchViewConfig: SearchViewConfig(
                    //     backgroundColor: backgroundColor ?? context.theme.scaffoldBackgroundColor,
                    //     buttonIconColor: context.theme.iconTheme.color ?? CupertinoColors.systemGrey,
                    //   ),
                    // ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
