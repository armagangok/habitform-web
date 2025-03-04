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
    return CupertinoButton.tinted(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
      child: Icon(
        FontAwesomeIcons.share,
        size: 20,
      ),
    );
  }
}
