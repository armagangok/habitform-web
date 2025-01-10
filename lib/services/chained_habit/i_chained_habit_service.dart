import '../../models/models.dart';

abstract interface class IChainedHabitService {
  Future<List<ChainedHabit>> fetchChainedHabits();
}
