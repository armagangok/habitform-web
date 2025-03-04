import '../enum/user_goal_enum.dart';

class OnboardingState {
  final bool isFirstLaunch;
  final bool isLoading;
  final String? error;
  final String? name;
  final List<UserGoal> selectedGoals;
  final int currentPage;
  final bool isLastPage;

  const OnboardingState({
    this.isFirstLaunch = true,
    this.isLoading = false,
    this.error,
    this.name,
    this.selectedGoals = const [],
    this.currentPage = 0,
    this.isLastPage = false,
  });

  OnboardingState copyWith({
    bool? isFirstLaunch,
    bool? isLoading,
    String? error,
    String? name,
    List<UserGoal>? selectedGoals,
    int? currentPage,
    bool? isLastPage,
  }) {
    return OnboardingState(
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      name: name ?? this.name,
      selectedGoals: selectedGoals ?? this.selectedGoals,
      currentPage: currentPage ?? this.currentPage,
      isLastPage: isLastPage ?? this.isLastPage,
    );
  }
}
