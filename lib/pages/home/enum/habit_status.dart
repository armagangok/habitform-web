enum HabitStatus {
  initial,
  loading,
  success,
  failure;

  bool get isInitial => this == HabitStatus.initial;
  bool get isLoading => this == HabitStatus.loading;
  bool get isSuccess => this == HabitStatus.success;
  bool get isFailure => this == HabitStatus.failure;
}
