import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '../../core/widgets/widgets.dart';
import 'provider/emoji_picker_provider.dart';

class IconPicker extends ConsumerStatefulWidget {
  final Function(String) onIconSelected;
  final String? selectedIcon;

  const IconPicker({
    super.key,
    required this.onIconSelected,
    this.selectedIcon,
  });

  @override
  ConsumerState<IconPicker> createState() => IconPickerState();
}

class IconPickerState extends ConsumerState<IconPicker> with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  final ScrollController _gridScrollController = ScrollController();
  final Map<int, GlobalKey> _iconKeys = {};

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this);

    // Initialize the provider with selected icon
    if (widget.selectedIcon != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(emojiPickerProvider.notifier).initializeWithSelectedIcon(widget.selectedIcon);
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    _gridScrollController.dispose();
    super.dispose();
  }

  void _scrollSelectedIconIntoView(int? selectedIconIndex) {
    if (!mounted || selectedIconIndex == null || !_iconKeys.containsKey(selectedIconIndex)) {
      return;
    }

    final context = _iconKeys[selectedIconIndex]?.currentContext;
    if (context == null || !_gridScrollController.hasClients) {
      return;
    }

    // Delay very slightly to ensure rendering is complete
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!mounted || !context.mounted) return;

      try {
        // İkonun pozisyonunu ve boyutunu al
        if (!context.mounted) return;
        final RenderBox box = context.findRenderObject() as RenderBox;
        final size = box.size;
        final position = box.localToGlobal(Offset.zero);

        // GridView'ın pozisyonunu ve boyutunu al
        final RenderBox gridBox = _gridScrollController.position.context.storageContext.findRenderObject() as RenderBox;
        final gridPosition = gridBox.localToGlobal(Offset.zero);
        final gridWidth = gridBox.size.width;

        // İkonun GridView içindeki göreceli pozisyonunu hesapla
        final relativePosition = position.dx - gridPosition.dx;

        // İkonun GridView'ın görünür alanında olup olmadığını kontrol et
        final isFullyVisible = relativePosition >= 0 && relativePosition + size.width <= gridWidth;

        // İkon tamamen görünür değilse, kaydır
        if (!isFullyVisible) {
          // İkonun GridView içindeki hedef pozisyonunu hesapla (ortada olacak şekilde)
          final targetPosition = _gridScrollController.offset + relativePosition - (gridWidth / 2) + (size.width / 2);

          // Hedef pozisyonu sınırla (minimum 0, maksimum scrollExtent)
          final clampedPosition = targetPosition.clamp(0.0, _gridScrollController.position.maxScrollExtent);

          // Ani bir kaydırma yapalım
          _gridScrollController.jumpTo(clampedPosition);
        }
      } catch (e) {
        LogHelper.shared.debugPrint(e.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(emojiPickerProvider);
    final notifier = ref.read(emojiPickerProvider.notifier);

    // Extract the keys as category names
    List<String> categoryNames = state.emojiCategories.keys.toList();

    // Seçili kategorideki ikonlar
    final currentCategoryIcons = state.emojiCategories[categoryNames[state.selectedCategoryIndex]] ?? [];

    // İkon tuşlarını güncelle - sadece gerektiğinde
    if (_iconKeys.length != currentCategoryIcons.length) {
      _iconKeys.clear();
      for (int i = 0; i < currentCategoryIcons.length; i++) {
        _iconKeys[i] = GlobalKey();
      }
    }

    // Scroll to selected icon when it changes
    if (state.selectedEmojiIndex != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollSelectedIconIntoView(state.selectedEmojiIndex);
      });
    }

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              CategoryWidget(
                categories: categoryNames,
                initialSelectedIndex: state.selectedCategoryIndex,
                onCategorySelected: (int selectedCategory) {
                  if (selectedCategory == state.selectedCategoryIndex) return;

                  controller.forward(from: 0);
                  // Update category in provider
                  notifier.selectCategory(selectedCategory);

                  // Kategori değiştiğinde GridView'ı başa sar
                  if (_gridScrollController.hasClients) {
                    _gridScrollController.jumpTo(0);
                  }

                  // Yeni kategori için tuşları güncelle
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _iconKeys.clear();
                      });
                    }
                  });
                },
              ),
              const SizedBox(height: 10),
              SizedBox(
                child: GridView.builder(
                  controller: _gridScrollController,
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.vertical,
                  physics: const BouncingScrollPhysics(),

                  cacheExtent: 1000, // Daha fazla öğeyi önbelleğe al
                  itemCount: currentCategoryIcons.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final iconData = currentCategoryIcons[index];
                    final isSelected = iconData == state.selectedEmoji;

                    // Performans için key kullanımını optimize et
                    if (!_iconKeys.containsKey(index)) {
                      _iconKeys[index] = GlobalKey();
                    }

                    return CustomButton(
                      key: _iconKeys[index],
                      onPressed: () {
                        // Eğer zaten seçiliyse, tekrar işlem yapma
                        if (state.selectedEmoji == iconData) return;

                        HapticFeedback.selectionClick();

                        // Update in provider
                        notifier.selectEmoji(iconData, index);

                        widget.onIconSelected(iconData);

                        // Seçilen ikonu görünür yap - ama sadece görünür değilse
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            _scrollSelectedIconIntoView(index);
                          }
                        });
                      },
                      child: CupertinoCard(
                        elevation: .25,
                        color: isSelected ? context.primary : context.selectionHandleColor.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(8),
                        child: Center(
                          child: FittedBox(
                            child: Text(
                              iconData,
                              textAlign: TextAlign.center,
                              style: context.titleLarge.copyWith(fontSize: 44),
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ).animate(controller: controller).fadeIn(duration: 350.ms),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
