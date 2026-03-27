import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../../models/app_defaults/app_defaults.dart';
import '../../../services/app_default.dart';
import '../../purchase/providers/purchase_provider.dart';
import '../enum/user_goal_enum.dart';
import 'onboarding_state.dart';

final onboardingProvider = AutoDisposeNotifierProvider<OnboardingNotifier, OnboardingState>(
  OnboardingNotifier.new,
);

class OnboardingNotifier extends AutoDisposeNotifier<OnboardingState> {
  late final PageController pageController;
  AppDefaultsService get _appDefaultsService => AppDefaultsService();

  @override
  OnboardingState build() {
    pageController = PageController();
    ref.onDispose(() => pageController.dispose());
    Future.microtask(() => checkFirstLaunch());
    return const OnboardingState();
  }

  Future<void> checkFirstLaunch() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final appDefaults = await _appDefaultsService.gettAppDefault();
      state = state.copyWith(
        isFirstLaunch: appDefaults?.isAppOpenedFirstTime ?? true,
        hasCheckedFirstLaunch: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        hasCheckedFirstLaunch: true,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> markOnboardingCompleted() async {
    final updatedDefaults = AppDefaults(isAppOpenedFirstTime: false);
    await _appDefaultsService.saveAppDefaults(updatedDefaults);
    state = state.copyWith(
      isFirstLaunch: false,
      hasCheckedFirstLaunch: true,
      isLoading: false,
      error: null,
    );
  }

  Future<void> completeOnboarding(BuildContext context) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await markOnboardingCompleted();

      if (!context.mounted) return;

      ref.read(purchaseProvider.notifier).presentPaywall(isFromOnboarding: true);
    } catch (e, s) {
      LogHelper.shared.debugPrint(e.toString());
      LogHelper.shared.debugPrint(s.toString());
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void toggleGoal(UserGoal goal) {
    final currentGoals = List<UserGoal>.from(state.selectedGoals);
    if (currentGoals.contains(goal)) {
      currentGoals.remove(goal);
    } else {
      currentGoals.add(goal);
    }
    state = state.copyWith(selectedGoals: currentGoals);
  }

  void clearGoals() {
    state = state.copyWith(selectedGoals: []);
  }

  void onPageChanged(int page, int totalPages) {
    state = state.copyWith(
      currentPage: page,
      isLastPage: page == totalPages - 1,
    );
  }

  void nextPage(BuildContext context) {
    if (state.isLastPage) {
      completeOnboarding(context);
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }
}
