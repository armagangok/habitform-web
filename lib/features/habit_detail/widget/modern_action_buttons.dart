import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/core/helpers/notifications/notification_helper.dart';
import '/models/models.dart';
import '/services/app_lifecycle_service.dart';
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: context.cupertinoTheme.scaffoldBackgroundColor.withValues(alpha: 0.5),
            child: SafeArea(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                spacing: 12,
                children: [
                  PrimaryActionButton(
                    icon: FontAwesomeIcons.solidCalendarDays,
                    label: LocaleKeys.habit_detail_calendar.tr(),
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
                    label: LocaleKeys.habit_detail_share.tr(),
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
                    label: LocaleKeys.habit_detail_archive.tr(),
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
              LogHelper.shared.debugPrint('🔄 ARCHIVE PROCESS STARTED for habit: ${habit.habitName} (ID: ${habit.id})');

              Navigator.pop(context);

              LogHelper.shared.debugPrint('📱 Step 1: Notifying app lifecycle service that archiving is starting');
              // Notify app lifecycle service that archiving is starting
              AppLifecycleService.shared.notifyArchivingStarted();

              LogHelper.shared.debugPrint('🔍 Step 2: Analyzing notification IDs before cancellation');
              // Debug: Analyze notification IDs before cancellation
              if (habit.reminderModel != null) {
                LogHelper.shared.debugPrint('📋 Habit has reminder model: ${habit.reminderModel}');
                await NotificationHelper.shared.debugNotificationIdsForHabit(
                  habit.habitName,
                  habit.reminderModel!.id,
                  habit.reminderModel!.days,
                );
              } else {
                LogHelper.shared.debugPrint('❌ Habit has NO reminder model');
              }

              LogHelper.shared.debugPrint('🚫 Step 3: Cancelling notifications BEFORE archiving the habit');
              // Cancel notifications BEFORE archiving the habit
              if (habit.reminderModel != null) {
                LogHelper.shared.debugPrint('🔄 Calling ReminderService.cancelAllReminderNotifications...');
                await ReminderService.cancelAllReminderNotifications(habit.reminderModel);
                LogHelper.shared.debugPrint('✅ Notifications cancelled for habit being archived: ${habit.id}');
              } else {
                LogHelper.shared.debugPrint('⏭️ Skipping notification cancellation - no reminder model');
              }

              LogHelper.shared.debugPrint('📦 Step 4: Calling homeProvider.archiveHabit...');
              await ref.read(homeProvider.notifier).archiveHabit(habit);
              LogHelper.shared.debugPrint('✅ HomeProvider.archiveHabit completed');

              LogHelper.shared.debugPrint('🔙 Step 5: Navigating back');
              navigator.pop();

              LogHelper.shared.debugPrint('🎉 ARCHIVE PROCESS COMPLETED for habit: ${habit.habitName}');
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
          color: context.primaryContrastingColor,
          sizeStyle: CupertinoButtonSize.medium,
          onPressed: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: context.primaryContrastingColor.withValues(alpha: 1),
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
              color: context.primaryContrastingColor.withValues(alpha: .9),
            ),
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
