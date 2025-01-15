import '/core/core.dart';
import '../../habits/widgets/single_habit/habit_detail.dart';
import '../../reminder/bloc/reminder/reminder_bloc.dart';
import '../../reminder/widget/reminder_widget.dart';

class AddReminderWidget extends StatelessWidget {
  const AddReminderWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReminderBloc, ReminderState>(
      builder: (context, state) {
        final reminderState = state;
        final days = reminderState.reminder?.days;
        final remindTime = reminderState.reminder?.reminderTime;

        return CustomHeader(
          text: "REMINDER",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (days != null && days.isNotEmpty)
                SizedBox(
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
                ),
              CustomButton(
                onTap: () {
                  context.read<ReminderBloc>().initializeReminderData(null, context);
                  showCupertinoModalBottomSheet(
                    enableDrag: false,
                    context: context,
                    builder: (contextFromSheet) {
                      return ReminderPage();
                    },
                  );
                },
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SizedBox(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            remindTime == null || days == null || days.isEmpty ? "None" : remindTime.toHHMM(),
                            style: context.bodyLarge?.copyWith(fontWeight: FontWeight.normal),
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
        );
      },
    );
  }
}
