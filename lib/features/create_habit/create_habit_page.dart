import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '../../core/widgets/habit_color_sheet/provider/habit_color_provider.dart';
import '../../core/widgets/habit_icon/icon_picker_sheet.dart';
import '../../core/widgets/habit_icon/provider/habit_icon_provider.dart';
import '../reminder/widget/reminder_selection_widget.dart';
import 'provider/create_habit_provider.dart';

class CreateHabitPage extends ConsumerWidget {
  const CreateHabitPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addHabitState = ref.watch(createHabitProvider);

    return GestureDetector(
      onTap: context.hideKeyboard,
      child: CupertinoPageScaffold(
        navigationBar: SheetHeader(
          title: LocaleKeys.habit_create_habit.tr(),
          closeButtonPosition: CloseButtonPosition.left,
          trailing: TrailingActionButton(
            title: LocaleKeys.common_save.tr(),
            onPressed: ref.read(createHabitProvider.notifier).createHabit,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.all(15),
          children: [
            SafeArea(
              bottom: false,
              child: Column(
                spacing: KSpacing.betweenListItems,
                children: [
                  CustomHeader(
                    text: LocaleKeys.habit_habit_name.tr().toUpperCase(),
                    child: _buildHabitTextField(
                      controller: addHabitState.value?.habitNameController ?? TextEditingController(),
                      maxLines: 1,
                    ),
                  ),
                  CustomHeader(
                    text: LocaleKeys.habit_habit_description.tr().toUpperCase(),
                    child: _buildHabitTextField(
                      controller: addHabitState.value?.habitDescriptionController ?? TextEditingController(),
                    ),
                  ),
                  ReminderSelectionWidget(),
                  CustomHeader(
                    text: LocaleKeys.common_icon.tr().toUpperCase(),
                    child: IconPickerSheet(
                      onIconSelected: (icon) {
                        ref.read(iconProvider.notifier).pickIcon(icon);
                      },
                    ),
                  ),
                  CustomHeader(
                    text: LocaleKeys.colors_color.tr().toUpperCase(),
                    child: ColorPickerSheet(
                      onColorSelected: (color) {
                        ref.read(colorProvider.notifier).pickColor(color);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitTextField({
    required TextEditingController controller,
    int? maxLines,
  }) {
    return Card(
      child: CupertinoTextField(
        padding: EdgeInsets.all(10),
        maxLines: maxLines,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        controller: controller,
      ),
    );
  }
}
