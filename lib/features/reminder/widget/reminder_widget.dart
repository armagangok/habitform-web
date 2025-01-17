import 'package:habitrise/features/reminder/widget/select_time_item.dart';

import '/core/core.dart';
import '../bloc/picker_extend/picker_extend_cubit.dart';
import '../bloc/remind_time/remind_time_cubit.dart';
import '../bloc/reminder/reminder_bloc.dart';
import '../models/days/days_enum.dart';
import '../provider/reminder_provider.dart';
import 'days_grid_view.dart';
import 'selection_buttons.dart';

extension DaysExtension on Days {
  String get capitalized {
    final name = this.name;
    return name[0].toUpperCase() + name.substring(1);
  }
}

class ReminderPage extends StatelessWidget {
  const ReminderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ReminderProvider(
      child: BlocBuilder<ReminderBloc, ReminderState>(
        builder: (context, state) {
          final reminder = state.reminder;
          return CupertinoPageScaffold(
            navigationBar: SheetHeader(
              closeButtonPosition: CloseButtonPosition.left,
              title: LocaleKeys.habit_reminder.tr(),
              // trailing: CupertinoButton(
              //   padding: EdgeInsets.zero,
              //   child: Text(
              //     LocaleKeys.common_save.tr(),
              //     style: context.titleMedium?.copyWith(color: context.primary),
              //   ),
              //   onPressed: () {
              //     final currentState = context.read<ReminderBloc>().state;
              //     if (currentState is ReminderSelectionState) {
              //       context.read<ReminderBloc>().add(
              //             InitializeReminderEvent(
              //               reminder: currentState.reminder,
              //               context: context,
              //             ),
              //           );
              //     }
              //     Navigator.pop(context);
              //   },
              // ),
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
                      header: Text(LocaleKeys.common_days.tr()),
                      children: [
                        CupertinoListTile(
                          padding: EdgeInsets.all(10),
                          title: DaysGridViewBuilder(),
                        ),
                      ],
                    ),
                    SelectionButtons(),
                  ],
                ),
                Column(
                  children: [
                    Column(
                      children: [
                        CupertinoListSection(
                          header: Text("TIME"),
                          backgroundColor: Colors.transparent,
                          children: [
                            SelectTimeItem(),
                          ],
                        ),
                        BlocBuilder<PickerExtendCubit, bool>(
                          builder: (context, state) {
                            final isExpanded = state;
                            return AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              height: isExpanded ? 300 : 0,
                              child: CupertinoDatePicker(
                                mode: CupertinoDatePickerMode.time,
                                initialDateTime: reminder?.reminderTime ?? DateTime.now().copyWith(hour: 12, minute: 0, second: 0),
                                use24hFormat: true,
                                onDateTimeChanged: (val) {
                                  context.read<RemindTimeCubit>().updateTime(val);
                                  context.read<ReminderBloc>().add(UpdateReminderTimeEvent(time: val));
                                },
                              ),
                            );
                          },
                        ),
                      ],
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
}
