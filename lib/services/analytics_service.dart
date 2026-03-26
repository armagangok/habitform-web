import 'package:firebase_analytics/firebase_analytics.dart';

/// Wrapper around [FirebaseAnalytics] for structured event and user tracking.
///
/// Usage:
/// ```dart
/// AnalyticsService.logOnboardingStep('welcome_completed');
/// AnalyticsService.logPaywallShown(source: 'onboarding', userGoal: 'getHealthier');
/// AnalyticsService.logPaywallConverted(plan: 'yearly');
/// AnalyticsService.setUserId('uid_123');
/// AnalyticsService.setUserProperty(name: 'is_pro', value: 'true');
/// AnalyticsService.logScreenView('home_page');
/// ```
class AnalyticsService {
  AnalyticsService._();

  static final _analytics = FirebaseAnalytics.instance;

  // ─── Identity ────────────────────────────────────────────────────────────

  /// Associates analytics events with [userId].
  ///
  /// Pass null to clear the association (e.g. on sign-out).
  static Future<void> setUserId(String? userId) async {
    await _analytics.setUserId(id: userId);
  }

  /// Sets a user-scoped property that persists across sessions.
  ///
  /// Property [name] must be 1–24 alphanumeric chars / underscores.
  /// [value] should be a short string (max 36 chars).
  static Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  // ─── Screen Tracking ─────────────────────────────────────────────────────

  /// Logs a screen view event.
  ///
  /// Call this inside [NavigatorObserver.didPush] or page [initState].
  static Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  // ─── Onboarding Funnel ───────────────────────────────────────────────────

  /// Tracks each step the user completes in the onboarding flow.
  static Future<void> logOnboardingStep(String step) async {
    await _analytics.logEvent(
      name: 'onboarding_step_completed',
      parameters: {'step': step},
    );
  }

  // ─── Paywall ─────────────────────────────────────────────────────────────

  /// Fired when the paywall screen becomes visible.
  static Future<void> logPaywallShown({
    required String source,
    String? userGoal,
  }) async {
    await _analytics.logEvent(
      name: 'paywall_shown',
      parameters: {
        'source': source,
        'user_goal': userGoal ?? 'none',
      },
    );
  }

  /// Fired when the user successfully completes a purchase.
  static Future<void> logPaywallConverted({
    required String plan,
  }) async {
    await _analytics.logEvent(
      name: 'paywall_converted',
      parameters: {'plan': plan},
    );
  }

  // ─── Generic ─────────────────────────────────────────────────────────────

  /// Log a custom event with optional parameters.
  static Future<void> logEvent(
    String name, [
    Map<String, Object>? parameters,
  ]) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }
}
