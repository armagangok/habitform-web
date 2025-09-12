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

  // Check if any days are selected
  bool get hasSelectedDays => reminder?.days?.isNotEmpty ?? false;

  // Check if reminder has any content (days or times)
  bool get hasReminderContent => hasSelectedDays;

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
