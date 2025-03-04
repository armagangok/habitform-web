class RemindTimeState {
  final DateTime? time;
  final String? error;

  const RemindTimeState({
    this.time,
    this.error,
  });

  RemindTimeState copyWith({
    DateTime? time,
    String? error,
  }) {
    return RemindTimeState(
      time: time ?? this.time,
      error: error,
    );
  }

  bool get hasTime => time != null;
}
