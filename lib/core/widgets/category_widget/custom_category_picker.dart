import 'package:flutter/services.dart';

import '../../core.dart';

class CustomCategoryWidget<T> extends StatefulWidget {
  final List<T> categories;
  final Function(T) onCategorySelected;
  final Color? customColor;
  final String Function(T) categoryLabelBuilder;
  final T selectedCategory;
  final double? borderRadius;

  const CustomCategoryWidget({
    super.key,
    required this.categories,
    required this.onCategorySelected,
    this.customColor,
    required this.categoryLabelBuilder,
    required this.selectedCategory,
    this.borderRadius,
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
          minimumSize: Size.zero,
          pressedOpacity: .8,
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 90),
          color: Colors.transparent,
          onPressed: () {
            HapticFeedback.selectionClick();
            setState(() {
              selectedCategory = category;
            });
            widget.onCategorySelected(category);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            child: Text(
              widget.categoryLabelBuilder(category),
              style: context.bodySmall.copyWith(
                color: isSelected ? Colors.white : context.bodySmall.color?.withValues(alpha: .72),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
