class Habit {
  Habit({
    required this.id,
    required this.habitName,
    this.habitDescription,
    required this.completeTime,
    this.icon,
    this.isCompletedToday = false,
  });

  final String id;
  final String habitName;
  final String? habitDescription;
  final DateTime completeTime;
  final String? icon;
  bool isCompletedToday;

  Habit copyWith({
    String? id,
    String? habitName,
    String? habitDescription,
    DateTime? completeTime,
    bool? isCompleted,
    String? icon,
  }) {
    return Habit(
      id: id ?? this.id,
      habitName: habitName ?? this.habitName,
      habitDescription: habitDescription ?? this.habitDescription,
      completeTime: completeTime ?? this.completeTime,
      isCompletedToday: isCompleted ?? isCompletedToday,
      icon: icon ?? this.icon,
    );
  }
}
