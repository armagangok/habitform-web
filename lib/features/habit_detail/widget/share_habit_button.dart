import '/core/core.dart';
import '../../../models/models.dart';
import '../page/share_habit_page.dart';

class ShareHabitButton extends StatelessWidget {
  final Habit habit;

  const ShareHabitButton({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CupertinoButton.tinted(
        color: CupertinoColors.activeBlue,
        padding: EdgeInsets.zero,
        sizeStyle: CupertinoButtonSize.small,
        onPressed: () {
          showCupertinoModalBottomSheet(
              context: context,
              builder: (context) {
                return ShareHabitPage(habit: habit);
              });
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Share",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: CupertinoColors.activeBlue,
              ),
            ),
            SizedBox(width: 5),
            Icon(
              FontAwesomeIcons.share,
              color: CupertinoColors.activeBlue,
            ),
          ],
        ),
      ),
    );
  }
}
