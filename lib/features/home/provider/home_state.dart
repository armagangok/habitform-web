import '../../../models/models.dart';

// Define enum for time of day filter options
enum TimeOfDayFilter {
  all,
  morning,
  noon,

  evening,
  night,
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
    List<Habit> result;

    if (timeFilter == TimeOfDayFilter.all) {
      result = List<Habit>.from(habits);
    } else {
      result = habits.where((habit) {
        final reminderTime = habit.reminderModel?.reminderTime;
        if (reminderTime == null) {
          return false; // If no reminder time, don't include in filtered results
        }

        final hour = reminderTime.hour;

        switch (timeFilter) {
          case TimeOfDayFilter.morning:
            return hour >= 5 && hour < 12; // 5:00 AM - 11:59 AM
          case TimeOfDayFilter.noon:
            return hour >= 12 && hour < 18; // 12:00 PM - 5:59 PM
          case TimeOfDayFilter.evening:
            return hour >= 18 && hour < 24; // 6:00 PM - 11:59 PM
          case TimeOfDayFilter.night:
            return hour >= 0 && hour < 5; // 12:00 AM - 4:59 AM
          default:
            return true;
        }
      }).toList();
    }

    // Sort habits by reminder time
    result.sort((a, b) {
      final timeA = a.reminderModel?.reminderTime;
      final timeB = b.reminderModel?.reminderTime;

      // If either habit doesn't have a reminder time, put it at the end
      if (timeA == null) return 1;
      if (timeB == null) return -1;

      // Convert both times to minutes since midnight for comparison
      final minutesA = timeA.hour * 60 + timeA.minute;
      final minutesB = timeB.hour * 60 + timeB.minute;

      return minutesA.compareTo(minutesB);
    });

    return result;
  }
}
