import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../../models/app_defaults/app_defaults.dart';
import '../../../services/app_default.dart';
import '../../purchase/page/paywall_page.dart';
import '../enum/user_goal_enum.dart';
import '../models/onboarding_page_model.dart';
import 'onboarding_state.dart';

final onboardingProvider = StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier(AppDefaultsService());
});

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final AppDefaultsService _appDefaultsService;
  late final PageController pageController;

  OnboardingNotifier(this._appDefaultsService) : super(const OnboardingState()) {
    pageController = PageController();
    checkFirstLaunch();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Future<void> checkFirstLaunch() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final appDefaults = await _appDefaultsService.gettAppDefault();
      state = state.copyWith(
        isFirstLaunch: appDefaults?.isAppOpenedFirstTime ?? true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> completeOnboarding(BuildContext context) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedDefaults = AppDefaults(isAppOpenedFirstTime: false);
      await _appDefaultsService.saveAppDefaults(updatedDefaults);
      state = state.copyWith(
        isFirstLaunch: false,
        isLoading: false,
      );

      if (!context.mounted) return;

      showCupertinoModalBottomSheet(
        context: context,
        enableDrag: false,
        expand: true,
        barrierColor: Colors.black,
        builder: (context) => const PaywallPage(isFromOnboarding: true),
      );
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
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void skipToLastPage() {
    pageController.animateToPage(
      OnboardingPages.pages.length - 1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
}
