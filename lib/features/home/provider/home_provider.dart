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
