import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '../habit_category/provider/habit_category_button_provider.dart';
import '../habit_category/widget/category_picker_button.dart';
import '../habit_color/color_picker_widget.dart';
import '../habit_color/provider/habit_color_provider.dart';
import '../habit_icon/icon_picker_button.dart';
import '../habit_icon/provider/habit_icon_provider.dart';
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
      // Clear any previously selected categories when creating a new habit
      ref.read(categoryButtonProvider.notifier).clearCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final addHabitState = ref.watch(createHabitProvider);
    final selectedIcon = ref.watch(iconProvider);

    return CupertinoPopupSurface(
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: context.hideKeyboard,
          child: CupertinoPageScaffold(
            backgroundColor: Colors.transparent,
            navigationBar: SheetHeader(
              title: LocaleKeys.habit_create_habit.tr(),
              closeButtonPosition: CloseButtonPosition.left,
              trailing: TrailingActionButton(
                title: LocaleKeys.common_save.tr(),
                onPressed: () {
                  ref.watch(createHabitProvider.notifier).createHabit();
                },
              ),
            ),
            child: CupertinoScrollbar(
              thumbVisibility: false,
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: IconPickerButton(selectedIcon: selectedIcon),
                        ),
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
                        SizedBox(height: KSpacing.betweenListItems),
                        Column(
                          children: [
                            ReminderSelectionWidget(),
                            CategoryPickerButton(),
                            SizedBox(height: KSpacing.betweenListItems),
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
