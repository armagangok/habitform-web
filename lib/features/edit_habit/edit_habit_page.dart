import '/core/core.dart';
import '/core/widgets/flushbar_widget.dart';
import '/core/widgets/habit_color_sheet/cubit/habit_color_cubit.dart';
import '/core/widgets/habit_icon/cubit/habit_icon_cubit.dart';
import '/core/widgets/habit_icon/icon_picker_sheet.dart';
import '/models/models.dart';
import '../add_habit/widget/add_reminder_widget.dart';
import '../habits/widgets/single_habit/habit_detail.dart';
import '../reminder/bloc/reminder/reminder_bloc.dart';
import '../reminder/models/reminder/reminder_model.dart';
import 'bloc/edit_habit_bloc.dart';

class EditHabitPage extends StatefulWidget {
  final Habit habit;

  const EditHabitPage({super.key, required this.habit});

  @override
  State<EditHabitPage> createState() => _EditHabitPageState();
}

class _EditHabitPageState extends State<EditHabitPage> {
  final FocusNode _focusNode = FocusNode();
  late final TextEditingController _habitNameController;
  late final TextEditingController _habitDescriptionController;

  @override
  void initState() {
    super.initState();
    _habitNameController = TextEditingController(text: widget.habit.habitName);
    _habitDescriptionController = TextEditingController(text: widget.habit.habitDescription);

    // Initialize the cubits with existing habit data
    context.read<HabitEmojiCubit>().pickIcon(widget.habit.emoji);
    context.read<HabitColorCubit>().pickColor(Color(widget.habit.colorCode));
    if (widget.habit.reminderModel != null) {
      context.read<ReminderBloc>().add(
            SetReminderEvent(reminder: widget.habit.reminderModel!),
          );
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _habitNameController.dispose();
    _habitDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditHabitBloc, EditHabitState>(
      listener: (context, state) {
        if (state is EditHabitSuccess) {
          navigator.pop();
        } else if (state is EditHabitFailure) {
          AppFlushbar.shared.errorFlushbar(state.error);
        }
      },
      child: CupertinoPageScaffold(
        navigationBar: SheetHeader(
          title: "Edit Habit",
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
              final int colorCode = context.read<HabitColorCubit>().state.color?.value ?? widget.habit.colorCode;

              final updatedHabit = widget.habit.copyWith(
                habitName: _habitNameController.text.trim(),
                habitDescription: _habitDescriptionController.text,
                reminderModel: reminderModel,
                emoji: emoji,
                colorCode: colorCode,
              );

              context.read<ReminderBloc>().scheduleReminder(
                    updatedHabit.habitName,
                    "Some message goes here",
                  );

              context.read<EditHabitBloc>().add(UpdateHabitEvent(habit: updatedHabit));
            },
          ),
        ),
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            Column(
              spacing: 30,
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

  // // Reuse the icon and color picker widgets from AddHabitPage
  // Widget _buildIconPicker() => Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Text("Icon", style: context.bodySmall),
  //         CustomButton(
  //           onTap: () {
  //             showCupertinoModalBottomSheet(
  //               enableDrag: false,
  //               context: context,
  //               builder: (context) => IconPickerSheet(
  //                 onIconSelected: (icon) {
  //                   context.read<HabitEmojiCubit>().pickIcon(icon);
  //                 },
  //               ),
  //             );
  //           },
  //           child: _buildIconPickerContent(),
  //         ),
  //       ],
  //     );

  // Widget _buildColorPicker() => Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Text("Color", style: context.bodySmall),
  //         CustomButton(
  //           onTap: () {
  //             showCupertinoModalBottomSheet(
  //               context: context,
  //               builder: (context) => ColorPickerSheet(
  //                 onColorSelected: (color) {
  //                   context.read<HabitColorCubit>().pickColor(color);
  //                 },
  //               ),
  //             );
  //           },
  //           child: _buildColorPickerContent(),
  //         ),
  //       ],
  //     );

  // Widget _buildIconPickerContent() => SizedBox(
  //       width: double.infinity,
  //       child: Card.filled(
  //         margin: EdgeInsets.zero,
  //         child: Padding(
  //           padding: const EdgeInsets.all(10),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               BlocBuilder<HabitEmojiCubit, HabitIconState>(
  //                 builder: (context, state) {
  //                   return Text(state.emoji ?? "None");
  //                 },
  //               ),
  //               CupertinoListTileChevron(),
  //             ],
  //           ),
  //         ),
  //       ),
  //     );

  // Widget _buildColorPickerContent() => SizedBox(
  //       width: double.infinity,
  //       child: BlocBuilder<HabitColorCubit, HabitColorState>(
  //         builder: (context, state) {
  //           return Card.filled(
  //             margin: EdgeInsets.zero,
  //             color: state.color ?? Color(widget.habit.colorCode),
  //             child: Padding(
  //               padding: const EdgeInsets.all(10),
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   BlocBuilder<HabitColorCubit, HabitColorState>(
  //                     builder: (context, state) {
  //                       return state.color == null ? Text("None", textAlign: TextAlign.center) : SizedBox.shrink();
  //                     },
  //                   ),
  //                   CupertinoListTileChevron(),
  //                 ],
  //               ),
  //             ),
  //           );
  //         },
  //       ),
  //     );
}
