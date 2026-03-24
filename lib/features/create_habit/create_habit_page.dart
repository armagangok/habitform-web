import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import 'widgets/step_widgets/page_view_step_router.dart';

class CreateHabitPage extends ConsumerStatefulWidget {
  const CreateHabitPage({super.key});

  @override
  ConsumerState<CreateHabitPage> createState() => _CreateHabitPageState();
}

class _CreateHabitPageState extends ConsumerState<CreateHabitPage> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: context.hideKeyboard,
      child: CupertinoPageScaffold(
        navigationBar: SheetHeader(
          title: LocaleKeys.habit_create_habit.tr(),
          closeButtonPosition: CloseButtonPosition.left,
        ),
        child: const SafeArea(
          bottom: true,
          child: PageViewStepRouter(),
        ),
      ),
    );
  }
}
