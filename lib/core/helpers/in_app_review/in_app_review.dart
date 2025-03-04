import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/debug_constants.dart';
import '../../core.dart';

final class InAppReviewHelper {
  InAppReviewHelper._();
  static final shared = InAppReviewHelper._();

  static const _lastReviewRequestKey = 'last_review_request_date';
  static const _firstAppOpenKey = 'first_app_open_date';

  Future<void> checkAndRequestReview({
    required int totalHabits,
    required double completionRate,
  }) async {
    if (KDebug.rateDebugMode) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if it's first time opening the app
      if (!prefs.containsKey(_firstAppOpenKey)) {
        await prefs.setString(_firstAppOpenKey, DateTime.now().toIso8601String());
        return;
      }

      final firstOpenDate = DateTime.parse(prefs.getString(_firstAppOpenKey)!);
      final daysSinceFirstOpen = DateTime.now().difference(firstOpenDate).inDays;

      // Get last review request date
      final lastReviewDate = prefs.getString(_lastReviewRequestKey);
      final daysSinceLastReview = lastReviewDate != null ? DateTime.now().difference(DateTime.parse(lastReviewDate)).inDays : 999;

      // Check all conditions
      final bool shouldShowReview = daysSinceFirstOpen >= 7 && // At least 7 days since first open
          totalHabits >= 3 && // At least 3 habits
          completionRate >= 0.7 && // 70% completion rate
          daysSinceLastReview >= 30 && // At least 30 days since last review
          await InAppReview.instance.isAvailable();

      if (shouldShowReview) {
        await InAppReview.instance.requestReview();
        await prefs.setString(_lastReviewRequestKey, DateTime.now().toIso8601String());
      }
    } catch (e) {
      LogHelper.shared.debugPrint('InAppReviewHelper error: $e');
    }
  }
}
