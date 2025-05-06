// This file defines the state for the home page

import '/models/habit/habit_model.dart';

/// State class for the home page
class HomeState {
  final List<Habit> habits;

  const HomeState({
    required this.habits,
  });

  /// Creates a copy of this state with the given fields replaced with new values
  HomeState copyWith({
    List<Habit>? habits,
  }) {
    return HomeState(
      habits: habits ?? this.habits,
    );
  }
}
