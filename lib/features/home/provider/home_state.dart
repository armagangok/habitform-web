import '../../../models/models.dart';

class HomeState {
  final List<Habit> habits;
  final String? errorMessage;

  HomeState({
    required this.habits,
    required this.errorMessage,
  });
}
