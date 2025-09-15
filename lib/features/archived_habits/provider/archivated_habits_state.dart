import '../../../models/models.dart';

class ArchivedHabitsState {
  final List<Habit> archivedHabits;
  final bool isLoading;
  final String? error;
  final String? successMessage;
  final bool isSelectionMode;
  final Set<String> selectedHabitIds;

  const ArchivedHabitsState({
    this.archivedHabits = const [],
    this.isLoading = false,
    this.error,
    this.successMessage,
    this.isSelectionMode = false,
    this.selectedHabitIds = const {},
  });

  ArchivedHabitsState copyWith({
    List<Habit>? archivedHabits,
    bool? isLoading,
    String? error,
    String? successMessage,
    bool? isSelectionMode,
    Set<String>? selectedHabitIds,
  }) {
    return ArchivedHabitsState(
      archivedHabits: archivedHabits ?? this.archivedHabits,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedHabitIds: selectedHabitIds ?? this.selectedHabitIds,
    );
  }
}
