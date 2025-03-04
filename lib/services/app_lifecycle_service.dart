import 'package:habitrise/core/core.dart';

/// Uygulama yaşam döngüsü servis sınıfı.
/// Bu sınıf, uygulama yaşam döngüsü olaylarını dinler ve gerekli işlemleri tetikler.
class AppLifecycleService with WidgetsBindingObserver {
  bool _initialized = false;

  AppLifecycleService();

  /// Servisi başlatır ve yaşam döngüsü olaylarını dinlemeye başlar
  void initialize() {
    if (_initialized) return;

    WidgetsBinding.instance.addObserver(this);
    LogHelper.shared.debugPrint('AppLifecycleService initialized');
    _initialized = true;
  }

  /// Servisi durdurur ve yaşam döngüsü olaylarını dinlemeyi bırakır
  void dispose() {
    if (!_initialized) return;

    WidgetsBinding.instance.removeObserver(this);
    LogHelper.shared.debugPrint('AppLifecycleService disposed');
    _initialized = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    LogHelper.shared.debugPrint('App lifecycle state changed to: $state');

    // Uygulama arka plana geçtiğinde veya tamamen kapandığında senkronizasyon yap
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      LogHelper.shared.debugPrint('App is closing or going to background, triggering auto sync');
    } else if (state == AppLifecycleState.resumed) {
      LogHelper.shared.debugPrint('App is resuming from background, triggering auto sync');
    }
  }
}
