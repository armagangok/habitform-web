import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '../models/onboarding_page_model.dart';
import '../providers/onboarding_provider.dart';
import '../providers/onboarding_state.dart';
import '../widgets/onboarding_button.dart';
import '../widgets/onboarding_page_widget.dart';

class OnboardingMainPage extends ConsumerWidget {
  const OnboardingMainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingProvider);
    final onboardingNotifier = ref.read(onboardingProvider.notifier);

    return CupertinoPageScaffold(
      child: Stack(
        children: [
          // Sayfa içeriği
          PageView.builder(
            controller: onboardingNotifier.pageController,
            onPageChanged: (page) => onboardingNotifier.onPageChanged(page, OnboardingPages.pages.length),
            itemCount: OnboardingPages.pages.length,
            itemBuilder: (context, index) {
              return OnboardingPageWidget(
                pageModel: OnboardingPages.pages[index],
                isLastPage: index == OnboardingPages.pages.length - 1,
              );
            },
          ),
    
          // Sayfa göstergeleri
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  OnboardingPages.pages.length,
                  (index) => _buildPageIndicator(index, onboardingState, context),
                ),
              ),
            ),
          ),
    
          // Devam et butonu
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: Animate(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OnboardingButton(
                        onPressed: () => onboardingNotifier.nextPage(context),
                        buttonText: onboardingState.isLastPage ? LocaleKeys.onboarding_start_button.tr() : LocaleKeys.onboarding_continue_button.tr(),
                      ),
                    ],
                  ),
                ).fadeIn(duration: 600.ms, delay: 800.ms),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index, OnboardingState state, BuildContext context) {
    final isActive = index == state.currentPage;
    final color = OnboardingPages.pages[state.currentPage].accentColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? color : color.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
