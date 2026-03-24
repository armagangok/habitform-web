import 'package:logger/logger.dart';

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

  void errorPrint(String message, [Object? error, StackTrace? stackTrace]) {
    if (KDebug.logDebugMode) _logger.e(message, error: error, stackTrace: stackTrace);
  }

  void whatTheFuckPrint(String message) {
    if (KDebug.logDebugMode) _logger.f(message);
  }

  String getError({
    String? errorMessage,
    required String errorCode,
    required String methodCode,
  }) {
    var errorText = errorMessage ?? "Something went wrong.";
    errorPrint("ERROR OCCURED -> Code: $errorCode$methodCode");
    return "$errorText | Code: $errorCode$methodCode";
  }
}
