enum OnboardingStep {
  initial,
  cardsStackedAtBottom,
  exerciseCardInCenter,
}

extension OnboardingStepExtension on OnboardingStep {
  String get name {
    switch (this) {
      case OnboardingStep.initial:
        return 'Initial Step';
      case OnboardingStep.cardsStackedAtBottom:
        return 'Cards Stacked at Bottom';
      case OnboardingStep.exerciseCardInCenter:
        return 'Exercise Card in Center';
    }
  }
}
