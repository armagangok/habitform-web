import 'package:habitrise/core/widgets/custom_emoji_picker.dart';

import '/core/core.dart';

class IconPickerSheet extends StatefulWidget {
  final Function(String) onIconSelected;
  final String? selectedIcon;

  const IconPickerSheet({
    super.key,
    required this.onIconSelected,
    this.selectedIcon,
  });

  @override
  IconPickerSheetState createState() => IconPickerSheetState();
}

class IconPickerSheetState extends State<IconPickerSheet> with SingleTickerProviderStateMixin {
  // Initial selected category index
  int selectedCategoryIndex = 0;

  int? selectedIconIndex;

  late final AnimationController controller;

  // Define categories with emojis
  late Map<String, List<String>> emojiCategories;

  void _initializeCategories() {
    emojiCategories = {
      LocaleKeys.iconCategories_dailylife.tr(): [
        '🛏️',
        '🛌',
        '🪥',
        '🚿',
        '🧴',
        "🏋️‍♂️",
        "🏃🏻",
        "🚶🏻‍♂️",
        "🚶🏻",
        "🚶🏻‍♀️",
        '🪒',
        '👕',
        '👖',
        '👟',
        '💧',
        '🎛️',
        '🍳',
        '🍞',
        '🥚',
        '🥛',
        "📚",
        "🚴‍♂️",
        "🏊‍♂️",
        '☕',
        '🍽️',
        '🍕',
        '🍔',
        '🍜',
        '🍎',
        '🥤',
      ],
      LocaleKeys.iconCategories_sports.tr(): [
        "🚶🏻‍➡️",
        "🚶🏼‍♀️",
        "🚴🏻‍♀️",
        "🏃🏻",
        "🚴🏻‍♀️",
        "⛹️",
        "🏋️‍♂️",
        "🎾",
        "🏇🏻",
        "🏌",
        "🏐",
        "🏉",
        "🥏",
        "🥋",
        "🚶🏻‍♀️",
        "⚽",
        "🏀",
        "⚾",
        "🥎",
        "⛳",
        "🏈",
        "🎾",
        "🏐",
        "🏉",
        "🥏",
        "🥋",
        "🏎️",
        "🛹",
        "🏂",
        "🏄‍♂️",
        "🚣‍♂️",
        "🚴‍♂️",
        "🏊‍♂️",
        "🏃‍♂️",
        "🛶",
        "⛰️",
        "🥾",
        "🛂",
        "⛵",
      ],
      LocaleKeys.iconCategories_health.tr(): [
        "❤️",
        "🔥",
        "🩹",
        "🌡️",
        "❤️‍🩹",
        "💪",
        "💧",
        "💉",
        "⚕️",
        "🩺",
        "🩻",
        "🏥",
        "🧑🏻‍⚕️",
        "👩🏻‍⚕️",
        "👩🏼‍⚕️",
        "👨🏻‍⚕️",
        "👨🏼‍⚕️",
        "👨🏿‍⚕️",
        "👩🏿‍⚕️",
        "🚑",
        "⛑️",
      ],
      LocaleKeys.iconCategories_social.tr(): [
        "👥",
        "💬",
        "📧",
        "📞",
        "🌐",
        "🔔",
        "🤝",
        "👥",
        "🗣️",
        "📢",
        "🔗",
        "⭐",
        "💌",
        "🌍",
      ],
      LocaleKeys.iconCategories_nature.tr(): [
        "☁️",
        "☀️",
        "🌙",
        "🌬️",
        "🌨️",
        "🌱",
        "🐦",
        "🌳",
        "🌿",
        "🌸",
        "🌵",
        "🌴",
        "🍀",
        "🍁",
        "🍂",
        "🦣",
        "🦤",
        "🦥",
        "🐫",
        "🐪",
        "🐎",
        "🐐",
        "🐑",
        "🐏",
        "🐒",
        "🐓",
        "🐔",
        "🐕",
        "🐖",
        "🐗",
        "🐙",
        "🐚",
        "🌨️",
        "⛈️",
        "🌦️",
        "🏔️",
        "☄️",
        "⛰️",
        "🌬️",
        "🌪️",
      ],
      LocaleKeys.iconCategories_art.tr(): [
        "🎭",
        "✏️",
        "🖌️",
        "🖼️",
        "📷",
        "🎨",
        "🖼️",
        "✏️",
        "📷",
        "🧶",
        "🧵",
        "✍🏻",
        "👨🏻‍🎨",
        "👩🏼‍🎨",
        "🧑🏼‍🎨",
        "👨🏼‍🎨",
      ],
      LocaleKeys.iconCategories_business.tr(): [
        "💼",
        "📈",
        "📊",
        "📁",
        "📄",
        "💰",
        "💳",
        "📆",
        "👥",
        "📧",
        "📞",
        "🏢",
        "🕴🏻",
        "🖇️",
        "🗂️",
        "🗄️",
        "🗒️",
        "📤",
        "📥",
        "📊",
        "📉",
        "📈",
        "📇",
      ],
      LocaleKeys.iconCategories_studyandtask.tr(): [
        "📚",
        "📝",
        "📂",
        "⏱️",
        "📆",
        "💡",
        "📃",
        "❔",
        "📝",
        "⏱️",
        "📃",
        "📆",
        "📑",
        "📋",
        "☑️",
        "📎",
        "📁",
        "💼",
        "✅",
        "✔️",
        "📅",
        "🔔",
        "⏱️",
        "📝",
        "📆",
        "🙇🏻",
        "🙇🏻",
        "🙇🏻‍♀️",
        "🧑‍🎄",
        "📖",
        "🧑🏻‍💻",
        "👩🏻‍💻",
        "👨🏻‍💻",
        "🧑🏻‍🏫",
        "🧑🏻‍🏫",
        "👩🏻‍🏫",
        "👨🏻‍🏫",
        "✍🏻",
        "📌",
        "📍",
        "🖇️",
        "🔗",
        "🧷",
        "🔖",
        "🖍️",
        "🖌️",
        "🖊️",
        "🖋️",
        "🧮",
        "📊",
        "📅",
        "🗃️",
        "📇",
        "🗳️",
        "🗄️",
        "📋",
        "📁",
        "📂",
        "🗂️",
        "🗞️",
        "📰",
        "📓",
        "📔",
        "📒",
        "📕",
        "📗",
        "📘",
        "📙",
      ],
      LocaleKeys.iconCategories_science.tr(): [
        "🌡️",
        "🧪",
        "🧫",
        "🦠",
        "🧬",
        "🩸",
        "💉",
        "⚗️",
        "💊",
        "🩺",
        "🩻",
        "🩹",
        "🕳️",
        "🔬",
        "🔺",
        "💉",
        "🔭",
        "🪐",
        "🧑🏻‍🔬",
        "👩🏻‍🔬",
        "👨🏻‍🔬",
        "🥼",
        "🌑",
      ],
      LocaleKeys.iconCategories_gardenandyard.tr(): [
        "🌱",
        "🌳",
        "🌾",
        "🌼",
        "🌍",
        "🌹",
        "⛲️",
        "🪴",
        "👨🏻‍🌾",
        "👩🏻‍🌾",
        "🧑🏻‍🌾",
        "🌿",
        "🌹",
      ],
      LocaleKeys.iconCategories_pets.tr(): [
        "🐾",
        "🐶",
        "🦴",
        "🐩",
        "🐩",
        "🐈‍⬛",
        "🐈",
        "🦮",
        "🐕‍🦺",
        "🐱",
        "🐶",
        "🐐",
        "🐑",
        "🐰",
        "🐹",
        "🐟",
        "🐂",
        "🦎",
        "🚗",
        "🦦",
        "🐦",
      ],
      "Custom": [], // Custom emojiler EmojiPicker'dan yüklenecek
    };

    // Eğer seçili icon Custom kategorisindeyse listeye ekle
    if (widget.selectedIcon != null && !emojiCategories.values.any((list) => list.contains(widget.selectedIcon))) {
      emojiCategories["Custom"]!.add(widget.selectedIcon!);
    }
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this);
    _initializeCategories();
    if (widget.selectedIcon != null) {
      // Tüm kategorilerde ara (Custom dahil)
      for (var i = 0; i < emojiCategories.length; i++) {
        final category = emojiCategories.values.elementAt(i);
        final iconIndex = category.indexOf(widget.selectedIcon!);
        if (iconIndex != -1) {
          selectedCategoryIndex = i;
          selectedIconIndex = iconIndex;
          break;
        }
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Extract the keys as category names
    List<String> categoryNames = emojiCategories.keys.toList();

    return Stack(
      children: [
        ListView(
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            CategoryWidget(
              categories: categoryNames,
              initialSelectedIndex: selectedCategoryIndex,
              onCategorySelected: (int selectedCategory) {
                controller.forward(from: 0);
                selectedIconIndex = null;
                setState(() {
                  selectedCategoryIndex = selectedCategory;
                });
              },
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 120,
              child: GridView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                scrollDirection: Axis.horizontal,
                itemCount: emojiCategories[categoryNames[selectedCategoryIndex]]!.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 15,
                ),
                itemBuilder: (context, index) {
                  final iconData = emojiCategories[categoryNames[selectedCategoryIndex]]![index];

                  return CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      setState(() {
                        selectedIconIndex = index;
                      });

                      widget.onIconSelected(iconData);
                    },
                    child: Card(
                      elevation: .25,
                      color: index == selectedIconIndex ? context.primary.withAlpha(100) : null,
                      child: Padding(
                        padding: const EdgeInsets.all(2.5),
                        child: Center(
                          child: FittedBox(
                            child: Text(
                              iconData,
                              textAlign: TextAlign.center,
                              style: context.titleLarge?.copyWith(fontSize: 40),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ).animate(controller: controller).fadeIn(duration: 500.ms),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 10,
                  top: 5,
                ),
                child: CustomEmojiPicker(
                  onEmojiSelected: (category, emoji) {
                    // Yeni emojiyi Custom kategorisine ekle
                    final customEmojis = emojiCategories["Custom"] ?? [];
                    if (!customEmojis.contains(emoji.emoji)) {
                      setState(() {
                        customEmojis.add(emoji.emoji);
                        emojiCategories["Custom"] = customEmojis;
                      });
                    }

                    widget.onIconSelected(emoji.emoji);

                    // Custom kategorisini seç
                    final customCategoryIndex = emojiCategories.keys.toList().indexOf("Custom");
                    setState(() {
                      selectedCategoryIndex = customCategoryIndex;
                    });

                    navigator.pop();
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
