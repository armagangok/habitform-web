import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '../habit_category/provider/habit_category_button_provider.dart';
import '../reminder/provider/reminder_provider.dart';
import 'widgets/step_widgets/page_view_step_router.dart';

class CreateHabitPage extends ConsumerStatefulWidget {
  const CreateHabitPage({super.key});

  @override
  ConsumerState<CreateHabitPage> createState() => _CreateHabitPageState();
}

class _CreateHabitPageState extends ConsumerState<CreateHabitPage> {
  @override
  void initState() {
    super.initState();
    // Initialize reminder provider with empty reminder
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.watch(reminderProvider.notifier).initializeReminder(null);
      // Clear any previously selected categories when creating a new habit
      ref.watch(categoryButtonProvider.notifier).clearCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: context.hideKeyboard,
      child: CupertinoPageScaffold(
        navigationBar: SheetHeader(
          title: LocaleKeys.habit_create_habit.tr(),
          closeButtonPosition: CloseButtonPosition.left,
        ),
        child: SafeArea(
          bottom: true,
          child: const PageViewStepRouter(),
        ),
      ),
    );
  }
}
