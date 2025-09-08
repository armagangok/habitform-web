import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/models/models.dart';
import '../../edit_habit/edit_habit_page.dart';
import '../../edit_habit/provider/edit_habit_provider.dart';
import '../../home/provider/home_provider.dart';
import '../../reminder/service/reminder_service.dart';
import '../../share_habit/share_habit_page.dart';
import '../widget/habit_calendar_widget.dart';

class ModernActionButtons extends ConsumerWidget {
  final Habit habit;

  const ModernActionButtons({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoListSection.insetGrouped(
      header: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            FontAwesomeIcons.listCheck,
            size: 20,
            color: Color(habit.colorCode),
          ),
          const SizedBox(width: 8),
          Text(
            "Actions",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: context.titleLarge.color,
            ),
          ),
        ],
      ),
      children: [
        CupertinoListTile(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Primary Action Buttons
              Row(
                children: [
                  Expanded(
                    child: PrimaryActionButton(
                      icon: FontAwesomeIcons.solidCalendarDays,
                      label: "View Calendar",
                      color: Color(habit.colorCode),
                      onPressed: () {
                        showCupertinoSheet(
                          enableDrag: false,
                          context: context,
                          builder: (context) => HabitCalendarCompletionSheet(habit: habit),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryActionButton(
                      icon: FontAwesomeIcons.solidPenToSquare,
                      label: "Edit Habit",
                      color: Color(habit.colorCode),
                      onPressed: () {
                        ref.watch(editHabitProvider.notifier).initHabit(habit);
                        showCupertinoSheet(
                          enableDrag: false,
                          context: context,
                          builder: (context) => EditHabitPage(habit: habit),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Secondary Action Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 2.8,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: [
                  _SecondaryActionButton(
                    icon: FontAwesomeIcons.share,
                    label: "Share Progress",
                    color: Colors.blue,
                    onPressed: () {
                      showCupertinoSheet(
                        context: context,
                        builder: (context) => ShareHabitPage(habit: habit),
                      );
                    },
                  ),
                  _SecondaryActionButton(
                    icon: FontAwesomeIcons.bell,
                    label: habit.reminderModel != null ? "Edit Reminder" : "Set Reminder",
                    color: Colors.orange,
                    onPressed: () {
                      ref.watch(editHabitProvider.notifier).initHabit(habit);
                      showCupertinoSheet(
                        enableDrag: false,
                        context: context,
                        builder: (context) => EditHabitPage(habit: habit),
                      );
                    },
                  ),
                  _SecondaryActionButton(
                    icon: CupertinoIcons.doc_chart,
                    label: "Export Data",
                    color: Colors.green,
                    onPressed: () => _showExportDialog(context),
                  ),
                  _SecondaryActionButton(
                    icon: CupertinoIcons.archivebox_fill,
                    label: "Archive",
                    color: Colors.grey,
                    onPressed: () => _showArchiveConfirmationDialog(context, habit, ref),
                    isDestructive: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showExportDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.doc_chart, color: Colors.green),
            const SizedBox(width: 8),
            Text("Export Data"),
          ],
        ),
        content: Column(
          children: [
            const SizedBox(height: 8),
            Text("Export your habit data for external analysis or backup."),
            const SizedBox(height: 8),
            Text(
              "Available formats: CSV, JSON",
              style: TextStyle(
                fontSize: 12,
                color: context.bodyMedium.color?.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement export functionality
              showCupertinoDialog(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                  title: Text("Coming Soon"),
                  content: Text("Export feature will be available in the next update."),
                  actions: [
                    CupertinoDialogAction(
                      onPressed: () => Navigator.pop(context),
                      child: Text("OK"),
                    ),
                  ],
                ),
              );
            },
            child: Text("Export"),
          ),
        ],
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
              ReminderService.cancelReminderNotification(habit.reminderModel?.id);
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

class _SecondaryActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;
  final bool isDestructive;

  const _SecondaryActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isDestructive ? Colors.red.withValues(alpha: 0.1) : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDestructive ? Colors.red.withValues(alpha: 0.3) : color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : color,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDestructive ? Colors.red : context.titleLarge.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
