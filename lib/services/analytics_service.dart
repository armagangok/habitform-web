import 'package:firebase_analytics/firebase_analytics.dart';

/// Lightweight analytics wrapper for onboarding funnel tracking.
///
/// Usage:
/// ```dart
/// AnalyticsService.logOnboardingStep('welcome_completed');
/// AnalyticsService.logPaywallShown(source: 'onboarding', userGoal: 'getHealthier');
/// AnalyticsService.logPaywallConverted(plan: 'yearly');
/// ```
class AnalyticsService {
  AnalyticsService._();

  static final _analytics = FirebaseAnalytics.instance;

  // ─── Onboarding Funnel ──────────────────────────────────────────────────

  /// Tracks each step the user completes in the onboarding flow.
  static Future<void> logOnboardingStep(String step) async {
    await _analytics.logEvent(
      name: 'onboarding_step_completed',
      parameters: {'step': step},
    );
  }

  // ─── Paywall ────────────────────────────────────────────────────────────

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

  // ─── Generic ────────────────────────────────────────────────────────────

  /// Log a custom event with optional parameters.
  static Future<void> logEvent(
    String name, [
    Map<String, Object>? parameters,
  ]) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }
}
