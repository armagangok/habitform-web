import 'package:habitrise/core/core.dart';

/// Onboarding sayfalarını temsil eden model sınıfı
class OnboardingPageModel {
  /// Sayfa başlığı
  final String title;

  /// Sayfa açıklaması
  final String description;

  /// Sayfa görseli (asset yolu)
  final String imagePath;

  /// Sayfa animasyon dosyası (opsiyonel)
  final String? lottieAnimation;

  /// Sayfa arka plan rengi
  final Color backgroundColor;

  /// Sayfa metin rengi
  final Color textColor;

  /// Sayfa vurgu rengi
  final Color accentColor;

  const OnboardingPageModel({
    required this.title,
    required this.description,
    required this.imagePath,
    this.lottieAnimation,
    required this.backgroundColor,
    required this.textColor,
    required this.accentColor,
  });
}

/// Onboarding sayfaları için önceden tanımlanmış sayfalar
class OnboardingPages {
  static List<OnboardingPageModel> pages = [
    OnboardingPageModel(
      title: LocaleKeys.onboarding_pages_small_steps_title.tr(),
      description: LocaleKeys.onboarding_pages_small_steps_description.tr(),
      imagePath: Assets.images.onboarding.smallSteps.path,
      backgroundColor: Color(0xFF1E1E1E),
      textColor: Colors.white,
      accentColor: Colors.blueAccent,
    ),
    OnboardingPageModel(
      title: LocaleKeys.onboarding_pages_routine_title.tr(),
      description: LocaleKeys.onboarding_pages_routine_description.tr(),
      imagePath: Assets.images.onboarding.waterTree.path,
      backgroundColor: Color(0xFF1E1E1E),
      textColor: Colors.white,
      accentColor: Colors.blueAccent,
    ),
    OnboardingPageModel(
      title: LocaleKeys.onboarding_pages_patience_title.tr(),
      description: LocaleKeys.onboarding_pages_patience_description.tr(),
      imagePath: Assets.images.onboarding.orangeFruit.path,
      backgroundColor: Color(0xFF1E1E1E),
      textColor: Colors.white,
      accentColor: Colors.blueAccent,
    ),
    OnboardingPageModel(
      title: LocaleKeys.onboarding_pages_bad_habits_title.tr(),
      description: LocaleKeys.onboarding_pages_bad_habits_description.tr(),
      imagePath: Assets.images.onboarding.badHabits.path,
      backgroundColor: Color(0xFF1E1E1E),
      textColor: Colors.white,
      accentColor: Colors.blueAccent,
    ),
    OnboardingPageModel(
      title: LocaleKeys.onboarding_pages_become_person_title.tr(),
      description: LocaleKeys.onboarding_pages_become_person_aristotleHabitQuote.tr(),
      imagePath: Assets.images.onboarding.aristoteles.path,
      backgroundColor: Colors.black,
      textColor: Colors.white.withValues(alpha: 0.9),
      accentColor: Colors.blueAccent,
    ),
  ];
}
