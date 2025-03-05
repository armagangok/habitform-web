import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/core/widgets/habit_color_sheet/provider/habit_color_provider.dart';
import '/core/widgets/habit_icon/icon_picker_sheet.dart';
import '/core/widgets/habit_icon/provider/habit_icon_provider.dart';
import '/models/models.dart';
import '../reminder/widget/reminder_selection_widget.dart';
import 'provider/edit_habit_provider.dart';

class EditHabitPage extends ConsumerWidget {
  final Habit habit;

  const EditHabitPage({super.key, required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editHabitNotifier = ref.watch(editHabitProvider.notifier);
    final editHabitState = ref.watch(editHabitProvider);

    return CupertinoPageScaffold(
      navigationBar: SheetHeader(
        title: LocaleKeys.habit_edit_habit.tr(),
        closeButtonPosition: CloseButtonPosition.left,
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: editHabitNotifier.updateHabit,
          child: Text(
            LocaleKeys.common_save.tr(),
            style: context.titleMedium?.copyWith(color: context.primary),
          ),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              spacing: KSpacing.betweenListItems,
              children: [
                CustomHeader(
                  text: LocaleKeys.habit_habit_name.tr().toUpperCase(),
                  child: _buildHabitTextField(
                    controller: editHabitNotifier.habitNameController,
                  ),
                ),
                CustomHeader(
                  text: LocaleKeys.habit_habit_description.tr().toUpperCase(),
                  child: _buildHabitTextField(
                    controller: editHabitNotifier.habitDescriptionController,
                  ),
                ),
                ReminderSelectionWidget(reminderModel: editHabitState?.reminderModel),
                CustomHeader(
                  text: LocaleKeys.common_icon.tr().toUpperCase(),
                  child: IconPickerSheet(
                    selectedIcon: habit.emoji,
                    onIconSelected: (icon) {
                      ref.watch(iconProvider.notifier).pickIcon(icon);
                    },
                  ),
                ),
                CustomHeader(
                  text: LocaleKeys.colors_color.tr().toUpperCase(),
                  child: ColorPickerSheet(
                    selectedColor: Color(habit.colorCode),
                    onColorSelected: (color) {
                      ref.watch(colorProvider.notifier).pickColor(color);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitTextField({required TextEditingController controller, String? placeHolder}) {
    return Card(
      child: CupertinoTextField(
        padding: EdgeInsets.all(10),
        maxLines: null,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        placeholder: placeHolder,
        controller: controller,
      ),
    );
  }
}
