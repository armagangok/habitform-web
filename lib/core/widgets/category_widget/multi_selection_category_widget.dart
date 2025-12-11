import 'package:flutter/services.dart';
import 'package:habitform/core/core.dart';

class MultiCategoryWidget<T> extends StatefulWidget {
  final List<T> categories;
  final List<T>? initialSelection;
  final Function(List<T>) onCategorySelected;
  final String Function(T) categoryLabelBuilder;
  final Color? selection;
  final Color? unselectedColor;
  final double? borderRadius;

  const MultiCategoryWidget({
    super.key,
    required this.categories,
    this.initialSelection,
    required this.onCategorySelected,
    required this.categoryLabelBuilder,
    this.selection,
    this.unselectedColor,
    this.borderRadius,
  });

  @override
  MultiCategoryWidgetState<T> createState() => MultiCategoryWidgetState<T>();
}

class MultiCategoryWidgetState<T> extends State<MultiCategoryWidget<T>> {
  final Set<T> selectedItems = {};

  @override
  void initState() {
    super.initState();

    // Initialize with pre-selected items if provided
    if (widget.initialSelection != null && widget.initialSelection!.isNotEmpty) {
      selectedItems.addAll(widget.initialSelection!);

      // Notify parent about initial selection
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onCategorySelected(selectedItems.toList());
      });
    }
  }

  @override
  void didUpdateWidget(MultiCategoryWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update selected items if initialSelection changes
    if (widget.initialSelection != oldWidget.initialSelection) {
      setState(() {
        selectedItems.clear();
        if (widget.initialSelection != null) {
          selectedItems.addAll(widget.initialSelection!);
        }
      });

      // Notify parent about updated selection AFTER the build cycle
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onCategorySelected(selectedItems.toList());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        spacing: 5.0,
        runSpacing: 5.0,
        alignment: WrapAlignment.start,
        runAlignment: WrapAlignment.start,
        children: List.generate(
          widget.categories.length,
          (index) {
            final item = widget.categories[index];
            final isSelected = selectedItems.contains(item);
            return CustomButton(
              padding: EdgeInsets.zero,
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 90),
              onPressed: () {
                HapticFeedback.selectionClick();
                setState(() {
                  if (isSelected) {
                    selectedItems.remove(item);
                  } else {
                    selectedItems.add(item);
                  }
                });

                widget.onCategorySelected(selectedItems.toList());
              },
              child: AnimatedContainer(
                duration: 350.ms,
                curve: Curves.easeOutCubic,
                margin: EdgeInsets.zero,
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: isSelected ? widget.selection : widget.unselectedColor ?? context.selectionHandleColor.withValues(alpha: .25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  child: Text(
                    widget.categoryLabelBuilder(item),
                    style: context.bodySmall.copyWith(
                      color: isSelected ? Colors.white : context.bodySmall.color?.withValues(alpha: .72),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
