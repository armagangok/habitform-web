import 'package:flutter/services.dart';
import 'package:habitrise/core/core.dart';

class CategoryWidget extends StatefulWidget {
  final List<String> categories;
  final Function(int) onCategorySelected;
  final Color? customColor;
  final int? initialSelectedIndex;

  const CategoryWidget({
    super.key,
    required this.categories,
    required this.onCategorySelected,
    this.customColor,
    this.initialSelectedIndex,
  });

  @override
  CategoryWidgetState createState() => CategoryWidgetState();
}

class CategoryWidgetState extends State<CategoryWidget> {
  late int selectedIndex;
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _itemKeys = {};

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialSelectedIndex ?? 0;
    _initializeKeys();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scrollSelectedItemIntoView();
    });
  }

  void _initializeKeys() {
    for (int i = 0; i < widget.categories.length; i++) {
      _itemKeys[i] = GlobalKey();
    }
  }

  @override
  void didUpdateWidget(CategoryWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSelectedIndex != widget.initialSelectedIndex) {
      selectedIndex = widget.initialSelectedIndex ?? 0;
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollSelectedItemIntoView();
        });
      }
    }
  }

  void _scrollSelectedItemIntoView() {
    if (!mounted || !_itemKeys.containsKey(selectedIndex)) return;

    final context = _itemKeys[selectedIndex]?.currentContext;
    if (context == null || !_scrollController.hasClients) return;

    try {
      // Get the RenderBox of the selected item
      final RenderBox box = context.findRenderObject() as RenderBox;
      final size = box.size;

      // Get the position of the selected item
      final position = box.localToGlobal(Offset.zero);

      // Get the position of the ScrollView
      final RenderBox scrollBox = _scrollController.position.context.storageContext.findRenderObject() as RenderBox;
      final scrollPosition = scrollBox.localToGlobal(Offset.zero);

      // Calculate the scroll view's width
      final scrollViewWidth = scrollBox.size.width;

      // Calculate the relative position of the item within the scroll view
      final relativePosition = position.dx - scrollPosition.dx;

      // Check if the item is fully visible
      final isFullyVisible = relativePosition >= 0 && relativePosition + size.width <= scrollViewWidth;

      // Only scroll if the item is not fully visible or not centered
      if (!isFullyVisible || (relativePosition + (size.width / 2) - (scrollViewWidth / 2)).abs() > 10) {
        // Calculate the target scroll position to center the item
        final targetScrollOffset = _scrollController.offset + relativePosition - (scrollViewWidth / 2) + (size.width / 2);

        // Ensure the target offset is within bounds
        final boundedOffset = targetScrollOffset.clamp(0.0, _scrollController.position.maxScrollExtent);

        // Animate to the target position
        _scrollController.animateTo(
          boundedOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    } catch (e) {
      // Handle any errors that might occur during scrolling
      LogHelper.shared.debugPrint('Error scrolling to selected item: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double horizontalPadding = 8.0;
        const double verticalPadding = 4.0;
        const double spacing = 8.0;
        const double minItemHeight = 32.0;

        final totalItems = widget.categories.length;
        final itemsPerRow = (totalItems / 2).ceil();

        final firstRow = widget.categories.take(itemsPerRow).toList();
        final secondRow = widget.categories.skip(itemsPerRow).toList();

        return IntrinsicHeight(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRow(firstRow, 0, minItemHeight, horizontalPadding, verticalPadding, spacing),
                SizedBox(height: spacing),
                _buildRow(secondRow, itemsPerRow, minItemHeight, horizontalPadding, verticalPadding, spacing),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRow(List<String> items, int startIndex, double minItemHeight, double horizontalPadding, double verticalPadding, double spacing) {
    return IntrinsicHeight(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: items.asMap().entries.map((entry) {
          final index = startIndex + entry.key;
          final text = entry.value;

          return Padding(
            key: _itemKeys[index],
            padding: EdgeInsets.only(right: entry.key == items.length - 1 ? 0 : 5),
            child: CupertinoButton(
              minSize: 0,
              pressedOpacity: .8,
              padding: EdgeInsets.zero,
              borderRadius: BorderRadius.circular(8),
              color: Colors.transparent,
              onPressed: () {
                HapticFeedback.selectionClick();
                setState(() => selectedIndex = index);
                widget.onCategorySelected(index);

                // Delay scrolling slightly to ensure UI updates first
                Future.delayed(Duration(milliseconds: 50), () {
                  if (mounted) _scrollSelectedItemIntoView();
                });
              },
              child: Card(
                elevation: .1,
                color: selectedIndex == index ? widget.customColor ?? context.cupertinoTheme.primaryColor.withValues(alpha: .9) : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: selectedIndex == index ? Colors.transparent : Theme.of(context).primaryColor.withValues(alpha: .2),
                    width: 1,
                  ),
                ),
                child: IntrinsicWidth(
                  child: Container(
                    constraints: BoxConstraints(minHeight: minItemHeight),
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalPadding,
                    ),
                    child: Center(
                      child: Text(
                        text,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selectedIndex == index
                              ? (widget.customColor ??
                                      context.cupertinoTheme.primaryColor.withValues(
                                        alpha: .9,
                                      ))
                                  .colorRegardingToBrightness
                              : context.primary.withValues(alpha: .75),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
