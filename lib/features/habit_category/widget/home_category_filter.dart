import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '../../home/provider/home_provider.dart';
import '../provider/habit_category_provider.dart';
import '../util/icon_util.dart';

/// Widget for filtering habits by category on the home screen
class HomeCategoryFilter extends ConsumerWidget {
  const HomeCategoryFilter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryState = ref.watch(habitCategoryProvider);
    final habitsAsync = ref.watch(homeProvider);

    // Get only categories that are used in habits
    final usedCategoryIds = <String>{};
    if (habitsAsync.hasValue) {
      for (final habit in habitsAsync.value!.habits) {
        usedCategoryIds.addAll(habit.categoryIds);
      }
    }

    return Material(
      color: Colors.transparent,
      child: categoryState.when(
        data: (state) {
          // Filter to only show categories that are used in habits
          final usedCategories = state.categories.where((cat) => usedCategoryIds.contains(cat.id)).toList();

          if (usedCategories.isEmpty) {
            return const SizedBox.shrink(); // No categories to show
          }

          // Single row ListView
          return SizedBox(
            height: 40,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 16),
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: usedCategories.map((category) {
                  final isSelected = state.selectedCategoryIds.contains(category.id);
                  final IconData iconData = category.icon != null ? CategoryIconUtil.getIconFromString(category.icon!) : _getCategoryIcon(category.name);

                  final selectedColor = isSelected ? context.cupertinoTheme.primaryColor : context.theme.primaryContrastingColor;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: CustomButton(
                      onPressed: () {
                        ref.read(habitCategoryProvider.notifier).toggleCategorySelection(category.id);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? context.cupertinoTheme.primaryColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selectedColor,
                            width: .7,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FaIcon(
                              iconData,
                              size: 13,
                              color: isSelected ? Colors.white : context.bodyMedium.color,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              category.getDisplayName(),
                              style: context.bodySmall.copyWith(
                                color: isSelected ? Colors.white : context.bodyMedium.color,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
        loading: () => const Center(child: CupertinoActivityIndicator()),
        error: (error, stack) => Center(
          child: Text(LocaleKeys.habit_category_error.tr(args: [error.toString()]), style: context.bodyMedium),
        ),
      ),
    );
  }

  // Helper method to get FontAwesome icon based on category name
  IconData _getCategoryIcon(String categoryName) {
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
}
