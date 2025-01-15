import 'dart:math';

import '/core/core.dart';
import '../../../core/widgets/flushbar_widget.dart';
import '../bloc/day_selection/day_selection_cubit.dart';
import '../bloc/picker_extend/picker_extend_cubit.dart';
import '../bloc/remind_time/remind_time_cubit.dart';
import '../bloc/reminder/reminder_bloc.dart';
import '../models/days/days_enum.dart';

extension DaysExtension on Days {
  String get capitalized {
    // İlk harfi büyük yapmak için:
    final name = this.name; // Enum adını al
    return name[0].toUpperCase() + name.substring(1); // İlk harfi büyüt ve geri kalanı ekle
  }
}

class ReminderPage extends StatelessWidget {
  const ReminderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DaySelectionCubit, DaySelection>(
      builder: (context, state) {
        final daySelection = state;

        final allDays = context.read<DaySelectionCubit>().allDays;
        final selectedDays = context.read<DaySelectionCubit>().selectedDays;
        return BlocBuilder<ReminderBloc, ReminderState>(
          builder: (context, state) {
            final reminder = state.reminder;
            return CupertinoPageScaffold(
              navigationBar: SheetHeader(
                closeButtonPosition: CloseButtonPosition.left,
                title: "Reminder",
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TrailingActionButton(
                      child: Text(
                        "Delete",
                        style: TextStyle(color: CupertinoColors.destructiveRed),
                      ),
                      onPressed: () async {
                        context.read<ReminderBloc>().deleteReminder(reminder, context);
                      },
                    ),
                    SizedBox(width: 10),
                    TrailingActionButton(
                      title: "Save",
                      onPressed: () {
                        if (reminder != null) {
                          if (reminder.reminderTime != null && reminder.days.isNotNullAndNotEmpty) {
                            navigator.pop();
                            LogHelper.shared.debugPrint('$reminder');
                            AppFlushbar.shared.successFlushbar("Reminder will be activated when the habit is being saved");
                          } else {
                            LogHelper.shared.debugPrint('$reminder');
                            AppFlushbar.shared.warningFlushbar("Please select days and remind time");
                          }
                        } else {
                          LogHelper.shared.debugPrint('$reminder');
                          AppFlushbar.shared.warningFlushbar("Please select days and remind time");
                        }
                      },
                    ),
                  ],
                ),
              ),
              child: ListView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  SafeArea(
                    bottom: false,
                    child: SizedBox(height: 20),
                  ),
                  Column(
                    children: [
                      CupertinoListSection(
                        backgroundColor: Colors.transparent,
                        header: Text("DAYS"),
                        children: [
                          CupertinoListTile(
                            padding: EdgeInsets.all(10),
                            title: Column(
                              children: [
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: allDays.length,
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 7,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 20,
                                  ),
                                  itemBuilder: (context, index) {
                                    final day = allDays[index];
                                    final isSelected = selectedDays.contains(day); // Günün seçili olup olmadığını kontrol et.

                                    return CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        context.read<DaySelectionCubit>().selectOneByOne(day, isSelected, context);
                                      },
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          side: BorderSide(
                                            color: context.theme.dividerColor.withAlpha(75),
                                            width: .75,
                                          ),
                                        ),
                                        color: isSelected ? context.primary : context.cupertinoTheme.scaffoldBackgroundColor,
                                        child: Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: Center(
                                            child: FittedBox(
                                              child: Text(
                                                day.capitalized,
                                                style: TextStyle(
                                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                                ),
                                                maxLines: 1,
                                              ),
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
                        ],
                      ),
                      daySelection != DaySelection.empty
                          ? Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                spacing: 10,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  daySelection == DaySelection.selected || daySelection == DaySelection.empty
                                      ? CupertinoButton.tinted(
                                          sizeStyle: CupertinoButtonSize.small,
                                          borderRadius: BorderRadius.circular(8),
                                          onPressed: () {
                                            context.read<DaySelectionCubit>().selectAll(context);
                                          },
                                          child: Text(
                                            "Select All",
                                            style: TextStyle(color: context.primary),
                                          ),
                                        ).animate().fadeIn()
                                      : SizedBox.shrink(),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 20.0),
                                    child: CupertinoButton.tinted(
                                      sizeStyle: CupertinoButtonSize.small,
                                      borderRadius: BorderRadius.circular(8),
                                      onPressed: () {
                                        context.read<DaySelectionCubit>().deselectAll(context);
                                      },
                                      child: Text(
                                        "Deselect All",
                                        style: TextStyle(color: context.primary),
                                      ).animate().fadeIn(),
                                    ).animate().fadeIn(),
                                  ),
                                ],
                              ),
                            )
                          : SizedBox.shrink(),
                    ],
                  ),
                  daySelection != DaySelection.empty
                      ? Column(
                          children: [
                            Column(
                              children: [
                                CupertinoListSection(
                                  header: Text("TIME"),
                                  backgroundColor: Colors.transparent,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        BlocBuilder<PickerExtendCubit, bool>(
                                          builder: (context, state) {
                                            final isExpanded = state;
                                            return BlocBuilder<RemindTimeCubit, DateTime>(
                                              builder: (context, state) {
                                                final remindTime = state;
                                                return AnimatedSize(
                                                  duration: Duration(milliseconds: 300),
                                                  child: CupertinoListTile(
                                                    title: Text("Select Time"),
                                                    subtitle: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          remindTime.toHHMM(),
                                                          style: TextStyle(
                                                            color: CupertinoColors.systemBlue,
                                                            fontWeight: FontWeight.normal,
                                                            fontSize: 18,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    trailing: Column(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: [
                                                        Transform.rotate(
                                                          angle: isExpanded ? pi / 2 : 0,
                                                          child: CupertinoListTileChevron().animate().fadeIn(),
                                                        ),
                                                      ],
                                                    ),
                                                    onTap: context.read<PickerExtendCubit>().switchExtendValue,
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                BlocBuilder<PickerExtendCubit, bool>(
                                  builder: (context, state) {
                                    final isExpanded = state;
                                    return AnimatedContainer(
                                      duration: Duration(milliseconds: 300),
                                      height: isExpanded ? 140 : 0,
                                      child: CupertinoDatePicker(
                                        mode: CupertinoDatePickerMode.time,
                                        initialDateTime: DateTime.now(),
                                        use24hFormat: true, // Change to false for AM/PM format
                                        onDateTimeChanged: (val) {
                                          context.read<RemindTimeCubit>().updateTime(val, context);
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ).animate().fadeIn()
                      : SizedBox.shrink(),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
