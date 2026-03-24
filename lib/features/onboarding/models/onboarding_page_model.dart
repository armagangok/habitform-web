import '../../../core/core.dart';

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

