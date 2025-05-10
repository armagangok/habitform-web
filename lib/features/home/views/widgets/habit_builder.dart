import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import '/core/core.dart';
import '../../../../models/models.dart';
import '../../../create_habit/create_habit_page.dart';
import '../../../create_habit/provider/create_habit_provider.dart';
import '../../../purchase/page/paywall_page.dart';
import '../../provider/home_provider.dart';
import 'habit_widget.dart';

class HabitBuilder extends ConsumerWidget {
  final List<Habit> habits;
  final bool isLoading;

  const HabitBuilder({
    super.key,
    required this.habits,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoActivityIndicator(),
            SizedBox(height: 10),
            Text(
              LocaleKeys.common_loading_habits.tr(),
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.theme.hintColor,
              ),
            ),
          ],
        ),
      );
    }

    if (habits.isEmpty) {
      // No habits at all
      return _noDataWidget(ref);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: SafeArea(
        top: false,
        bottom: false,
        child: _buildHabitList(habits),
      ),
    );
  }

  Widget _buildHabitList(List<Habit> habits) {
    return Builder(
      builder: (context) {
        if (context.isTabletOrLandscape) {
          return SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Wrap(
              spacing: 24,
              runSpacing: 24,
              alignment: WrapAlignment.center,
              children: habits.map((habit) {
                return SizedBox(
                  width: (context.dynamicWidth - 185) / 2,
                  child: HabitWidget(habit: habit),
                );
              }).toList(),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: ClampingScrollPhysics(),
                itemCount: habits.length,
                itemBuilder: (context, index) {
                  final habit = habits[index];
                  final remindTime = habit.reminderModel?.reminderTime;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      HabitWidget(habit: habit),
                      SizedBox(
                        width: 50,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 5),
                            if (remindTime != null) ...[
                              SizedBox(height: 4),
                              Text(
                                remindTime.toHHMM(),
                                style: context.bodySmall,
                              ),
                            ],
                            if (habits.isNotLast(index)) ...[
                              SizedBox(height: 10),
                              SizedBox(
                                height: 20,
                                child: VerticalDivider(),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ],
                  );
                },
                separatorBuilder: (context, index) => SizedBox(height: 10),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _noDataWidget(WidgetRef ref) => Builder(
        builder: (context) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Lottie.asset(
                Assets.animations.astronout,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 30),
              Text(
                LocaleKeys.habit_no_habit_found.tr(),
                style: context.titleLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15),
              CupertinoButton.tinted(
                color: Colors.blueAccent,
                sizeStyle: CupertinoButtonSize.medium,
                child: Text(
                  LocaleKeys.habit_create_habit.tr(),
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.blueAccent,
                  ),
                ),
                onPressed: () async {
                  final homeState = ref.read(homeProvider).value;
                  if (homeState != null) {
                    final canCreate = await ref.read(createHabitProvider.notifier).canCreateHabit(homeState.habits.length);
                    if (canCreate) {
                      CupertinoScaffold.showCupertinoModalBottomSheet(
                        enableDrag: false,
                        context: context,
                        builder: (contextFromSheet) {
                          return CreateHabitPage();
                        },
                      );
                    } else {
                      CupertinoScaffold.showCupertinoModalBottomSheet(
                        enableDrag: false,
                        context: context,
                        builder: (_) => PaywallPage(),
                      );
                    }
                  }
                },
              ),
            ],
          );
        },
      );
}
