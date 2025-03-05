import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/models/models.dart';
import '../provider/archived_habits_provider.dart';

class ArchivedHabitCard extends ConsumerWidget {
  final Habit habit;

  const ArchivedHabitCard({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitDescription = habit.habitDescription;
    final habitEmoji = habit.emoji ?? '';

    final archivedDate = habit.archiveDate;

    final archivedDateString = archivedDate != null ? DateFormat('yyyy-MM-dd').format(archivedDate) : "";

    return Stack(
      children: [
        Card(
          child: CupertinoListTile(
            onTap: () {
              showModalPopUpForActions(context);
            },
            leading: Text(
              habitEmoji,
              style: context.textTheme.titleLarge?.copyWith(fontSize: 24),
            ),
            title: Text(habit.habitName),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (habitDescription != null && habitDescription.isNotEmpty) Text(habitDescription),
                Text("${LocaleKeys.archived_habits_archived_on.tr()} $archivedDateString"),
              ],
            ),
            trailing: CupertinoListTileChevron(),
          ),
        ),
      ],
    );
  }

  Future<dynamic> showModalPopUpForActions(BuildContext context) {
    return showCupertinoModalPopup(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          return CupertinoActionSheet(
            title: Text(
              habit.habitName,
            ),
            actions: [
              CupertinoActionSheetAction(
                onPressed: () {
                  navigator.pop();
                  ref.read(archivedHabitsProvider.notifier).unarchiveHabit(habit.id);
                },
                child: Text(LocaleKeys.archived_habits_restore.tr()),
              ),
              CupertinoActionSheetAction(
                onPressed: () async {
                  final shouldDelete = await _showDeleteConfirmationDialog(context, habit);
                  if (shouldDelete) {
                    ref.read(archivedHabitsProvider.notifier).deleteArchivedHabit(habit);
                    navigator.pop();
                  }
                },
                child: Text(LocaleKeys.archived_habits_delete.tr()),
              ),
            ],
          );
        },
      ),
    );
  }

  // Show confirmation dialog for permanent deletion
  Future<bool> _showDeleteConfirmationDialog(BuildContext context, Habit habit) async {
    return await showCupertinoDialog<bool>(
          context: context,
          builder: (context) => Consumer(
            builder: (context, ref, child) {
              return CupertinoAlertDialog(
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(CupertinoIcons.exclamationmark_triangle, color: CupertinoColors.systemRed),
                    const SizedBox(width: 8),
                    Text(LocaleKeys.archived_habits_delete_confirmation_title.tr()),
                  ],
                ),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),
                    Text('${LocaleKeys.archived_habits_delete_confirmation_message.tr()}${habit.habitName}?'),
                    const SizedBox(height: 8),
                    Text(
                      LocaleKeys.archived_habits_delete_confirmation_warning.tr(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.systemRed,
                      ),
                    ),
                  ],
                ),
                actions: [
                  CupertinoDialogAction(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    isDefaultAction: true,
                    child: Text(LocaleKeys.common_cancel.tr()),
                  ),
                  CupertinoDialogAction(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    isDestructiveAction: true,
                    child: Text(LocaleKeys.common_delete.tr()),
                  ),
                ],
              );
            },
          ),
        ) ??
        false;
  }
}
