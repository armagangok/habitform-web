import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/features/home/provider/home_provider.dart';
import '../../provider/statistics_state.dart';
import 'habit_selector_button.dart';

// Alışkanlık seçici widget
class HabitSelector extends ConsumerWidget {
  const HabitSelector({
    super.key,
    required this.selectedHabitIndex,
    required this.habitStats,
    required this.onHabitSelected,
  });

  final int selectedHabitIndex;
  final List<HabitStatistic> habitStats;
  final Function(int) onHabitSelected;

  String _getEmojiForHabit(String habitName, WidgetRef ref) {
    // Önce HomeProvider'dan emoji bilgisini almaya çalış
    final homeState = ref.watch(homeProvider);

    return homeState.when(
      data: (data) {
        // Habit adına göre eşleşen alışkanlığı bul
        final matchingHabit = data.habits.where((h) => h.habitName == habitName).firstOrNull;
        if (matchingHabit != null && matchingHabit.emoji != null && matchingHabit.emoji!.isNotEmpty) {
          return matchingHabit.emoji!;
        }

        // Eşleşme bulunamazsa varsayılan emoji eşleştirmesini kullan
        return _getDefaultEmoji(habitName);
      },
      loading: () => _getDefaultEmoji(habitName),
      error: (_, __) => _getDefaultEmoji(habitName),
    );
  }

  String _getDefaultEmoji(String habitName) {
    // Varsayılan emoji olarak yıldız kullan
    return '✨';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Eğer hiç alışkanlık yoksa veya seçili alışkanlık yoksa (-1), ilk alışkanlığı seç
    if (habitStats.isNotEmpty && selectedHabitIndex == -1) {
      // İlk alışkanlığı seç
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onHabitSelected(0);
      });
    }

    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // Alışkanlık butonları
            for (int i = 0; i < habitStats.length; i++)
              HabitSelectorButton(
                isSelected: i == selectedHabitIndex,
                emoji: _getEmojiForHabit(habitStats[i].habitName, ref),
                habitName: habitStats[i].habitName,
                onTap: () => onHabitSelected(i),
              ),
          ],
        ),
      ),
    );
  }
}
