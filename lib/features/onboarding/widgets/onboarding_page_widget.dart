import '/core/core.dart';
import '../models/onboarding_page_model.dart';

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPageModel pageModel;
  final bool isLastPage;

  const OnboardingPageWidget({
    super.key,
    required this.pageModel,
    required this.isLastPage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: pageModel.backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 1),
            // Görsel
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Stack(
                  children: [
                    Center(
                      child: Animate(
                        child: Image.asset(
                          pageModel.imagePath,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    if (isLastPage)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 30,
                          width: double.infinity,
                          color: Colors.black.withValues(alpha: 0.5),
                          child: Center(
                            child: Text(
                              LocaleKeys.onboarding_pages_become_person_aristotle.tr(),
                              textAlign: TextAlign.left,
                              style: context.bodyLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ).animate().fadeIn(duration: 600.ms, delay: 300.ms).scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1, 1),
                      duration: 600.ms,
                      curve: Curves.easeOutBack,
                    ),
              ),
            ),
            const Spacer(flex: 1),
            // Başlık ve açıklama
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Animate(
                      child: Text(
                        pageModel.title,
                        textAlign: TextAlign.center,
                        style: context.headlineMedium.copyWith(
                          color: pageModel.textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ).fadeIn(duration: 600.ms, delay: 400.ms).slideY(
                          begin: 0.2,
                          end: 0,
                          duration: 600.ms,
                          curve: Curves.easeOutBack,
                        ),
                    const SizedBox(height: 16),
                    Animate(
                      child: Text(
                        pageModel.description,
                        textAlign: TextAlign.center,
                        style: context.bodyLarge.copyWith(
                          color: pageModel.textColor.withValues(alpha: 0.8),
                        ),
                      ),
                    ).fadeIn(duration: 600.ms, delay: 500.ms).slideY(
                          begin: 0.2,
                          end: 0,
                          duration: 600.ms,
                          curve: Curves.easeOutBack,
                        ),
                  ],
                ),
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
