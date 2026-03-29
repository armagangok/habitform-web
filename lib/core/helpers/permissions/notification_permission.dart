final class NotificationPermission {
  /// Web build: no native notification permission flow.
  static Future<bool> checkNotificationPermission() async {
    return false;
  }

  static Future<bool> handleNotificationPermission() async {
    return false;
  }
}
