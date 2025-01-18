import '/core/core.dart';
import '../../reminder/bloc/reminder/reminder_bloc.dart';
import '../../reminder/models/reminder/reminder_model.dart';
import '../../reminder/widget/reminder_widget.dart';

class AddReminderWidget extends StatelessWidget {
  const AddReminderWidget({
    super.key,
    this.reminder,
  });

  final ReminderModel? reminder;

  @override
  Widget build(BuildContext context) {
    final days = reminder?.days;
    final remindTime = reminder?.reminderTime;
    return CustomHeader(
      text: LocaleKeys.habit_reminder.tr().toUpperCase(),
      child: Card(
        child: CupertinoButton(
          minSize: 0,
          padding: EdgeInsets.all(10),
          onPressed: () {
            context.hideKeyboard();

            showCupertinoModalBottomSheet(
              enableDrag: false,
              context: context,
              builder: (context) {
                context.read<ReminderBloc>().add(
                      InitializeReminderEvent(
                        reminder: reminder,
                        context: context,
                      ),
                    );
                return const ReminderPage();
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
                                final day = days[index];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 1.0),
                                  child: Text(
                                    days.isLast(index) ? day.capitalized : "${day.capitalized}, ",
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
  }
}
