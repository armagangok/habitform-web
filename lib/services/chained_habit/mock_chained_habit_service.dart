import '../../models/chained_habit/chained_habit_model.dart';
import 'i_chained_habit_service.dart';
import 'mock_data/chained_habit_mock_data.dart';

final class MockChainedHabitService implements IChainedHabitService {
  @override
  Future<List<ChainedHabit>> fetchChainedHabits() async {
    return chainedHabitMockData;
  }
}
