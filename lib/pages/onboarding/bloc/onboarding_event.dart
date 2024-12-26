part of 'onboarding_bloc.dart';

@immutable
sealed class OnboardingEvent {}

 class OnboardingInitialEvent extends OnboardingEvent{}

class SelectGoalEvent extends OnboardingEvent {
  final List<int> goals;
  SelectGoalEvent({
    required this.goals,
  });
}

class NameChangedEvent extends OnboardingEvent {
  final String name;

  NameChangedEvent(this.name);
}
