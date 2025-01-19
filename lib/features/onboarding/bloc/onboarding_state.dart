part of 'onboarding_bloc.dart';

@immutable
sealed class OnboardingState {}

class OnboardingInitial extends OnboardingState {}

class OnboardingCompleted extends OnboardingState {}

class OnboardingSkipped extends OnboardingState {}

class OnboardingRequired extends OnboardingState {}

class OnboardingError extends OnboardingState {
  final String error;
  OnboardingError(this.error);
}

// final class OnboardingTemplateGenerateEvent extends OnboardingState {}
