import 'package:habitrise/core/core.dart';

import '../../../models/models.dart';
import 'habit_calendar_completion_sheet.dart';

class HabitCalendarWidget extends StatefulWidget {
  final Habit habit;

  const HabitCalendarWidget({
    super.key,
    required this.habit,
  });

  @override
  State<HabitCalendarWidget> createState() => _HabitCalendarWidgetState();
}

class _HabitCalendarWidgetState extends State<HabitCalendarWidget> {
  @override
  Widget build(BuildContext context) {
    return CupertinoButton.tinted(
      sizeStyle: CupertinoButtonSize.small,
      onPressed: () {
        showCupertinoModalBottomSheet(
          enableDrag: false,
          context: context,
          builder: (context) => HabitCalendarCompletionSheet(habit: widget.habit),
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            LocaleKeys.habit_detail_calendar.tr(),
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
