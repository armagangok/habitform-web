import '../../../models/models.dart';

// Define enum for time of day filter options
enum TimeOfDayFilter {
  all,
  morning,
  afternoon,
  evening,
}

class HomeState {
  final List<Habit> habits;
  final TimeOfDayFilter timeFilter;

  const HomeState({
    required this.habits,
    this.timeFilter = TimeOfDayFilter.all,
  });

  // Factory constructor for initial state
  factory HomeState.initial() => const HomeState(
        habits: [],
        timeFilter: TimeOfDayFilter.all,
      );

  // CopyWith method for immutability
  HomeState copyWith({
    List<Habit>? habits,
    TimeOfDayFilter? timeFilter,
  }) {
    return HomeState(
      habits: habits ?? this.habits,
      timeFilter: timeFilter ?? this.timeFilter,
    );
  }

  // Get filtered habits based on time of day filter
  List<Habit> get filteredHabits {
    if (timeFilter == TimeOfDayFilter.all) {
      return habits;
    }

    return habits.where((habit) {
      final reminderTime = habit.reminderModel?.reminderTime;
      if (reminderTime == null) {
        return false; // If no reminder time, don't include in filtered results
      }

      final hour = reminderTime.hour;

      switch (timeFilter) {
        case TimeOfDayFilter.morning:
          return hour >= 5 && hour < 12; // 5:00 AM - 11:59 AM
        case TimeOfDayFilter.afternoon:
          return hour >= 12 && hour < 18; // 12:00 PM - 5:59 PM
        case TimeOfDayFilter.evening:
          return hour >= 18 || hour < 5; // 6:00 PM - 4:59 AM
        default:
          return true;
      }
    }).toList();
  }
}
