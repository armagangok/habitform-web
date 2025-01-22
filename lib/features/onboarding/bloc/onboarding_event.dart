// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'onboarding_bloc.dart';

@immutable
sealed class OnboardingEvent {}

class OnboardingInitialEvent extends OnboardingEvent {}

class SelectGoalEvent extends OnboardingEvent {
  final List<UserGoal> goals;
  SelectGoalEvent({
    required this.goals,
  });
}

class NameChangedEvent extends OnboardingEvent {
  final String name;

  NameChangedEvent(this.name);
}

class CompleteOnboardingEvent extends OnboardingEvent {}

class CheckFirstLaunchEvent extends OnboardingEvent {}

// class GetHabitRiseProEvent extends OnboardingEvent {
//   final BuildContext context;

//   GetHabitRiseProEvent({required this.context});
// }

// class GenerateHabitTemplateEvent extends OnboardingEvent {}

// class GoToHomePageEvent extends OnboardingEvent {}
