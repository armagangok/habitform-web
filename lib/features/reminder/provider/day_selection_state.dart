import '../models/days/days_enum.dart';

class DaySelectionState {
  final List<Days> selectedDays;
  final String? error;

  const DaySelectionState({
    this.selectedDays = const [],
    this.error,
  });

  DaySelectionState copyWith({
    List<Days>? selectedDays,
    String? error,
  }) {
    return DaySelectionState(
      selectedDays: selectedDays ?? this.selectedDays,
      error: error,
    );
  }
}
