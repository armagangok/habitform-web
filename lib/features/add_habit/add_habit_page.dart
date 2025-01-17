import 'package:habitrise/core/helpers/spacing_helper.dart';

import '/core/core.dart';
import '/core/widgets/flushbar_widget.dart';
import '/models/models.dart';
import '../../core/widgets/habit_color_sheet/cubit/habit_color_cubit.dart';
import '../../core/widgets/habit_icon/cubit/habit_icon_cubit.dart';
import '../../core/widgets/habit_icon/icon_picker_sheet.dart';
import '../habits/bloc/habit_bloc.dart';
import '../reminder/bloc/reminder/reminder_bloc.dart';
import '../reminder/models/reminder/reminder_model.dart';
import 'provider/add_habit_provider.dart';
import 'widget/add_reminder_widget.dart';

class AddHabitPage extends StatefulWidget {
  const AddHabitPage({super.key});

  @override
  State<AddHabitPage> createState() => _AddHabitPageState();
}

class _AddHabitPageState extends State<AddHabitPage> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _habitNameController = TextEditingController();
  final TextEditingController _habitDescriptionController = TextEditingController();

  @override
  void dispose() {
    _focusNode.dispose();
    _habitNameController.dispose();
    _habitDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AddHabitProvider(
      child: Builder(
        builder: (context) {
          return CupertinoPageScaffold(
            navigationBar: SheetHeader(
              title: LocaleKeys.habit_add_habit.tr(),
              closeButtonPosition: CloseButtonPosition.left,
              trailing: TrailingActionButton(
                title: LocaleKeys.common_save.tr(),
                onPressed: () {
                  if (_habitNameController.text.isEmpty) {
                    AppFlushbar.shared.warningFlushbar(LocaleKeys.errors_required_field.tr());
                    return;
                  }
                  final ReminderModel? reminderModel = context.read<ReminderBloc>().state.reminder;
                  final String? emoji = context.read<HabitEmojiCubit>().state.emoji;
                  final int colorCode = context.read<HabitColorCubit>().state.color?.value ?? CupertinoColors.activeGreen.value;
                  final Habit habit = Habit(
                    id: UuidHelper.uid,
                    habitName: _habitNameController.text.trim(),
                    habitDescription: _habitDescriptionController.text,
                    reminderModel: reminderModel,
                    emoji: emoji,
                    colorCode: colorCode,
                  );

                  final scheduleReminderEvent = ScheduleReminderEvent(
                    habit.habitName,
                    "It's time to add a completion",
                  );

                  context.read<ReminderBloc>().add(scheduleReminderEvent);
                  context.read<HabitBloc>().add(SaveHabitEvent(habit: habit));

                  navigator.pop();
                },
              ),
            ),
            child: ListView(
              padding: EdgeInsets.all(15),
              children: [
                Column(
                  spacing: KSpacing.betweenListItems,
                  children: [
                    SafeArea(
                      bottom: false,
                      child: CustomHeader(
                        text: LocaleKeys.habit_habit_name.tr().toUpperCase(),
                        child: _buildHabitTextField(controller: _habitNameController),
                      ),
                    ),
                    CustomHeader(
                      text: LocaleKeys.habit_habit_description.tr().toUpperCase(),
                      child: _buildHabitTextField(controller: _habitDescriptionController),
                    ),
                    BlocBuilder<ReminderBloc, ReminderState>(
                      builder: (context, state) {
                        return AddReminderWidget(reminder: state.reminder);
                      },
                    ),
                    CustomHeader(
                      text: LocaleKeys.common_icon.tr().toUpperCase(),
                      child: IconPickerSheet(
                        onIconSelected: (icon) {
                          context.read<HabitEmojiCubit>().pickIcon(icon);
                        },
                      ),
                    ),
                    CustomHeader(
                      text: LocaleKeys.colors_color.tr().toUpperCase(),
                      child: ColorPickerSheet(
                        onColorSelected: (color) {
                          context.read<HabitColorCubit>().pickColor(color);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHabitTextField({required TextEditingController controller}) {
    return Card(
      child: CupertinoTextField(
        padding: EdgeInsets.all(10),
        maxLines: null,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        controller: controller,
      ),
    );
  }
}
