import '/core/core.dart';
import '../../core/widgets/widgets.dart';

class ColorPickerWidget extends StatefulWidget {
  final Function(Color) onColorSelected;
  final Color? selectedColor;

  const ColorPickerWidget({
    super.key,
    required this.onColorSelected,
    this.selectedColor,
  });

  @override
  ColorPickerWidgetState createState() => ColorPickerWidgetState();
}

class ColorPickerWidgetState extends State<ColorPickerWidget> with SingleTickerProviderStateMixin {
  // Define color categories with colors in hex format
  final Map<String, List<Color>> colorCategories = {
    LocaleKeys.colors_blue.tr(): [
      Colors.blue.shade300,
      Colors.blue.shade400,
      Colors.blue.shade500,
      Colors.blue.shade600,
      Colors.blue.shade700,
      Colors.blue.shade800,
      Colors.blue.shade900,
    ],
    LocaleKeys.colors_lightBlue.tr(): [
      Colors.lightBlue.shade300,
      Colors.lightBlue.shade400,
      Colors.lightBlue.shade500,
      Colors.lightBlue.shade600,
      Colors.lightBlue.shade700,
      Colors.lightBlue.shade800,
      Colors.lightBlue.shade900,
    ],
    LocaleKeys.colors_indigo.tr(): [
      Colors.indigo.shade300,
      Colors.indigo.shade400,
      Colors.indigo.shade500,
      Colors.indigo.shade600,
      Colors.indigo.shade700,
      Colors.indigo.shade800,
      Colors.indigo.shade900,
    ],
    LocaleKeys.colors_red.tr(): [
      Colors.red.shade300,
      Colors.red.shade400,
      Colors.red.shade500,
      Colors.red.shade600,
      Colors.red.shade700,
      Colors.red.shade800,
      Colors.red.shade900,
    ],
    LocaleKeys.colors_orange.tr(): [
      Colors.orange.shade300,
      Colors.orange.shade400,
      Colors.orange.shade500,
      Colors.orange.shade600,
      Colors.orange.shade700,
      Colors.orange.shade800,
      Colors.orange.shade900,
    ],
    LocaleKeys.colors_deepOrange.tr(): [
      Colors.deepOrange.shade300,
      Colors.deepOrange.shade400,
      Colors.deepOrange.shade500,
      Colors.deepOrange.shade600,
      Colors.deepOrange.shade700,
      Colors.deepOrange.shade800,
      Colors.deepOrange.shade900,
    ],
    LocaleKeys.colors_amber.tr(): [
      Colors.amber.shade300,
      Colors.amber.shade400,
      Colors.amber.shade500,
      Colors.amber.shade600,
      Colors.amber.shade700,
      Colors.amber.shade800,
      Colors.amber.shade900,
    ],
    LocaleKeys.colors_yellow.tr(): [
      Colors.yellow.shade300,
      Colors.yellow.shade400,
      Colors.yellow.shade500,
      Colors.yellow.shade600,
      Colors.yellow.shade700,
      Colors.yellowAccent.shade400,
      Colors.yellowAccent.shade700,
    ],
    LocaleKeys.colors_Lime.tr(): [
      Colors.lime.shade300,
      Colors.lime.shade400,
      Colors.lime.shade500,
      Colors.lime.shade600,
      Colors.lime.shade700,
      Colors.lime.shade800,
      Colors.lime.shade900,
    ],
    LocaleKeys.colors_green.tr(): [
      Colors.green.shade300,
      Colors.green.shade400,
      Colors.green.shade500,
      Colors.green.shade600,
      Colors.green.shade700,
      Colors.green.shade800,
      Colors.green.shade900,
    ],
    LocaleKeys.colors_cyan.tr(): [
      Colors.cyan.shade300,
      Colors.cyan.shade400,
      Colors.cyan.shade500,
      Colors.cyan.shade600,
      Colors.cyan.shade700,
      Colors.cyan.shade800,
      Colors.cyan.shade900,
    ],
    LocaleKeys.colors_teal.tr(): [
      Colors.teal.shade300,
      Colors.teal.shade400,
      Colors.teal.shade500,
      Colors.teal.shade600,
      Colors.teal.shade700,
      Colors.teal.shade800,
      Colors.teal.shade900,
    ],
    LocaleKeys.colors_purple.tr(): [
      Colors.purple.shade300,
      Colors.purple.shade400,
      Colors.purple.shade500,
      Colors.purple.shade600,
      Colors.purple.shade700,
      Colors.purple.shade800,
      Colors.purple.shade900,
    ],
    LocaleKeys.colors_deepPurple.tr(): [
      Colors.deepPurple.shade300,
      Colors.deepPurple.shade400,
      Colors.deepPurple.shade500,
      Colors.deepPurple.shade600,
      Colors.deepPurple.shade700,
      Colors.deepPurple.shade800,
      Colors.deepPurple.shade900,
    ],
    LocaleKeys.colors_brown.tr(): [
      Colors.brown.shade300,
      Colors.brown.shade400,
      Colors.brown.shade500,
      Colors.brown.shade600,
      Colors.brown.shade700,
      Colors.brown.shade800,
      Colors.brown.shade900,
    ],
    LocaleKeys.colors_pink.tr(): [
      Colors.pink.shade300,
      Colors.pink.shade400,
      Colors.pink.shade500,
      Colors.pink.shade600,
      Colors.pink.shade700,
      Colors.pink.shade800,
      Colors.pink.shade900,
    ],
    LocaleKeys.colors_grey.tr(): [
      Colors.grey.shade300,
      Colors.grey.shade400,
      Colors.grey.shade500,
      Colors.grey.shade600,
      Colors.grey.shade700,
      Colors.grey.shade800,
      Colors.grey.shade900,
    ],
    LocaleKeys.colors_blueGrey.tr(): [
      Colors.blueGrey.shade300,
      Colors.blueGrey.shade400,
      Colors.blueGrey.shade500,
      Colors.blueGrey.shade600,
      Colors.blueGrey.shade700,
      Colors.blueGrey.shade800,
      Colors.blueGrey.shade900,
    ],
  };

  int selectedCategoryIndex = 0;
  int? selectedColorIndex;
  Color? actuallySelectedColor; // Track the actually selected color

  late final AnimationController controller;

  Color customColorForPicker = Colors.blue.shade500;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this);
    if (widget.selectedColor != null) {
      // Find the category and index of the selected color
      for (var i = 0; i < colorCategories.length; i++) {
        final category = colorCategories.values.elementAt(i);
        final colorIndex = category.indexOf(widget.selectedColor!);
        if (colorIndex != -1) {
          selectedCategoryIndex = i;
          selectedColorIndex = colorIndex;
          customColorForPicker = widget.selectedColor!;
          actuallySelectedColor = widget.selectedColor!;
          break;
        }
      }
    }
  }

  @override
  void didUpdateWidget(ColorPickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedColor != oldWidget.selectedColor) {
      _updateSelectedColor();
    }
  }

  void _updateSelectedColor() {
    if (widget.selectedColor != null) {
      // Find the category and index of the selected color
      for (var i = 0; i < colorCategories.length; i++) {
        final category = colorCategories.values.elementAt(i);
        final colorIndex = category.indexOf(widget.selectedColor!);
        if (colorIndex != -1) {
          setState(() {
            selectedCategoryIndex = i;
            selectedColorIndex = colorIndex;
            customColorForPicker = widget.selectedColor!;
            actuallySelectedColor = widget.selectedColor!;
          });
          break;
        }
      }
    } else {
      // Reset selection if no color is provided
      setState(() {
        selectedColorIndex = null;
        actuallySelectedColor = null;
        customColorForPicker = Colors.blue.shade500;
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> categoryNames = colorCategories.keys.toList();

    // Ekran genişliğine göre uygun boyut hesaplama
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    // Sabit item boyutu belirle
    final itemSize = isTablet ? 40.0 : 55.0;

    // Grid için sütun sayısı
    final crossAxisCount = isTablet ? 10 : 5;

    return CustomSection(
      text: LocaleKeys.colors_color.tr(),
      child: ListView(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CategoryWidget(
              customColor: customColorForPicker,
              categories: categoryNames,
              initialSelectedIndex: selectedCategoryIndex,
              onCategorySelected: (val) {
                controller.forward(from: 0);
                setState(() {
                  selectedCategoryIndex = val;
                  final newCategoryColors = colorCategories[categoryNames[val]]!;

                  // Check if the actually selected color exists in the new category
                  if (actuallySelectedColor != null) {
                    final colorIndex = newCategoryColors.indexOf(actuallySelectedColor!);
                    if (colorIndex != -1) {
                      // Keep the same color if it exists in the new category
                      selectedColorIndex = colorIndex;
                      customColorForPicker = actuallySelectedColor!;
                    } else {
                      // Reset selection if color doesn't exist in new category
                      selectedColorIndex = null;
                      customColorForPicker = newCategoryColors[5];
                    }
                  } else {
                    // No color selected yet, use default
                    selectedColorIndex = null;
                    customColorForPicker = newCategoryColors[5];
                  }
                });
              },
            ),
          ),
          SizedBox(height: 10),
          GridView.builder(
            physics: ClampingScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.all(8),
            itemCount: colorCategories[categoryNames[selectedCategoryIndex]]!.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1, // Kare şeklinde itemler
            ),
            itemBuilder: (context, index) {
              Color color = colorCategories[categoryNames[selectedCategoryIndex]]![index];
              return SizedBox(
                width: itemSize,
                height: itemSize,
                child: _buildColorItem(color, index, itemSize),
              );
            },
          ).animate(controller: controller).fadeIn(duration: 500.ms),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildColorItem(Color color, int index, double size) {
    return CustomButton(
      onPressed: () {
        setState(() {
          selectedColorIndex = index;
          actuallySelectedColor = color;
          customColorForPicker = color;
          widget.onColorSelected(color);
        });
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: index == selectedColorIndex
              ? Icon(
                  CupertinoIcons.checkmark_alt,
                  size: size * 0.45,
                  color: color.colorRegardingToBrightness,
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
