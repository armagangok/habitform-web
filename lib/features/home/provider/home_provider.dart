import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/models/completion_entry/completion_entry.dart';
import '/models/habit/habit_model.dart';
import '../../../services/local_habit_service.dart';

final homeProvider = AsyncNotifierProvider<HomeNotifier, List<Habit>>(() {
  return HomeNotifier();
});

class HomeNotifier extends AsyncNotifier<List<Habit>> {
  final LocalHabitService _habitService = LocalHabitService.instance;

  @override
  Future<List<Habit>> build() async {
    // İnternet bağlantısı varsa senkronizasyon yap

    return fetchHabits();
  }

  Future<List<Habit>> fetchHabits() async {
    state = const AsyncValue.loading();

    try {
      final habits = await _habitService.getHabits();
      state = AsyncValue.data(habits);
      return habits;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return [];
    }
  }

  Future<void> archiveHabit(Habit habit) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      // Önce LocalHabitService ile arşivleme işlemini gerçekleştir
      await _habitService.archiveHabit(habit);

      return fetchHabits();
    });
  }

  Future<void> updateHabitCompletionStatus(String habitId, CompletionEntry completion) async {
    // Mevcut state'i al
    final currentState = state;
    if (currentState is AsyncData<List<Habit>>) {
      // Mevcut alışkanlıkları al
      final habits = List<Habit>.from(currentState.value);

      // Güncellenecek alışkanlığın indeksini bul
      final habitIndex = habits.indexWhere((h) => h.id == habitId);

      if (habitIndex != -1) {
        // Alışkanlığı al
        final habit = habits[habitIndex];

        // Tamamlanma durumlarını güncelle
        final updatedCompletions = Map<String, CompletionEntry>.from(habit.completions);
        updatedCompletions[completion.id] = completion;

        // Güncellenmiş alışkanlığı oluştur
        final updatedHabit = habit.copyWith(
          completions: updatedCompletions,
        );

        // Listedeki alışkanlığı güncelle
        habits[habitIndex] = updatedHabit;

        // State'i güncelle (yükleme durumu olmadan)
        state = AsyncData(habits);

        // Arka planda veritabanını güncelle
        _habitService.updateHabitCompletionStatus(habitId, completion);
        return;
      }
    }

    // Eğer mevcut state AsyncData değilse veya alışkanlık bulunamazsa
    // eski yöntemi kullan (yükleme durumu göster)
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      // Önce LocalHabitService ile tamamlanma durumunu güncelle
      await _habitService.updateHabitCompletionStatus(habitId, completion);

      return fetchHabits();
    });
  }

  Future<void> createHabit(Habit habit) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      // Önce LocalHabitService ile yeni alışkanlık oluştur
      await _habitService.createHabit(habit);

      return fetchHabits();
    });
  }

  Future<void> updateHabit(Habit habit) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      // Önce LocalHabitService ile alışkanlığı güncelle
      await _habitService.updateHabit(habit);

      return fetchHabits();
    });
  }

  Future<void> deleteHabit(String habitId) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      // Önce LocalHabitService ile alışkanlığı sil
      await _habitService.deleteHabit(habitId);

      return fetchHabits();
    });
  }
}
