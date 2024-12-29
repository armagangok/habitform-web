import 'package:habitrise/core/widgets/trailing_button.dart';

import '/core/core.dart';
import '/core/widgets/habit_color_sheet/color_picker_sheet.dart';
import '/core/widgets/sheet_header.dart';
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
                    SizedBox(width: 20),
                    Expanded(
                      child: SizedBox(
                        width: context.width(.4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Streak Goal",
                              style: context.bodySmall,
                            ),
                            CustomButton(
                              onTap: () {},
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
                                        Text(
                                          "None",
                                          textAlign: TextAlign.center,
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
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Streak Goal",
                      style: context.bodySmall,
                    ),
                    CustomButton(
                      onTap: () {
                        showCupertinoModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return CupertinoPageScaffold(
                              child: ListView(
                                children: [],
                              ),
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
                                Text(
                                  "None",
                                  textAlign: TextAlign.center,
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
                Column(
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
                              debugPrint(color.toString());
                            });
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
                                Text(
                                  "None",
                                  textAlign: TextAlign.center,
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
