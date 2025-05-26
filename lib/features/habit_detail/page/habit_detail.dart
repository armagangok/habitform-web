import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/core/widgets/custom_list_tile.dart';
import '/models/models.dart';
import '../../edit_habit/edit_habit_page.dart';
import '../../edit_habit/provider/edit_habit_provider.dart';
import '../../home/provider/home_provider.dart';
import '../../reminder/service/reminder_service.dart';
import '../../share_habit/share_habit_page.dart';
import '../providers/habit_detail_provider.dart';
import '../widget/habit_calendar_widget.dart';
import '../widget/habit_data_widget.dart';
import '../widget/navbar_button.dart';

class HabitDetailPage extends ConsumerWidget {
  const HabitDetailPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentHabit = ref.watch(habitDetailProvider);

    if (currentHabit == null) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        CupertinoPopupSurface(
          child: CupertinoPageScaffold(
            backgroundColor: Colors.transparent,
            navigationBar: SheetHeader(
              title: LocaleKeys.habit_detail_detail.tr(),
              closeButtonPosition: CloseButtonPosition.left,
            ),
            child: ListView(
              children: [
                SafeArea(
                  child: Column(
                    spacing: 16,
                    children: [
                      SizedBox(height: 28),
                      _iconPicker(context, currentHabit),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15) + const EdgeInsets.only(top: 10),
                        child: _HabitGeneralInfo(
                          name: currentHabit.habitName,
                          description: currentHabit.habitDescription,
                          emoji: currentHabit.emoji,
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
                    NavBarButton(
                      icon: FontAwesomeIcons.solidCalendarDays,
                      color: Color(currentHabit.colorCode),
                      label: LocaleKeys.habit_detail_calendar.tr(),
                      onPressed: () {
                        showCupertinoModalBottomSheet(
                          enableDrag: false,
                          context: context,
                          builder: (context) => HabitCalendarCompletionSheet(habit: currentHabit),
                        );
                      },
                    ),
                    NavBarButton(
                      icon: CupertinoIcons.archivebox_fill,
                      color: Color(currentHabit.colorCode),
                      label: LocaleKeys.habit_detail_archive_title.tr(),
                      onPressed: () => _showArchiveConfirmationDialog(context, currentHabit),
                    ),
                    NavBarButton(
                      color: Color(currentHabit.colorCode),
                      icon: FontAwesomeIcons.share,
                      label: LocaleKeys.share_share.tr(),
                      onPressed: () {
                        showCupertinoModalBottomSheet(
                          context: context,
                          builder: (context) => ShareHabitPage(habit: currentHabit),
                        );
                      },
                    ),
                    NavBarButton(
                      icon: FontAwesomeIcons.solidPenToSquare,
                      label: LocaleKeys.common_edit.tr(),
                      color: Color(currentHabit.colorCode),
                      onPressed: () {
                        ref.watch(editHabitProvider.notifier).initHabit(currentHabit);

                        showCupertinoModalBottomSheet(
                          enableDrag: false,
                          context: context,
                          builder: (context) => EditHabitPage(habit: currentHabit),
                        );
                      },
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

  CustomButton _iconPicker(BuildContext context, Habit currentHabit) {
    return CustomButton(
      onPressed: () {},
      child: Container(
        height: 90,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.theme.scaffoldBackgroundColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey.withValues(alpha: .7),
            width: .5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              spreadRadius: 10,
              blurRadius: 30,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Text(
          currentHabit.emoji ?? "",
          style: const TextStyle(fontSize: 40, color: Colors.white),
        ),
      ),
    );
  }

  void _showArchiveConfirmationDialog(BuildContext context, Habit habit) {
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
          Consumer(
            builder: (context, ref, child) {
              return CupertinoDialogAction(
                isDestructiveAction: false,
                onPressed: () async {
                  Navigator.pop(context);
                  await ref.read(homeProvider.notifier).archiveHabit(habit);
                  ReminderService.cancelReminderNotification(habit.reminderModel?.id);

                  navigator.pop();
                },
                child: Text(LocaleKeys.habit_detail_archive_title.tr()),
              );
            },
          )
        ],
      ),
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
