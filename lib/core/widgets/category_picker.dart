import 'package:flutter/services.dart';
import 'package:habitrise/core/core.dart';

class MultiCategoryWidget extends StatefulWidget {
  final List<String> categories;
  final Function(List<int>) onCategorySelected;
  final Color? customColor;

  const MultiCategoryWidget({
    super.key,
    required this.categories,
    required this.onCategorySelected,
    this.customColor,
  });

  @override
  MultiCategoryWidgetState createState() => MultiCategoryWidgetState();
}

class MultiCategoryWidgetState extends State<MultiCategoryWidget> {
  final Set<int> selectedIndexes = {}; // Çoklu seçim için set kullanıyoruz.

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 5.0, // Kategoriler arasındaki yatay boşluk
      runSpacing: 5.0, // Satırlar arasındaki dikey boşluk
      children: List.generate(
        widget.categories.length,
        (index) {
          final isSelected = selectedIndexes.contains(index);
          return CupertinoButton(
            minSize: 0,
            pressedOpacity: .8,
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(8),
            color: Colors.transparent,
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() {
                if (isSelected) {
                  selectedIndexes.remove(index); // Eğer seçiliyse çıkar
                } else {
                  selectedIndexes.add(index); // Eğer seçili değilse ekle
                }
              });

              widget.onCategorySelected(selectedIndexes.toList());
            },
            child: Card(
              surfaceTintColor: Colors.transparent,
              elevation: .1,
              color: isSelected ? widget.customColor ?? context.primary : null,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                child: Text(
                  widget.categories[index],
                  style: context.bodySmall?.copyWith(
                    color: isSelected ? Colors.white : context.bodySmall?.color?.withValues(alpha: .72),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CategoryWidget extends StatefulWidget {
  final List<String> categories;
  final Function(int) onCategorySelected;

  final Color? customColor;

  const CategoryWidget({
    super.key,
    required this.categories,
    required this.onCategorySelected,
    this.customColor,
  });

  @override
  CategoryWidgetState createState() => CategoryWidgetState();
}

class CategoryWidgetState extends State<CategoryWidget> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4, // Kategoriler arasındaki yatay boşluk
      runSpacing: 4, // Satırlar arasındaki dikey boşluk
      children: List.generate(
        widget.categories.length,
        (index) {
          return CupertinoButton(
            minSize: 0,
            pressedOpacity: .8,
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(8),
            color: Colors.transparent,
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() {
                selectedIndex = index;
              });

              widget.onCategorySelected(index);
            },
            child: Card(
              elevation: .1,
              color: selectedIndex == index ? widget.customColor ?? context.primary : null,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 5.5),
                child: AnimatedDefaultTextStyle(
                  duration: 300.ms, // Smooth animation duration
                  curve: Curves.easeInOut, // Curve for the animation
                  style: TextStyle(
                    fontSize: selectedIndex == index ? 13 : 13, // Change size with weight if desired
                    fontWeight: selectedIndex == index ? FontWeight.w600 : FontWeight.normal,
                    color: selectedIndex == index ? Colors.white : context.bodySmall?.color?.withValues(alpha: .72),
                  ),

                  child: Text(widget.categories[index]),
                ).animate(effects: []),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CustomCategoryWidget<T> extends StatefulWidget {
  final List<T> categories;
  final Function(T) onCategorySelected;
  final Color? customColor;
  final String Function(T) categoryLabelBuilder;
  final T selectedCategory;

  const CustomCategoryWidget({
    super.key,
    required this.categories,
    required this.onCategorySelected,
    this.customColor,
    required this.categoryLabelBuilder,
    required this.selectedCategory,
  });

  @override
  CustomCategoryWidgetState<T> createState() => CustomCategoryWidgetState<T>();
}

class CustomCategoryWidgetState<T> extends State<CustomCategoryWidget<T>> {
  T? selectedCategory;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        selectedCategory = widget.selectedCategory;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0, // Horizontal spacing between categories
      runSpacing: 8.0, // Vertical spacing between rows

      children: widget.categories.map((category) {
        final isSelected = category == selectedCategory;
        return CupertinoButton(
          minSize: 0,
          pressedOpacity: .8,
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(8),
          color: Colors.transparent,
          onPressed: () {
            HapticFeedback.selectionClick();
            setState(() {
              selectedCategory = category;
            });
            widget.onCategorySelected(category);
          },
          child: Card(
            color: isSelected ? widget.customColor ?? context.primary : null,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              child: Text(
                widget.categoryLabelBuilder(category),
                style: context.bodySmall?.copyWith(
                  color: isSelected ? Colors.white : context.bodySmall?.color?.withValues(alpha: .72),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
