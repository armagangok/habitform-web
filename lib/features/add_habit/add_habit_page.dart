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

            context.read<SingleHabitBloc>().add(SaveSingleHabitEvent(habit: habit));

            navigator.pop();
          },
        ),
      ),
      child: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Column(
            spacing: 25,
            children: [
              SafeArea(
                bottom: false,
                child: _buildHabitTextField(text: "Name", controller: _habitNameController),
              ),
              _buildHabitTextField(text: "Description", controller: _habitDescriptionController),
              AddReminderWidget(),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Icon",
                          style: context.bodySmall,
                        ),
                        CustomButton(
                          onTap: () {
                            showCupertinoModalBottomSheet(
                              enableDrag: false,
                              context: context,
                              builder: (context) {
                                return IconPickerSheet(
                                  onIconSelected: (icon) {
                                    context.read<HabitEmojiCubit>().pickIcon(icon);
                                  },
                                );
                              },
                            );
                          },
                          child: SizedBox(
                            width: double.infinity,
                            child: Card.filled(
                              margin: EdgeInsets.zero,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    BlocBuilder<HabitEmojiCubit, HabitIconState>(
                                      builder: (context, state) {
                                        return state.emoji == null
                                            ? Text(
                                                "None",
                                                textAlign: TextAlign.center,
                                              )
                                            : Text(state.emoji ?? "");
                                      },
                                    ),
                                    CupertinoListTileChevron(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Color",
                          style: context.bodySmall,
                        ),
                        CustomButton(
                          onTap: () {
                            showCupertinoModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return ColorPickerSheet(onColorSelected: (color) {
                                  context.read<HabitColorCubit>().pickColor(color);
                                });
                              },
                            );
                          },
                          child: SizedBox(
                            width: double.infinity,
                            child: BlocBuilder<HabitColorCubit, HabitColorState>(
                              builder: (context, state) {
                                return Card.filled(
                                  margin: EdgeInsets.zero,
                                  color: state.color ?? CupertinoColors.activeBlue,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        BlocBuilder<HabitColorCubit, HabitColorState>(
                                          builder: (context, state) {
                                            return state.color == null
                                                ? Text(
                                                    "None",
                                                    textAlign: TextAlign.center,
                                                  )
                                                : SizedBox.shrink();
                                          },
                                        ),
                                        CupertinoListTileChevron(),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHabitTextField({required String text, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: context.bodySmall,
        ),
        Card(
          child: CupertinoTextField(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            controller: controller,
          ),
        ),
      ],
    );
  }
}
