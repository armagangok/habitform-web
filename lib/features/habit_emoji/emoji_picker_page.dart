import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import 'emoji_picker_widget.dart';
import 'provider/emoji_picker_provider.dart';
import 'provider/habit_emoji_provider.dart';

class EmojiPickerPage extends ConsumerStatefulWidget {
  final String? selectedIcon;
  final Function(String?)? onIconSelected;

  const EmojiPickerPage({
    super.key,
    this.selectedIcon,
    this.onIconSelected,
  });

  @override
  ConsumerState<EmojiPickerPage> createState() => _IconPickerPageState();
}

class _IconPickerPageState extends ConsumerState<EmojiPickerPage> {
  @override
  void initState() {
    super.initState();
    // Initialize the provider with any selected icon
    if (widget.selectedIcon != null) {
      // Delay the provider modification until after the widget tree is built
      Future(() {
        ref.read(emojiPickerProvider.notifier).initializeWithSelectedIcon(widget.selectedIcon);
      });
    }
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
                  color: context.theme.selectionHandleColor.withValues(alpha: 0.4),
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
                  color: context.theme.scaffoldBackgroundColor,
                  child: EmojiPicker(
                    onEmojiSelected: (category, emoji) {
                      final state = ref.read(emojiPickerProvider);

                      // If emoji is already selected, just close the picker
                      if (state.selectedEmoji == emoji.emoji) {
                        Navigator.pop(context);
                        return;
                      }

                      // Add the new emoji to custom category
                      ref.read(emojiPickerProvider.notifier).addCustomEmoji(emoji.emoji);

                      // Select the emoji
                      final customCategory = "Custom";
                      final customCategoryIndex = state.emojiCategories.keys.toList().indexOf(customCategory);
                      final customEmojis = state.emojiCategories[customCategory] ?? [];
                      final emojiIndex = customEmojis.indexOf(emoji.emoji);

                      // Select custom category
                      ref.read(emojiPickerProvider.notifier).selectCategory(customCategoryIndex);
                      // Select the emoji
                      ref.read(emojiPickerProvider.notifier).selectEmoji(emoji.emoji, emojiIndex);

                      if (widget.onIconSelected != null) {
                        widget.onIconSelected!(emoji.emoji);
                      } else {
                        ref.read(habitEmojiProvider.notifier).pickEmoji(emoji.emoji);
                      }

                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(emojiPickerProvider);

    return Stack(
      children: [
        CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text("Emoji"),
            previousPageTitle: LocaleKeys.common_back.tr(),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              child: Text(LocaleKeys.common_custom.tr()),
              onPressed: () => _showEmojiPicker(context),
            ),
          ),
          child: SafeArea(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                CupertinoListSection.insetGrouped(
                  header: Text("Pick your emoji"),
                  children: [
                    ColoredBox(
                      color: context.cupertinoTheme.scaffoldBackgroundColor,
                      child: IconPicker(
                        onIconSelected: (icon) {
                          // The icon selection is now handled by the provider,
                          // we just need to call our callback if provided
                          if (widget.onIconSelected != null) {
                            widget.onIconSelected!(icon);
                          } else {
                            ref.watch(habitEmojiProvider.notifier).pickEmoji(icon);
                          }
                        },
                        selectedIcon: state.selectedEmoji,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 120),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(bottom: 16) + EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  child: Text(
                    LocaleKeys.common_done.tr(),
                    style: context.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    final selectedIcon = state.selectedEmoji;
                    if (selectedIcon != null) {
                      if (widget.onIconSelected != null) {
                        widget.onIconSelected!(selectedIcon);
                      } else {
                        ref.watch(habitEmojiProvider.notifier).pickEmoji(selectedIcon);
                      }
                    }
                    navigator.pop();
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
