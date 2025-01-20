import '/core/core.dart';
import '../../models/models.dart';
import 'share_habit_page.dart';

class ShareHabitButton extends StatelessWidget {
  final Habit habit;
  final ScrollController? scrollController;

  const ShareHabitButton({
    super.key,
    required this.habit,
    this.scrollController,
  });

  void _scrollToEnd() {
    if (scrollController?.hasClients ?? false) {
      scrollController!.jumpTo(scrollController!.position.maxScrollExtent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CupertinoButton.tinted(
        padding: EdgeInsets.zero,
        sizeStyle: CupertinoButtonSize.small,
        onPressed: () {
          _scrollToEnd();

          // Add a small delay to ensure scroll completes before showing the sheet
          Future.delayed(Duration(milliseconds: 100), () {
            showCupertinoModalBottomSheet(
              context: context,
              builder: (context) => ShareHabitPage(habit: habit),
            );
          });
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              LocaleKeys.share_share.tr(),
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(width: 5),
            Icon(FontAwesomeIcons.share),
          ],
        ),
      ),
    );
  }
}
