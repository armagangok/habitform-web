import 'package:habitrise/features/habit_detail/page/habit_detail.dart';

import '/core/core.dart';
import '/core/widgets/flushbar_widget.dart';
import '/core/widgets/habit_color_sheet/cubit/habit_color_cubit.dart';
import '/core/widgets/habit_icon/cubit/habit_icon_cubit.dart';
import '/core/widgets/habit_icon/icon_picker_sheet.dart';
import '/models/models.dart';
import '../habits/bloc/single_habit/single_habit_bloc.dart';
import '../reminder/bloc/reminder/reminder_bloc.dart';
import '../reminder/models/reminder/reminder_model.dart';
import 'widget/add_reminder_widget.dart';

class AddHabitPage extends StatefulWidget {
  const AddHabitPage({super.key});

  @override
  State<AddHabitPage> createState() => _AddHabitPageState();
}

class _AddHabitPageState extends State<AddHabitPage> {
  final FocusNode _focusNode = FocusNode();

  void openKeyboard() {
    FocusScope.of(context).requestFocus(_focusNode);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  final TextEditingController _habitNameController = TextEditingController();
  final TextEditingController _habitDescriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: SheetHeader(
        title: "Add Habit",
        closeButtonPosition: CloseButtonPosition.left,
        trailing: TrailingActionButton(
          title: "Save",
          onPressed: () {
            if (_habitNameController.text.isEmpty) {
              AppFlushbar.shared.warningFlushbar("Habit name can't be empty");
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

            context.read<ReminderBloc>().scheduleReminder(
                  habit.habitName,
                  "Some message goes here",
                );

            context.read<SingleHabitBloc>().add(SaveSingleHabitEvent(habit: habit));

            navigator.pop();
          },
        ),
      ),
      child: ListView(
        padding: EdgeInsets.all(15),
        children: [
          Column(
            spacing: 20,
            children: [
              SafeArea(
                bottom: false,
                child: CustomHeader(
                  text: "NAME",
                  child: _buildHabitTextField(controller: _habitNameController),
                ),
              ),
              CustomHeader(
                text: "DESCRIPTION",
                child: _buildHabitTextField(controller: _habitDescriptionController),
              ),
              AddReminderWidget(),
              CustomHeader(
                text: "ICON",
                child: IconPickerSheet(
                  onIconSelected: (icon) {
                    context.read<HabitEmojiCubit>().pickIcon(icon);
                  },
                ),
              ),
              CustomHeader(
                text: "COLOR",
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
