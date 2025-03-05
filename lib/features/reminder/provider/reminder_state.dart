import 'package:equatable/equatable.dart';

import '../models/reminder/reminder_model.dart';

// State class for reminder
class ReminderState extends Equatable {
  final ReminderModel? reminder;
  final bool isLoading;
  final String? error;

  const ReminderState({
    this.reminder,
    this.isLoading = false,
    this.error,
  });

  @override
  List<Object?> get props => [reminder, isLoading, error];

  ReminderState copyWith({
    ReminderModel? reminder,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ReminderState(
      reminder: reminder ?? this.reminder,
      isLoading: isLoading ?? this.isLoading,
      error: errorMessage ?? error,
    );
  }
}
