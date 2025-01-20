import '/core/core.dart';
import '../bloc/reminder/reminder_bloc.dart';
import '../extension/easy_day.dart';
import '../models/days/days_enum.dart';
import 'reminder_widget.dart';

class ReminderSelectionWidget extends StatelessWidget {
  const ReminderSelectionWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReminderBloc, ReminderState>(
      builder: (contextFromBuilder, state) {
        final days = state.reminder?.days;
        final remindTime = state.reminder?.reminderTime;

        return CustomHeader(
          text: LocaleKeys.habit_reminder.tr().toUpperCase(),
          child: Card(
            child: CupertinoButton(
              minSize: 0,
              padding: EdgeInsets.all(10),
              onPressed: () {
                contextFromBuilder.hideKeyboard();

                showCupertinoModalBottomSheet(
                  enableDrag: false,
                  context: context,
                  builder: (contextFromSheet) {
                    final reminderBloc = contextFromBuilder.read<ReminderBloc>();
                    return BlocProvider.value(
                      value: reminderBloc,
                      child: const ReminderPage(),
                    );
                  },
                );
              },
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          remindTime?.toHHMM() ?? LocaleKeys.common_none.tr(),
                          style: context.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: context.titleMedium?.color,
                          ),
                        ),
                        days != null && days.isNotEmpty
                            ? SizedBox(
                                height: 20,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: days.length,
                                  itemBuilder: (context, index) {
                                    final Days day = days[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 1.0),
                                      child: Text(
                                        days.isLast(index) ? day.getDayName : "${day.getDayName}, ",
                                        style: context.bodySmall?.copyWith(color: context.primary),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : SizedBox.shrink(),
                      ],
                    ),
                  ),
                  CupertinoListTileChevron(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
