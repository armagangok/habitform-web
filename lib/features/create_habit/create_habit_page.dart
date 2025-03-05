import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '../../core/widgets/habit_color_sheet/provider/habit_color_provider.dart';
import '../../core/widgets/habit_icon/icon_picker_sheet.dart';
import '../../core/widgets/habit_icon/provider/habit_icon_provider.dart';
import '../reminder/provider/reminder_provider.dart';
import '../reminder/widget/reminder_selection_widget.dart';
import 'provider/create_habit_provider.dart';

class CreateHabitPage extends ConsumerStatefulWidget {
  const CreateHabitPage({super.key});

  @override
  ConsumerState<CreateHabitPage> createState() => _CreateHabitPageState();
}

class _CreateHabitPageState extends ConsumerState<CreateHabitPage> {
  @override
  void initState() {
    super.initState();
    // Initialize reminder provider with empty reminder
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reminderProvider.notifier).initializeReminder(null);
    });
  }

  @override
  Widget build(BuildContext context) {
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
                        ref.watch(iconProvider.notifier).pickIcon(icon);
                      },
                    ),
                  ),
                  CustomHeader(
                    text: LocaleKeys.colors_color.tr().toUpperCase(),
                    child: ColorPickerSheet(
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
      ),
    );
  }

  Widget _buildHabitTextField({
    required TextEditingController controller,
    int? maxLines,
  }) {
    return Card(
      child: CupertinoTextField(
        controller: controller,
        maxLines: maxLines,
        placeholder: maxLines == 1 ? LocaleKeys.habit_habit_name.tr() : LocaleKeys.habit_habit_description.tr(),
        padding: const EdgeInsets.all(10),
        decoration: null,
      ),
    );
  }
}
