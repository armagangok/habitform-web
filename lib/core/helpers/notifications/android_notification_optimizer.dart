import 'package:flutter/services.dart';

import '/core/core.dart';
import '/core/helpers/platform/platform_info.dart';

/// Android-specific notification optimizations
class AndroidNotificationOptimizer {
  AndroidNotificationOptimizer._();
  static final AndroidNotificationOptimizer shared = AndroidNotificationOptimizer._();

  static const MethodChannel _channel = MethodChannel('habitrise/notifications');

  /// Check if battery optimization is enabled for the app
  Future<bool> isBatteryOptimizationEnabled() async {
    if (!appIsAndroid) return false;

    try {
      final bool isOptimized = await _channel.invokeMethod('isBatteryOptimized');
      return isOptimized;
    } catch (e) {
      LogHelper.shared.debugPrint('Error checking battery optimization: $e');
      return false;
    }
  }

  /// Request to disable battery optimization
  Future<bool> requestDisableBatteryOptimization() async {
    if (!appIsAndroid) return true;

    try {
      final bool success = await _channel.invokeMethod('requestDisableBatteryOptimization');
      return success;
    } catch (e) {
      LogHelper.shared.debugPrint('Error requesting battery optimization disable: $e');
      return false;
    }
  }

  /// Check if notifications are enabled for the app
  Future<bool> areNotificationsEnabled() async {
    if (!appIsAndroid) return true;

    try {
      final bool enabled = await _channel.invokeMethod('areNotificationsEnabled');
      return enabled;
    } catch (e) {
      LogHelper.shared.debugPrint('Error checking notification permission: $e');
      return true; // Assume enabled if we can't check
    }
  }

  /// Get Android-specific notification limits and recommendations
  AndroidNotificationInfo getAndroidNotificationInfo(int currentCount) {
    return AndroidNotificationInfo(
      currentCount: currentCount,
      recommendedMax: _getRecommendedMax(),
      batteryOptimizationEnabled: false, // Will be set by async call
      performanceImpact: _calculatePerformanceImpact(currentCount),
    );
  }

  int _getRecommendedMax() {
    // Android için önerilen maksimum bildirim sayısı
    // Bu sayı performans ve kullanıcı deneyimini optimize eder
    return 200; // iOS'tan çok daha yüksek ama yine de makul bir sınır
  }

  NotificationPerformanceImpact _calculatePerformanceImpact(int count) {
    if (count < 50) return NotificationPerformanceImpact.low;
    if (count < 100) return NotificationPerformanceImpact.medium;
    if (count < 200) return NotificationPerformanceImpact.high;
    return NotificationPerformanceImpact.critical;
  }

  /// Get optimization suggestions for Android
  List<String> getOptimizationSuggestions(int count) {
    final suggestions = <String>[];

    if (count > 100) {
      suggestions.add('Consider reducing notification frequency for better performance');
    }

    if (count > 150) {
      suggestions.add('Group similar notifications to reduce system load');
    }

    suggestions.add('Ensure battery optimization is disabled for reliable notifications');
    suggestions.add('Test notification delivery on different Android versions');

    return suggestions;
  }
}

/// Android-specific notification information
class AndroidNotificationInfo {
  final int currentCount;
  final int recommendedMax;
  final bool batteryOptimizationEnabled;
  final NotificationPerformanceImpact performanceImpact;

  AndroidNotificationInfo({
    required this.currentCount,
    required this.recommendedMax,
    required this.batteryOptimizationEnabled,
    required this.performanceImpact,
  });

  bool get isWithinRecommended => currentCount <= recommendedMax;
  double get usagePercentage => (currentCount / recommendedMax * 100).clamp(0.0, 100.0);
}

enum NotificationPerformanceImpact {
  low,
  medium,
  high,
  critical,
}
