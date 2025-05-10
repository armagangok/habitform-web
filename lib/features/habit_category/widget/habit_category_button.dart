import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/core/widgets/custom_list_tile.dart';
import '/features/habit_category/provider/habit_category_provider.dart';
import '/features/habit_category/util/icon_util.dart';
import '../provider/habit_category_button_provider.dart';

class CategoryPickerButton extends ConsumerWidget {
  const CategoryPickerButton({super.key});

  // Helper method to get FontAwesome icon based on category name
  static IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'art':
        return FontAwesomeIcons.paintbrush;
      case 'finances':
        return FontAwesomeIcons.moneyBill;
      case 'sports':
        return FontAwesomeIcons.dumbbell;
      case 'health':
        return FontAwesomeIcons.solidHeart;
      case 'nutrition':
        return FontAwesomeIcons.utensils;
      case 'social':
        return FontAwesomeIcons.userGroup;
      case 'study':
        return FontAwesomeIcons.book;
      case 'work':
        return FontAwesomeIcons.briefcase;
      case 'morning':
        return FontAwesomeIcons.solidSun;
      case 'dailylife':
        return FontAwesomeIcons.houseUser;
      case 'evening':
        return FontAwesomeIcons.solidMoon;
      default:
        return FontAwesomeIcons.tag;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryState = ref.watch(habitCategoryProvider);

    return categoryState.when(
      data: (state) {
        // Find selected categories
        final selectedCategories = state.categories.where((category) => state.selectedCategoryIds.contains(category.id)).toList();

        return CustomHeader(
          text: "CATEGORY",
          child: CustomListTile(
            onPressed: () {
              context.hideKeyboard();
              final selectedCategoryIds = selectedCategories.map((category) => category.id).toList();
              ref.read(categoryButtonProvider.notifier).setSelectedCategories(selectedCategoryIds);
              navigator.navigateTo(path: KRoute.habitCategoryPage);
            },
            trailing: CupertinoListTileChevron(),
            child: selectedCategories.isEmpty
                ? Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.tag,
                        size: 16,
                        color: context.primary,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Select categories',
                        style: context.bodyMedium?.copyWith(
                          color: context.primary,
                        ),
                      ),
                    ],
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: selectedCategories.map((category) {
                      final iconData = category.icon != null ? CategoryIconUtil.getIconFromString(category.icon!) : _getCategoryIcon(category.name);

                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: context.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: context.primary.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FaIcon(
                              iconData,
                              size: 14,
                              color: context.primary,
                            ),
                            SizedBox(width: 6),
                            Text(
                              category.name,
                              style: context.bodySmall?.copyWith(
                                color: context.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
        );
      },
      loading: () => SizedBox.shrink(),
      error: (_, __) => SizedBox.shrink(),
    );
  }
}
