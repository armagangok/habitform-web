import '../../../models/models.dart';

class ArchivedHabitsState {
  final List<Habit> archivedHabits;
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const ArchivedHabitsState({
    this.archivedHabits = const [],
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  ArchivedHabitsState copyWith({
    List<Habit>? archivedHabits,
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return ArchivedHabitsState(
      archivedHabits: archivedHabits ?? this.archivedHabits,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}
