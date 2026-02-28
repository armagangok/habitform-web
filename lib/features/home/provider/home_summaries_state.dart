// This file defines the state for the home page summaries

import '/models/habit/habit_summary.dart';

/// State class for the home page summaries (lightweight data)
class HomeSummariesState {
  final List<HabitSummary> summaries;

  const HomeSummariesState({
    required this.summaries,
  });

  /// Creates a copy of this state with the given fields replaced with new values
  HomeSummariesState copyWith({
    List<HabitSummary>? summaries,
  }) {
    return HomeSummariesState(
      summaries: summaries ?? this.summaries,
    );
  }
}
