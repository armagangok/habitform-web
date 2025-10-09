import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/features/home/provider/home_provider.dart';
import '/models/habit/habit_model.dart';
import '/services/habit_service/mock_habit_service.dart';
import '../../provider/habit_probability_provider.dart';
import '../../provider/habit_probability_state.dart';
import '../../provider/selected_habit_index_provider.dart';
import 'habit_selector_button.dart';

// Mock habit service provider
final mockHabitsProvider = FutureProvider<List<Habit>>((ref) async {
  final mockService = MockHabitService();
  return await mockService.getHabits();
});

// Alışkanlık seçici widget
class HabitSelector extends ConsumerWidget {
  const HabitSelector({
    super.key,
    required this.habitStats,
    required this.onHabitSelected,
  });

  final List<HabitStatistic> habitStats;
  final Function(int) onHabitSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedHabitIndex = ref.watch(selectedHabitIndexProvider);
    // Eğer hiç alışkanlık yoksa veya seçili alışkanlık yoksa (-1), ilk alışkanlığı seç
    if (habitStats.isNotEmpty && selectedHabitIndex == -1) {
      // İlk alışkanlığı seç
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onHabitSelected(0);
      });
    }

    // If we have habits but no selected habit, make sure to select the first one
    // This is especially important for mock data
    if (habitStats.isNotEmpty && (selectedHabitIndex < 0 || selectedHabitIndex >= habitStats.length)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onHabitSelected(0);
      });
    }

    // Check if we're using mock data
    final statisticsState = ref.watch(probabilityProvider);
    final isMockData = statisticsState.value?.isMockData ?? false;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          width: double.infinity,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Alışkanlık butonları
                for (int i = 0; i < habitStats.length; i++) isMockData ? _buildMockHabitButton(context, ref, i, habitStats[i], selectedHabitIndex) : _buildRealHabitButton(context, ref, i, habitStats[i], selectedHabitIndex),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Build a habit button for real data
  Widget _buildRealHabitButton(BuildContext context, WidgetRef ref, int index, HabitStatistic habitStat, int selectedHabitIndex) {
    final homeState = ref.watch(homeProvider);

    return homeState.when(
      data: (data) {
        // Find the matching habit to get its emoji
        final matchingHabit = data.habits.where((h) => h.id == habitStat.habitId).firstOrNull;
        final emoji = matchingHabit?.emoji ?? '✨';

        return HabitSelectorButton(
          isSelected: index == selectedHabitIndex,
          emoji: emoji,
          habitName: habitStat.habitName,
          onTap: () => onHabitSelected(index),
        );
      },
      loading: () => HabitSelectorButton(
        isSelected: index == selectedHabitIndex,
        emoji: '✨',
        habitName: habitStat.habitName,
        onTap: () => onHabitSelected(index),
      ),
      error: (_, __) => HabitSelectorButton(
        isSelected: index == selectedHabitIndex,
        emoji: '✨',
        habitName: habitStat.habitName,
        onTap: () => onHabitSelected(index),
      ),
    );
  }

  // Build a habit button for mock data
  Widget _buildMockHabitButton(BuildContext context, WidgetRef ref, int index, HabitStatistic habitStat, int selectedHabitIndex) {
    final mockHabitsAsync = ref.watch(mockHabitsProvider);

    return mockHabitsAsync.when(
      data: (mockHabits) {
        // Find the matching mock habit to get its emoji
        final matchingHabit = mockHabits.where((h) => h.id == habitStat.habitId || h.habitName == habitStat.habitName).firstOrNull;

        final emoji = matchingHabit?.emoji ?? '✨';

        return HabitSelectorButton(
          isSelected: index == selectedHabitIndex,
          emoji: emoji,
          habitName: habitStat.habitName,
          onTap: () => onHabitSelected(index),
        );
      },
      loading: () => HabitSelectorButton(
        isSelected: index == selectedHabitIndex,
        emoji: '✨',
        habitName: habitStat.habitName,
        onTap: () => onHabitSelected(index),
      ),
      error: (_, __) => HabitSelectorButton(
        isSelected: index == selectedHabitIndex,
        emoji: '✨',
        habitName: habitStat.habitName,
        onTap: () => onHabitSelected(index),
      ),
    );
  }
}
