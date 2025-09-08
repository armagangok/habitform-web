import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/core.dart';
import '../../models/create_habit_step.dart';
import '../../provider/create_habit_provider.dart';
import 'category_step.dart';
import 'color_step.dart';
import 'description_step.dart';
import 'difficulty_step.dart';
import 'emoji_step.dart';
import 'habit_name_step.dart';
import 'reminder_step.dart';

class PageViewStepRouter extends ConsumerStatefulWidget {
  const PageViewStepRouter({super.key});

  @override
  ConsumerState<PageViewStepRouter> createState() => _PageViewStepRouterState();
}

class _PageViewStepRouterState extends ConsumerState<PageViewStepRouter> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to step changes from provider
    ref.listen(createHabitProvider, (previous, next) {
      if (next.hasValue && next.value != null) {
        final currentStep = next.value!.currentStep;
        final stepIndex = CreateHabitStep.values.indexOf(currentStep);
        if (stepIndex != _currentPage) {
          _pageController.animateToPage(
            stepIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          setState(() {
            _currentPage = stepIndex;
          });
        }
      }
    });

    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(), // Disable manual swiping
      onPageChanged: (index) {
        setState(() {
          _currentPage = index;
        });
      },
      children: const [
        HabitNameStep(),
        DescriptionStep(),
        EmojiStep(),
        ColorStep(),
        ReminderStep(),
        CategoryStep(),
        DifficultyStep(),
      ],
    );
  }
}
