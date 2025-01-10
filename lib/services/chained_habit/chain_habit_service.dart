import '../../models/chained_habit/chained_habit_model.dart';
import 'i_chained_habit_service.dart';

final class ChainedHabitService implements IChainedHabitService {
  
  @override
  Future<List<ChainedHabit>> fetchChainedHabits() async {
    await Future.delayed(Duration(milliseconds: 250));

    return [];
  }
}
