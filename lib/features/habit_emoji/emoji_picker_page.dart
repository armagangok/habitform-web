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
    showCupertinoSheet(
      context: context,
      builder: (context) => CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          leading: CircularActionButton(
            onPressed: () => Navigator.pop(context),
            icon: CupertinoIcons.xmark,
          ),
          middle: Text(LocaleKeys.common_pick_your_emoji.tr()),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            onPressed: () => Navigator.pop(context),
            child: Text(LocaleKeys.common_ok.tr()),
          ),
          previousPageTitle: LocaleKeys.common_back.tr(),
        ),
        child: SafeArea(
          child: ListView(
            children: [
              //
              Material(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    brightness: context.theme.brightness,
                    scaffoldBackgroundColor: context.theme.scaffoldBackgroundColor,
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: context.theme.primaryColor,
                    ),
                    textTheme: Theme.of(context).textTheme.apply(
                          bodyColor: context.titleLarge.color,
                          displayColor: context.titleLarge.color,
                        ),
                  ),
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
                      final customCategory = LocaleKeys.emoji_picker_custom.tr();
                      final customCategoryIndex = state.emojiCategories.keys.toList().indexOf(customCategory);
                      final customEmojis = state.emojiCategories[customCategory] ?? [];
                      final emojiIndex = customEmojis.indexOf(emoji.emoji);

                      // Select custom category
                      ref.read(emojiPickerProvider.notifier).selectCategory(customCategoryIndex);
                      // Select the emoji
                      ref.read(emojiPickerProvider.notifier).selectEmoji(emoji.emoji, emojiIndex);

                      if (widget.onIconSelected != null) {
                        widget.onIconSelected!(emoji.emoji);
                      } else if (mounted) {
                        ref.read(habitEmojiProvider.notifier).pickEmoji(emoji.emoji);
                      }

                      Navigator.pop(context);
                    },
                    config: Config(
                      emojiViewConfig: EmojiViewConfig(
                        backgroundColor: context.theme.scaffoldBackgroundColor,
                      ),
                      skinToneConfig: const SkinToneConfig(enabled: true),
                      categoryViewConfig: CategoryViewConfig(
                        backgroundColor: context.theme.scaffoldBackgroundColor,
                        iconColor: context.hintColor,
                        iconColorSelected: context.theme.primaryColor,
                        indicatorColor: context.theme.primaryColor,
                      ),
                      bottomActionBarConfig: BottomActionBarConfig(
                        backgroundColor: context.theme.scaffoldBackgroundColor,
                        buttonColor: CupertinoColors.transparent,
                        buttonIconColor: context.theme.primaryContrastingColor.withValues(alpha: 1),
                        customBottomActionBar: (config, state, showSearchView) {
                          return Container(
                            height: 50,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: context.theme.scaffoldBackgroundColor,
                              border: Border(
                                top: BorderSide(
                                  color: context.hintColor.withValues(alpha: 0.2),
                                  width: 0.5,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Search button
                                CupertinoButton.filled(
                                  color: context.theme.primaryColor,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  onPressed: showSearchView,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        CupertinoIcons.search,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        LocaleKeys.common_search.tr(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      searchViewConfig: SearchViewConfig(
                        backgroundColor: context.theme.scaffoldBackgroundColor,
                        hintTextStyle: context.bodyMedium.copyWith(
                          color: context.hintColor,
                        ),
                      ),
                      checkPlatformCompatibility: true,
                    ),
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
            middle: Text(LocaleKeys.edit_habit_emoji.tr()),
            previousPageTitle: LocaleKeys.common_back.tr(),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              child: Text(LocaleKeys.common_custom.tr()),
              onPressed: () => _showEmojiPicker(context),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                CupertinoListSection.insetGrouped(
                  header: Text(LocaleKeys.emoji_picker_pick_your_emoji.tr()),
                  children: [
                    IconPicker(
                      onIconSelected: (icon) {
                        // The icon selection is now handled by the provider,
                        // we just need to call our callback if provided
                        if (widget.onIconSelected != null) {
                          widget.onIconSelected!(icon);
                        } else if (mounted) {
                          ref.watch(habitEmojiProvider.notifier).pickEmoji(icon);
                        }
                      },
                      selectedIcon: state.selectedEmoji,
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
                    if (widget.onIconSelected != null) {
                      widget.onIconSelected?.call(selectedIcon);
                    } else if (mounted) {
                      ref.watch(habitEmojiProvider.notifier).pickEmoji(selectedIcon);
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
