import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/features/reminder/extension/easy_day.dart';
import '/features/reminder/models/days/days_enum.dart';
import '/models/models.dart';
import '../../../core/widgets/custom_list_tile.dart';
import '../../edit_habit/edit_habit_page.dart';
import '../../edit_habit/provider/edit_habit_provider.dart';
import '../../home/provider/home_provider.dart';
import '../../reminder/service/reminder_service.dart';
import '../../share_habit/share_habit_button.dart';
import '../providers/habit_detail_provider.dart';
import '../widget/habit_calendar_widget.dart';
import '../widget/habit_data_widget.dart';

class HabitDetailPage extends ConsumerStatefulWidget {
  const HabitDetailPage({
    super.key,
    required this.habit,
  });

  final Habit habit;

  @override
  ConsumerState<HabitDetailPage> createState() => _HabitDetailPageState();
}

class _HabitDetailPageState extends ConsumerState<HabitDetailPage> {
  @override
  void initState() {
    super.initState();
    // Set initial habit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(habitDetailProvider.notifier).setHabit(widget.habit);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentHabit = ref.watch(habitDetailProvider);

    if (currentHabit == null) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        CupertinoPageScaffold(
          navigationBar: SheetHeader(
            title: "${currentHabit.emoji ?? ""}${LocaleKeys.habit_detail_detail.tr()}",
            closeButtonPosition: CloseButtonPosition.left,
          ),
          child: ListView(
            children: [
              SafeArea(
                child: Column(
                  spacing: 30,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15) + const EdgeInsets.only(top: 10),
                      child: CustomHeader(
                        text: LocaleKeys.common_general.tr(),
                        child: _HabitGeneralInfo(
                          name: currentHabit.habitName,
                          description: currentHabit.habitDescription,
                          emoji: currentHabit.emoji,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: CustomHeader(
                        text: LocaleKeys.habit_reminder.tr(),
                        child: _ReminderInfo(
                          remindTime: currentHabit.reminderModel?.reminderTime?.toHHMM(),
                          days: currentHabit.reminderModel?.days,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: CustomHeader(
                        text: LocaleKeys.habit_detail_habitData.tr(),
                        child: HabitDataWidget(habit: currentHabit),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: CustomBlurWidget(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          HabitCalendarWidget(),
                          const SizedBox(height: 2.5),
                          Text(
                            LocaleKeys.habit_detail_calendar.tr(),
                            style: context.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ArchiveButton(habit: currentHabit),
                          const SizedBox(height: 2.5),
                          Text(
                            LocaleKeys.habit_detail_archive_title.tr(),
                            style: context.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ShareHabitButton(habit: currentHabit),
                          const SizedBox(height: 2.5),
                          Text(
                            LocaleKeys.share_share.tr(),
                            style: context.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _EditButton(habit: currentHabit),
                          const SizedBox(height: 2.5),
                          Text(
                            LocaleKeys.common_edit.tr(),
                            style: context.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HabitGeneralInfo extends ConsumerWidget {
  const _HabitGeneralInfo({
    required this.name,
    this.description,
    this.emoji,
  });

  final String name;
  final String? description;
  final String? emoji;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomListTile(
      title: name,
      description: description,
      onPressed: () {
        final habit = ref.read(habitDetailProvider);
        if (habit == null) return;

        ref.watch(editHabitProvider.notifier).initHabit(habit);

        showCupertinoModalBottomSheet(
          enableDrag: false,
          context: context,
          builder: (context) => EditHabitPage(habit: habit),
        );
      },
    );
  }
}

class _ReminderInfo extends ConsumerWidget {
  const _ReminderInfo({
    required this.remindTime,
    this.days,
  });

  final String? remindTime;
  final List<Days>? days;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: CustomListTile(
        title: remindTime ?? LocaleKeys.common_none.tr(),
        additionalInfo: (days != null && days!.isNotEmpty)
            ? SizedBox(
                height: 20,
                child: days!.length == 7
                    ? Text(
                        LocaleKeys.habit_daily.tr(),
                        style: context.bodyLarge?.copyWith(
                          color: context.primary.withValues(alpha: .72),
                        ),
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: days!.length,
                        separatorBuilder: (context, index) {
                          return Text(
                            ", ",
                            style: context.bodyMedium?.copyWith(
                              color: context.primary.withAlpha(170),
                            ),
                          );
                        },
                        itemBuilder: (context, index) {
                          final day = days![index];
                          return Text(
                            day.shortenDayName,
                            style: context.bodyMedium?.copyWith(
                              color: context.primary.withAlpha(170),
                            ),
                          );
                        },
                      ),
              )
            : null,
        onPressed: () {
          final habit = ref.watch(habitDetailProvider);
          ref.watch(editHabitProvider.notifier).initHabit(habit!);

          showCupertinoModalBottomSheet(
            enableDrag: false,
            context: context,
            builder: (context) => EditHabitPage(
              habit: habit,
            ),
          );
        },
      ),
    );
  }
}

class _ArchiveButton extends ConsumerWidget {
  const _ArchiveButton({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoButton.tinted(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      sizeStyle: CupertinoButtonSize.small,
      onPressed: () => _showArchiveConfirmationDialog(context, ref, habit),
      child: const Icon(
        CupertinoIcons.archivebox_fill,
        size: 20,
      ),
    );
  }

  void _showArchiveConfirmationDialog(BuildContext context, WidgetRef ref, Habit habit) {
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

class _EditButton extends ConsumerWidget {
  const _EditButton({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoButton.tinted(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      sizeStyle: CupertinoButtonSize.small,
      onPressed: () {
        ref.watch(editHabitProvider.notifier).initHabit(habit);

        showCupertinoModalBottomSheet(
          enableDrag: false,
          context: context,
          builder: (context) => EditHabitPage(habit: habit),
        );
      },
      child: Icon(
        FontAwesomeIcons.solidPenToSquare,
        size: 20,
      ),
    );
  }
}
