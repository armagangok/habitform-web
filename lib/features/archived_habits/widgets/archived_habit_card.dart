import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitrise/features/archived_habits/provider/archived_habits_provider.dart';

import '/core/core.dart';
import '/models/models.dart';

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

        // Positioned.fill(
        //   child: CustomBlurWidget(
        //     blurValue: 1.75,
        //     child: CupertinoButton(
        //       onPressed: () {
        //         showModalPopUpForActions(context);
        //       },
        //       child: SizedBox(),
        //     ),
        //   ),
        // ),

        // Positioned.fill(
        //   child: Transform.rotate(
        //     angle: -0.075,
        //     child: GestureDetector(
        //       onTap: () {
        //         showModalPopUpForActions(context);
        //       },
        //       child: Align(
        //         alignment: Alignment.center,
        //         child: Card(
        //           shape: RoundedRectangleBorder(
        //             borderRadius: BorderRadius.circular(10),
        //             side: BorderSide(color: CupertinoColors.destructiveRed),
        //           ),
        //           color: Colors.transparent,
        //           child: Padding(
        //             padding: const EdgeInsets.all(6.0),
        //             child: Text(
        //               LocaleKeys.archived_habits_marked_for_deletion.tr(),
        //               style: context.textTheme.titleSmall?.copyWith(
        //                 color: CupertinoColors.destructiveRed,
        //                 fontWeight: FontWeight.bold,
        //               ),
        //             ),
        //           ),
        //         ),
        //       ),
        //     ),
        //   ),
        // )
        //     .animate(
        //       delay: const Duration(milliseconds: 350),
        //     )
        //     .scale(
        //       duration: const Duration(milliseconds: 350),
        //       curve: Curves.easeOutBack,
        //       alignment: Alignment.center,
        //     )
        //     .custom(
        //       begin: 1.5,
        //       end: 1.0,
        //       curve: Curves.easeOutBack,
        //       builder: (context, value, child) {
        //         return Transform.scale(
        //           scale: value,
        //           child: child,
        //         );
        //       },
        //     ),
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
                  ref.read(archivedHabitsProvider.notifier).unarchiveHabit(habit.id);
                  navigator.pop();
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
