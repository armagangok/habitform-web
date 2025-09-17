import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '../provider/archivated_habits_state.dart';
import '../provider/archived_habits_provider.dart';
import '../widgets/archived_habit_card.dart';

class ArchivedHabitsPage extends ConsumerStatefulWidget {
  const ArchivedHabitsPage({super.key});

  @override
  ConsumerState<ArchivedHabitsPage> createState() => _ArchivedHabitsPageState();
}

class _ArchivedHabitsPageState extends ConsumerState<ArchivedHabitsPage> {
  @override
  void initState() {
    super.initState();
    ref.read(archivedHabitsProvider.notifier).fetchArchivedHabits();
  }

  @override
  Widget build(BuildContext context) {
    final archivedHabitsAsync = ref.watch(archivedHabitsProvider);

    return archivedHabitsAsync.when(
      loading: () => CupertinoPageScaffold(
        navigationBar: SheetHeader(
          closeButtonPosition: CloseButtonPosition.left,
          middle: Text(LocaleKeys.archived_habits_title.tr()),
        ),
        child: const Center(child: CupertinoActivityIndicator()),
      ),
      error: (error, _) => CupertinoPageScaffold(
        navigationBar: SheetHeader(
          closeButtonPosition: CloseButtonPosition.left,
          middle: Text(LocaleKeys.archived_habits_title.tr()),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                CupertinoIcons.exclamationmark_triangle,
                size: 48,
                color: CupertinoColors.systemRed,
              ),
              const SizedBox(height: 16),
              Text('${LocaleKeys.common_error.tr()}: $error'),
            ],
          ),
        ),
      ),
      data: (state) => CupertinoPageScaffold(
        navigationBar: SheetHeader(
          closeButtonPosition: CloseButtonPosition.left,
          middle: Text(LocaleKeys.archived_habits_title.tr()),
          trailing: state.isSelectionMode
              ? _buildSelectionActions(context, state)
              : CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(CupertinoIcons.checkmark_circle),
                  onPressed: () {
                    ref.read(archivedHabitsProvider.notifier).toggleSelectionMode();
                  },
                ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              if (state.isSelectionMode && state.selectedHabitIds.isNotEmpty) _buildSelectionInfoBar(context, state),
              Expanded(
                child: state.archivedHabits.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.archivebox,
                              size: 64,
                              color: CupertinoTheme.of(context).primaryColor.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              LocaleKeys.archived_habits_no_habits_found.tr(),
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              LocaleKeys.archived_habits_no_habits_hint.tr(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: state.archivedHabits.length,
                        itemBuilder: (context, index) {
                          final habit = state.archivedHabits[index];
                          return ArchivedHabitCard(
                            habit: habit,
                            isSelectionMode: state.isSelectionMode,
                            isSelected: state.selectedHabitIds.contains(habit.id),
                            onLongPress: () {
                              ref.read(archivedHabitsProvider.notifier).toggleSelectionMode();
                              ref.read(archivedHabitsProvider.notifier).toggleHabitSelection(habit.id);
                            },
                            onTap: () {
                              if (state.isSelectionMode) {
                                ref.read(archivedHabitsProvider.notifier).toggleHabitSelection(habit.id);
                              }
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionActions(BuildContext context, ArchivedHabitsState state) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (state.selectedHabitIds.isNotEmpty)
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.delete),
            onPressed: () => _showDeleteSelectedConfirmation(context),
          ),
        const SizedBox(width: 8),
        CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.xmark_circle),
          onPressed: () {
            ref.read(archivedHabitsProvider.notifier).toggleSelectionMode();
          },
        ),
      ],
    );
  }

  Widget _buildSelectionInfoBar(BuildContext context, ArchivedHabitsState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: CupertinoTheme.of(context).primaryColor.withValues(alpha: 0.1),
      child: Row(
        children: [
          Text(
            LocaleKeys.archived_habits_selected_count.tr(namedArgs: {'count': state.selectedHabitIds.length.toString()}),
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: Text(
              state.selectedHabitIds.length == state.archivedHabits.length ? LocaleKeys.archived_habits_deselect_all.tr() : LocaleKeys.archived_habits_select_all.tr(),
              style: TextStyle(color: CupertinoTheme.of(context).primaryColor),
            ),
            onPressed: () {
              if (state.selectedHabitIds.length == state.archivedHabits.length) {
                ref.read(archivedHabitsProvider.notifier).clearSelection();
              } else {
                ref.read(archivedHabitsProvider.notifier).selectAllHabits();
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteSelectedConfirmation(BuildContext context) async {
    final state = ref.read(archivedHabitsProvider).value!;
    final selectedCount = state.selectedHabitIds.length;

    final shouldDelete = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(CupertinoIcons.exclamationmark_triangle, color: CupertinoColors.systemRed),
            const SizedBox(width: 8),
            Text(LocaleKeys.archived_habits_delete_selected_title.tr()),
          ],
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            Text(
              LocaleKeys.archived_habits_delete_selected_message.tr(namedArgs: {'count': selectedCount.toString()}),
            ),
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
            onPressed: () => Navigator.of(context).pop(false),
            isDefaultAction: true,
            child: Text(LocaleKeys.common_cancel.tr()),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(true),
            isDestructiveAction: true,
            child: Text(LocaleKeys.common_delete.tr()),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await ref.read(archivedHabitsProvider.notifier).deleteSelectedHabits();
    }
  }
}
