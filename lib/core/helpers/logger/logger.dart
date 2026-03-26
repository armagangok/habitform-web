import 'package:logger/logger.dart';

import '../../../services/crashlytics_service.dart';
import '../../constants/debug_constants.dart';

class LogHelper {
  LogHelper._();
  static final shared = LogHelper._();

  final _logger = Logger();

  void debugPrint(String message) {
    if (KDebug.logDebugMode) _logger.d(message);
  }

  void warningPrint(String message) {
    if (KDebug.logDebugMode) _logger.w(message);
  }

  /// Logs an error locally (debug only) and always forwards it to Crashlytics
  /// as a non-fatal crash so production issues are visible in Firebase Console.
  void errorPrint(String message, [Object? error, StackTrace? stackTrace]) {
    if (KDebug.logDebugMode) _logger.e(message, error: error, stackTrace: stackTrace);
    CrashlyticsService.recordError(
      error ?? message,
      stackTrace,
      reason: message,
    );
  }

  void whatTheFuckPrint(String message) {
    if (KDebug.logDebugMode) _logger.f(message);
  }

  String getError({
    String? errorMessage,
    required String errorCode,
    required String methodCode,
  }) {
    final errorText = errorMessage ?? 'Something went wrong.';
    errorPrint('ERROR OCCURED -> Code: $errorCode$methodCode');
    return '$errorText | Code: $errorCode$methodCode';
  }
}
