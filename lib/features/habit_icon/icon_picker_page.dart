import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '../../core/widgets/custom_emoji_picker.dart';
import 'icon_picker_widget.dart';
import 'provider/habit_icon_provider.dart';
import 'provider/icon_picker_provider.dart';

class IconPickerPage extends ConsumerStatefulWidget {
  final String? selectedIcon;

  const IconPickerPage({
    super.key,
    this.selectedIcon,
  });

  @override
  ConsumerState<IconPickerPage> createState() => _IconPickerPageState();
}

class _IconPickerPageState extends ConsumerState<IconPickerPage> {
  @override
  void initState() {
    super.initState();
    // Initialize the provider with any selected icon
    if (widget.selectedIcon != null) {
      ref.read(iconPickerProvider.notifier).initializeWithSelectedIcon(widget.selectedIcon);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(iconPickerProvider);

    return Stack(
      children: [
        CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text("Icon Picker"),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              child: Text(LocaleKeys.common_done.tr()),
              onPressed: () {
                final selectedIcon = state.selectedIcon;
                if (selectedIcon != null) {
                  ref.watch(iconProvider.notifier).pickIcon(selectedIcon);
                }
                navigator.pop();
              },
            ),
          ),
          child: ListView(
            padding: EdgeInsets.all(16),
            children: [
              IconPicker(
                onIconSelected: (icon) {
                  // The icon selection is now handled by the provider,
                  // we just need to call our callback if provided
                  ref.watch(iconProvider.notifier).pickIcon(icon);
                },
                selectedIcon: state.selectedIcon,
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: CustomEmojiPicker(
            onEmojiSelected: (category, emoji) {
              // If emoji is already selected, just close the picker
              if (state.selectedIcon == emoji.emoji) {
                navigator.pop();
                return;
              }

              // Add the new emoji to custom category
              ref.read(iconPickerProvider.notifier).addCustomIcon(emoji.emoji);

              // Select the emoji
              final customCategory = "Custom";
              final customCategoryIndex = state.emojiCategories.keys.toList().indexOf(customCategory);
              final customEmojis = state.emojiCategories[customCategory] ?? [];
              final emojiIndex = customEmojis.indexOf(emoji.emoji);

              // Select custom category
              ref.read(iconPickerProvider.notifier).selectCategory(customCategoryIndex);
              // Select the emoji
              ref.read(iconPickerProvider.notifier).selectIcon(emoji.emoji, emojiIndex);

              ref.watch(iconProvider.notifier).pickIcon(emoji.emoji);

              navigator.pop();
            },
          ),
        ),
      ],
    );
  }
}
