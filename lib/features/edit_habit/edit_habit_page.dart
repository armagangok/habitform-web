import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitrise/features/habit_icon/icon_picker_button.dart';

import '/core/core.dart';
import '/models/models.dart';
import '../habit_category/widget/category_picker_button.dart';
import '../habit_color/color_picker_widget.dart';
import '../habit_color/provider/habit_color_provider.dart';
import '../reminder/widget/reminder_selection_widget.dart';
import 'provider/edit_habit_provider.dart';

class EditHabitPage extends ConsumerWidget {
  final Habit habit;

  const EditHabitPage({super.key, required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editHabitNotifier = ref.watch(editHabitProvider.notifier);

    return CupertinoPopupSurface(
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: context.hideKeyboard,
          child: CupertinoPageScaffold(
            backgroundColor: Colors.transparent,
            navigationBar: SheetHeader(
              title: LocaleKeys.habit_edit_habit.tr(),
              closeButtonPosition: CloseButtonPosition.left,
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  // Pass category IDs to provider
                  editHabitNotifier.updateHabit();
                },
                child: Text(
                  LocaleKeys.common_save.tr(),
                  style: context.titleMedium.copyWith(color: context.primary),
                ),
              ),
            ),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: IconPickerButton(selectedIcon: habit.emoji),
                      ),
                      CustomHeader(
                        text: LocaleKeys.habit_habit_name.tr().toUpperCase(),
                        child: _buildHabitTextField(
                          controller: editHabitNotifier.habitNameController,
                          maxLines: 1,
                        ),
                      ),
                      CustomHeader(
                        text: LocaleKeys.habit_habit_description.tr().toUpperCase(),
                        child: _buildHabitTextField(
                          controller: editHabitNotifier.habitDescriptionController,
                        ),
                      ),
                      Column(
                        children: [
                          ReminderSelectionWidget(),
                          CategoryPickerButton(),
                          ColorPickerWidget(
                            onColorSelected: (color) {
                              ref.watch(colorProvider.notifier).pickColor(color);
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 50)
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHabitTextField({
    required TextEditingController controller,
    int? maxLines,
  }) {
    return CupertinoTextField(
      controller: controller,
      maxLines: maxLines,
      placeholder: maxLines == 1 ? LocaleKeys.habit_habit_name.tr() : LocaleKeys.habit_habit_description.tr(),
      padding: const EdgeInsets.all(10),
      decoration: null,
    );
  }
}
