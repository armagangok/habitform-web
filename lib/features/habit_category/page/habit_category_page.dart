import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/features/habit_category/model/habit_category_model.dart';
import '/features/habit_category/provider/category_selection_provider.dart';
import '/features/habit_category/provider/habit_category_provider.dart';
import '/features/habit_category/provider/icon_selection_provider.dart';
import '/features/habit_category/util/icon_util.dart';
import '../provider/habit_category_button_provider.dart';

class HabitCategoryPage extends ConsumerStatefulWidget {
  final List<String>? selectedCategoryIds;
  final bool allowMultiple;

  const HabitCategoryPage({
    super.key,
    this.selectedCategoryIds,
    this.allowMultiple = true,
  });

  @override
  ConsumerState<HabitCategoryPage> createState() => _HabitCategoryPageState();
}

class _HabitCategoryPageState extends ConsumerState<HabitCategoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize local selection with current selected categories
      final selectedIds = ref.read(categoryButtonProvider)?.toSet() ?? widget.selectedCategoryIds?.toSet() ?? {};
      ref.read(categorySelectionProvider.notifier).setCategories(selectedIds);
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(habitCategoryProvider);
    final localSelectedIds = ref.watch(categorySelectionProvider);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(LocaleKeys.habit_category_title.tr()),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.add, size: 20),
              SizedBox(width: 4),
              Text(LocaleKeys.habit_category_new.tr()),
            ],
          ),
          onPressed: () => _showCreateCategoryDialog(),
        ),
      ),
      child: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: categoryState.when(
                data: (state) => _buildCategoryList(state, localSelectedIds),
                loading: () => const Center(child: CupertinoActivityIndicator()),
                error: (error, _) => Center(
                  child: Text(LocaleKeys.habit_category_error_loading_categories.tr(args: [error.toString()]), style: context.bodyMedium),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: CupertinoButton.filled(
                      onPressed: () {
                        // Update categoryButtonProvider for UI (this is for the category selection button)
                        ref.watch(categoryButtonProvider.notifier).setSelectedCategories(localSelectedIds.toList());

                        // Clear category selection in habitCategoryProvider to prevent auto-filtering on home page
                        ref.watch(habitCategoryProvider.notifier).setSelectedCategories({});

                        navigator.pop();
                      },
                      child: Text(
                        LocaleKeys.common_done.tr(),
                        style: context.titleLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(HabitCategoryState state, Set<String> localSelectedIds) {
    final defaultCategories = state.categories.where((cat) => cat.isDefault).toList();
    final customCategories = state.categories.where((cat) => !cat.isDefault).toList();

    return ListView(
      padding: EdgeInsets.only(bottom: 80),
      children: [
        if (defaultCategories.isNotEmpty) ...[
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: defaultCategories.map((category) => _buildCategoryChip(category, localSelectedIds)).toList(),
          ),
          SizedBox(height: 24),
        ],
        if (customCategories.isNotEmpty) ...[
          _buildSectionHeader(LocaleKeys.habit_category_custom_categories.tr()),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: customCategories.map((category) => _buildDeletableCategoryChip(category, localSelectedIds)).toList(),
          ),
          SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: context.bodySmall.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildCategoryChip(HabitCategory category, Set<String> localSelectedIds) {
    final bool isSelected = localSelectedIds.contains(category.id);
    final iconData = category.icon != null ? CategoryIconUtil.getIconFromString(category.icon!) : null;

    return CustomButton(
      onPressed: () {
        ref.read(categorySelectionProvider.notifier).toggleCategory(category.id);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? context.cupertinoTheme.primaryColor : context.selectionHandleColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconData != null) ...[
              FaIcon(
                iconData,
                size: 16,
                color: isSelected ? Colors.white : context.primaryContrastingColor.withValues(alpha: isSelected ? 1.0 : 0.5),
              ),
              SizedBox(width: 6),
            ],
            Text(
              category.getDisplayName(),
              style: context.bodySmall.copyWith(
                color: isSelected ? Colors.white : null,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeletableCategoryChip(HabitCategory category, Set<String> localSelectedIds) {
    return GestureDetector(
      onLongPress: () => _showDeleteCategoryConfirmation(category),
      child: _buildCategoryChip(category, localSelectedIds),
    );
  }

  void _showDeleteCategoryConfirmation(HabitCategory category) {
    showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: Text(LocaleKeys.habit_category_category_options.tr()),
        content: Text(LocaleKeys.habit_category_category_options_message.tr(namedArgs: {'categoryName': category.getDisplayName()})),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(dialogContext);
              _showEditCategoryDialog(category);
            },
            child: Text(LocaleKeys.habit_category_edit.tr()),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ref.read(habitCategoryProvider.notifier).deleteCategory(category.id);
            },
            child: Text(LocaleKeys.habit_category_delete.tr()),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(LocaleKeys.common_cancel.tr()),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(HabitCategory category) {
    final nameController = TextEditingController(text: category.name);

    // Initialize the icon selection provider with the category's icon
    ref.read(iconSelectionProvider.notifier).setInitialIcon(category.icon);

    showCupertinoModalPopup(
      context: context,
      builder: (context) => Consumer(
        builder: (context, widgetRef, _) {
          final selectedIcon = widgetRef.watch(iconSelectionProvider);

          return CupertinoActionSheet(
            title: Text(LocaleKeys.habit_category_edit_category.tr()),
            message: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: CupertinoTextField(
                    controller: nameController,
                    placeholder: LocaleKeys.habit_category_enter_category_name.tr(),
                    padding: const EdgeInsets.all(12),
                    autofocus: true,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: CupertinoColors.systemBackground,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 230,
                  child: GridView.builder(
                    itemCount: CategoryIconUtil.getIconList().length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                    ),
                    itemBuilder: (context, index) {
                      final iconData = CategoryIconUtil.getIconList()[index];
                      final iconString = CategoryIconUtil.getIconString(iconData);
                      final isSelected = selectedIcon == iconString;

                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              widgetRef.read(iconSelectionProvider.notifier).selectIcon(iconString);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected ? CupertinoColors.activeBlue.withOpacity(0.2) : null,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.systemGrey3,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Center(
                                child: FaIcon(
                                  iconData,
                                  size: 20,
                                  color: isSelected ? CupertinoColors.activeBlue : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            actions: [
              CupertinoActionSheetAction(
                onPressed: () {
                  final name = nameController.text.trim();
                  if (name.isNotEmpty && selectedIcon != null) {
                    ref.read(habitCategoryProvider.notifier).updateCategory(
                          category.id,
                          name,
                          selectedIcon,
                        );
                    Navigator.pop(context);
                  }
                },
                child: Text(LocaleKeys.habit_category_save.tr()),
              ),
              CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () => Navigator.pop(context),
                child: Text(LocaleKeys.common_cancel.tr()),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCreateCategoryDialog() {
    final nameController = TextEditingController();

    // Reset the icon selection provider
    ref.read(iconSelectionProvider.notifier).reset();

    showCupertinoModalPopup(
      context: context,
      builder: (context) => Consumer(
        builder: (context, widgetRef, _) {
          final selectedIcon = widgetRef.watch(iconSelectionProvider);

          return CupertinoActionSheet(
            title: Text(LocaleKeys.habit_category_create_category.tr()),
            message: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: CupertinoTextField(
                    controller: nameController,
                    placeholder: LocaleKeys.habit_category_enter_category_name.tr(),
                    padding: const EdgeInsets.all(12),
                    autofocus: true,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: CupertinoColors.systemBackground,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 230,
                  child: GridView.builder(
                    itemCount: CategoryIconUtil.getIconList().length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                    ),
                    itemBuilder: (context, index) {
                      final iconData = CategoryIconUtil.getIconList()[index];
                      final iconString = CategoryIconUtil.getIconString(iconData);
                      final isSelected = selectedIcon == iconString;

                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              widgetRef.read(iconSelectionProvider.notifier).selectIcon(iconString);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected ? CupertinoColors.activeBlue.withOpacity(0.2) : null,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.systemGrey3,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Center(
                                child: FaIcon(
                                  iconData,
                                  size: 20,
                                  color: isSelected ? CupertinoColors.activeBlue : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            actions: [
              CupertinoActionSheetAction(
                onPressed: () {
                  final name = nameController.text.trim();
                  if (name.isNotEmpty && selectedIcon != null) {
                    ref.read(habitCategoryProvider.notifier).createCategory(name, selectedIcon);
                    Navigator.pop(context);
                  }
                },
                child: Text(LocaleKeys.habit_category_create.tr()),
              ),
              CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () => Navigator.pop(context),
                child: Text(LocaleKeys.common_cancel.tr()),
              ),
            ],
          );
        },
      ),
    );
  }
}
