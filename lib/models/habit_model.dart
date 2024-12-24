class Habit {
  Habit({
    required this.id,
    required this.habitName,
    this.habitDescription,
    required this.completeTime,
    this.icon,
    this.isCompleted = false,
  });

  final String id;
  final String habitName;
  final String? habitDescription;
  final DateTime completeTime;
  final String? icon;
  bool isCompleted;

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
      isCompleted: isCompleted ?? this.isCompleted,
      icon: icon ?? this.icon,
    );
  }
}
