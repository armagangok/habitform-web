import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/features/habit_category/model/habit_category_model.dart';
import '/features/habit_category/provider/habit_category_provider.dart';
import '../../../core/widgets/custom_list_tile.dart';
import '../provider/habit_category_button_provider.dart';
import '../util/icon_util.dart';

class CategoryPickerButton extends ConsumerWidget {
  final Widget? header;

  const CategoryPickerButton({super.key, this.header});

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
    final selectedCategoryIds = ref.watch(categoryButtonProvider);

    return categoryState.when(
      data: (state) {
        // Find selected categories based on categoryButtonProvider
        final selectedCategories = selectedCategoryIds != null ? state.categories.where((category) => selectedCategoryIds.contains(category.id)).toList() : <HabitCategory>[];

        return CustomSection(
          header: header,
          child: CustomListTile(
            onTap: () {
              context.hideKeyboard();
              navigator.navigateTo(path: KRoute.habitCategoryPage);
            },
            trailing: const CupertinoListTileChevron(),
            titleWidget: selectedCategories.isEmpty
                ? Text(LocaleKeys.habit_category_select_categories.tr())
                : Wrap(
                    runAlignment: WrapAlignment.start,
                    alignment: WrapAlignment.start,
                    spacing: 8,
                    runSpacing: 8,
                    children: selectedCategories.map((category) {
                      final iconData = category.icon != null ? CategoryIconUtil.getIconFromString(category.icon!) : _getCategoryIcon(category.name);

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                            const SizedBox(width: 6),
                            Text(
                              category.getDisplayName(),
                              style: context.bodySmall.copyWith(
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
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
