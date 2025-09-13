import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
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

    return CupertinoPageScaffold(
      navigationBar: SheetHeader(
        closeButtonPosition: CloseButtonPosition.left,
        middle: Text(LocaleKeys.archived_habits_title.tr()),
      ),
      child: SafeArea(
        bottom: false,
        child: archivedHabitsAsync.when(
          loading: () => const Center(
            child: CupertinoActivityIndicator(),
          ),
          error: (error, _) => Center(
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
          data: (state) {
            if (state.archivedHabits.isEmpty) {
              return Center(
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
              );
            }

            return ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: state.archivedHabits.length,
              itemBuilder: (context, index) {
                final habit = state.archivedHabits[index];
                return ArchivedHabitCard(
                  habit: habit,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
