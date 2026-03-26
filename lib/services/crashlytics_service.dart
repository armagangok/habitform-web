import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Thin wrapper around [FirebaseCrashlytics].
///
/// All methods are no-ops in debug/web builds so that development output
/// is not polluted with crash reports and Crashlytics is only active in
/// real production builds.
final class CrashlyticsService {
  CrashlyticsService._();

  static final _crashlytics = FirebaseCrashlytics.instance;

  static bool get _isEnabled => !kDebugMode && !kIsWeb;

  /// Records a non-fatal or fatal error to Crashlytics.
  ///
  /// Use [fatal] = true for unhandled exceptions caught at the zone level.
  static Future<void> recordError(
    Object error,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {
    if (!_isEnabled) return;
    await _crashlytics.recordError(
      error,
      stack,
      reason: reason,
      fatal: fatal,
    );
  }

  /// Adds a message to the crash log breadcrumb trail.
  ///
  /// Useful for leaving context before a crash (e.g. "Started sync").
  static void log(String message) {
    if (!_isEnabled) return;
    _crashlytics.log(message);
  }

  /// Associates all subsequent crash reports with [userId].
  ///
  /// Pass an empty string or null to clear the association (on sign-out).
  static Future<void> setUserId(String? userId) async {
    if (!_isEnabled) return;
    await _crashlytics.setUserIdentifier(userId ?? '');
  }

  /// Attaches an arbitrary key-value pair to crash reports.
  ///
  /// Accepted value types: [String], [bool], [int], [double].
  static Future<void> setCustomKey(String key, Object value) async {
    if (!_isEnabled) return;
    await _crashlytics.setCustomKey(key, value);
  }
}
