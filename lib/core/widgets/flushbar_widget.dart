import 'package:another_flushbar/flushbar.dart';

import '../core.dart';

final class AppFlushbar {
  AppFlushbar._();
  static final shared = AppFlushbar._();

  final context = NavigationService.shared.navigatorKey.currentContext;

  Flushbar<dynamic> errorFlushbar(String message) {
    return Flushbar(
      backgroundColor: context?.theme.scaffoldBackgroundColor.withValues(alpha: .25) ?? Colors.transparent,
      titleText: Text(
        LocaleKeys.common_error.tr(),
        textAlign: TextAlign.left,
        style: context?.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      messageText: Text(
        message,
        textAlign: TextAlign.left,
        style: context?.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      borderRadius: BorderRadius.circular(16),
      borderColor: context?.theme.dividerColor.withAlpha(75),
      borderWidth: 1,
      margin: EdgeInsets.all(20),
      barBlur: 10,
      duration: const Duration(seconds: 4),
      flushbarPosition: FlushbarPosition.TOP,
    )..show(context!);
  }

  Flushbar<dynamic> warningFlushbar(String message) {
    return Flushbar(
      backgroundColor: context?.theme.scaffoldBackgroundColor.withValues(alpha: .25) ?? Colors.transparent,
      titleText: Text(
        LocaleKeys.common_warning.tr(),
        textAlign: TextAlign.left,
        style: context?.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      messageText: Text(
        message,
        textAlign: TextAlign.left,
        style: context?.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      barBlur: 10,
      borderRadius: BorderRadius.circular(16),
      borderColor: context?.theme.dividerColor.withAlpha(75),
      borderWidth: 1,
      margin: EdgeInsets.all(20),
      duration: const Duration(seconds: 4),
      flushbarPosition: FlushbarPosition.TOP,
    )..show(NavigationService.shared.navigatorKey.currentContext!);
  }

  Flushbar<dynamic> successFlushbar(String message) {
    return Flushbar(
      backgroundColor: context?.theme.scaffoldBackgroundColor.withValues(alpha: .25) ?? Colors.transparent,
      titleText: Text(
        LocaleKeys.common_Information.tr(),
        style: context?.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.left,
      ),
      messageText: Text(
        message,
        textAlign: TextAlign.left,
      ),
      barBlur: 10,
      borderRadius: BorderRadius.circular(16),
      borderColor: context?.theme.dividerColor.withAlpha(75),
      borderWidth: 1,
      margin: EdgeInsets.all(20),
      duration: const Duration(seconds: 4),
      flushbarPosition: FlushbarPosition.TOP,
    )..show(NavigationService.shared.navigatorKey.currentContext!);
  }
}
