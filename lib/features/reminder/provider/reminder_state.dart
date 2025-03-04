// State class for reminder
import '../models/reminder/reminder_model.dart';

class ReminderState {
  final ReminderModel? reminder;
  final bool isLoading;
  final String? error;

  const ReminderState({
    this.reminder,
    this.isLoading = false,
    this.error,
  });

  ReminderState copyWith({
    ReminderModel? reminder,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ReminderState(
      reminder: reminder ?? this.reminder,
      isLoading: isLoading ?? this.isLoading,
      error: errorMessage ?? this.error,
    );
  }
}
