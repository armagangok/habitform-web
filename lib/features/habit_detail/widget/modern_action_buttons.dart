import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/models/models.dart';
import '../../home/provider/home_provider.dart';
import '../../reminder/service/reminder_service.dart';
import '../../share_habit/share_habit_page.dart';
import '../providers/habit_detail_provider.dart';
import '../widget/habit_calendar_widget.dart';

class ActionButtons extends ConsumerWidget {
  const ActionButtons({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentHabit = ref.watch(habitDetailProvider);

    if (currentHabit == null) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: CustomBlurWidget(
          blurValue: 20,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: context.cupertinoTheme.scaffoldBackgroundColor.withValues(alpha: 0.5),
            child: SafeArea(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                spacing: 12,
                children: [
                  PrimaryActionButton(
                    icon: FontAwesomeIcons.solidCalendarDays,
                    label: "Calendar",
                    color: Color(currentHabit.colorCode),
                    onPressed: () {
                      showCupertinoSheet(
                        enableDrag: false,
                        context: context,
                        builder: (context) => HabitCalendarCompletionSheet(habit: currentHabit),
                      );
                    },
                  ),
                  PrimaryActionButton(
                    icon: FontAwesomeIcons.share,
                    label: "Share",
                    color: Color(currentHabit.colorCode),
                    onPressed: () {
                      showCupertinoSheet(
                        context: context,
                        builder: (context) => ShareHabitPage(habit: currentHabit),
                      );
                    },
                  ),
                  PrimaryActionButton(
                    icon: CupertinoIcons.archivebox_fill,
                    label: "Archive",
                    color: Color(currentHabit.colorCode),
                    onPressed: () => _showArchiveConfirmationDialog(context, currentHabit, ref),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showArchiveConfirmationDialog(BuildContext context, Habit habit, WidgetRef ref) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(CupertinoIcons.archivebox, color: CupertinoColors.systemIndigo),
            const SizedBox(width: 8),
            Text(LocaleKeys.habit_detail_archive_title.tr()),
          ],
        ),
        content: Column(
          children: [
            const SizedBox(height: 8),
            Text(
              LocaleKeys.habit_detail_archive_confirmation.tr().replaceAll('{{habitName}}', habit.habitName),
            ),
            const SizedBox(height: 8),
            Text(
              LocaleKeys.habit_detail_archive_info.tr(),
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: Text(LocaleKeys.common_cancel.tr()),
          ),
          CupertinoDialogAction(
            isDestructiveAction: false,
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(homeProvider.notifier).archiveHabit(habit);
              ReminderService.cancelAllReminderNotifications(habit.reminderModel);
              navigator.pop();
            },
            child: Text(LocaleKeys.habit_detail_archive_title.tr()),
          ),
        ],
      ),
    );
  }
}

class PrimaryActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const PrimaryActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CupertinoButton.filled(
          color: color,
          sizeStyle: CupertinoButtonSize.medium,
          onPressed: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: CupertinoColors.white,
              ),
            ],
          ),
        ),
        FittedBox(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
