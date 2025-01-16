part of 'onboarding_bloc.dart';

@immutable
sealed class OnboardingState {}

final class OnboardingInitial extends OnboardingState {}

final class NameInvalid extends OnboardingState {}

final class GoalInvalid extends OnboardingState {}

final class GoalValid extends OnboardingState {}

final class NameValid extends OnboardingState {}

final class OnboardingTemplateGenerateEvent extends OnboardingState {}
