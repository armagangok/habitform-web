import 'package:habitrise/core/widgets/habit_color_sheet/cubit/habit_color_cubit.dart';
import 'package:habitrise/core/widgets/habit_icon/cubit/habit_icon_cubit.dart';
import 'package:habitrise/core/widgets/habit_icon/icon_picker_sheet.dart';

import '/core/core.dart';
import '../habits/widgets/habit_type_widget.dart';
import 'bloc/cubit/reminder_time_cubit.dart';
import 'widgets/add_reminder.dart';

class AddHabitPage extends StatefulWidget {
  const AddHabitPage({super.key});

  @override
  State<AddHabitPage> createState() => _AddHabitPageState();
}

class _AddHabitPageState extends State<AddHabitPage> {
  String _selectedSegment = 'BasicHabits';

  final FocusNode _focusNode = FocusNode();

  void openKeyboard() {
    FocusScope.of(context).requestFocus(_focusNode);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: SheetHeader(
        title: "Add Habit",
        closeButtonPosition: CloseButtonPosition.left,
        trailing: TrailingActionButton(
          title: "Save",
          onPressed: () {},
        ),
      ),
      child: ListView(
        padding: EdgeInsets.all(20),
        children: [
          SafeArea(
            child: HabitTypeSegmentedControl(
              selectedSegment: _selectedSegment,
              onSegmentChanged: (value) {
                setState(() => _selectedSegment = value);
              },
            ),
          ),
          if (_selectedSegment == 'BasicHabits')
            Column(
              spacing: 15,
              children: [
                _buildHabitTextField(text: "Name"),
                _buildHabitTextField(text: "Description"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Reminder",
                            style: context.bodySmall,
                          ),
                          BlocBuilder<ReminderCubit, ReminderTimeState>(
                            builder: (context, state) {
                              return CustomButton(
                                onTap: () {
                                  showCupertinoModalBottomSheet(
                                    enableDrag: false,
                                    context: context,
                                    builder: (contextFromSheet) => AddReminderPage(),
                                  );
                                },
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Card.filled(
                                    margin: EdgeInsets.zero,
                                    color: Colors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: BlocBuilder<ReminderCubit, ReminderTimeState>(
                                              builder: (context, state) {
                                                // print(state.reminderModel?.days);
                                                // print(state.reminderModel?.reminderTime);
                                                return SizedBox(
                                                  width: context.width(.4),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        state.reminderModel?.reminderTime?.toHHMM() ?? "None",
                                                        textAlign: TextAlign.center,
                                                      ),
                                                      if (state.reminderModel?.days != null)
                                                        Wrap(
                                                          runSpacing: 0,
                                                          spacing: 5,
                                                          children: List.generate(
                                                            state.reminderModel?.days?.length ?? 0,
                                                            (index) {
                                                              final day = state.reminderModel!.days!.toList()[index];
                                                              return Text(
                                                                day.capitalized,
                                                                style: context.bodySmall.copyWith(
                                                                  color: CupertinoColors.systemBlue,
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          CupertinoListTileChevron(),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // SizedBox(width: 20),
                    // Expanded(
                    //   child: SizedBox(
                    //     width: context.width(.4),
                    //     child: Column(
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children: [
                    //         Text(
                    //           "Streak Goal",
                    //           style: context.bodySmall,
                    //         ),
                    //         CustomButton(
                    //           onTap: () {},
                    //           child: SizedBox(
                    //             width: double.infinity,
                    //             child: Card.filled(
                    //               margin: EdgeInsets.zero,
                    //               color: Colors.white,
                    //               child: Padding(
                    //                 padding: const EdgeInsets.all(8.0),
                    //                 child: Row(
                    //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //                   children: [
                    //                     Text(
                    //                       "None",
                    //                       textAlign: TextAlign.center,
                    //                     ),
                    //                     CupertinoListTileChevron(),
                    //                   ],
                    //                 ),
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
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
                                      context.read<HabitIconCubit>().pickIcon(icon);
                                    },
                                  );
                                },
                              );
                            },
                            child: SizedBox(
                              width: double.infinity,
                              child: Card.filled(
                                margin: EdgeInsets.zero,
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      BlocBuilder<HabitIconCubit, HabitIconState>(
                                        builder: (context, state) {
                                          return state.iconData == null
                                              ? Text(
                                                  "None",
                                                  textAlign: TextAlign.center,
                                                )
                                              : Icon(state.iconData);
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
                                      padding: const EdgeInsets.all(8.0),
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
          if (_selectedSegment == 'ChainedHabits') Text("data2"),
        ],
      ),
    );
  }

  Widget _buildHabitTextField({required String text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: context.bodySmall,
        ),
        CupertinoTextField(),
      ],
    );
  }
}
