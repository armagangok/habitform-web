import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

final class NotificationPermission {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<bool> checkNotificationPermission() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  static Future<bool> handleNotificationPermission() async {
    if (Platform.isIOS) {
      final bool? result = await _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    }

    final status = await Permission.notification.status;

    if (status.isPermanentlyDenied) {
      return await openAppSettings();
    }

    if (status.isDenied) {
      final result = await Permission.notification.request();
      return result.isGranted;
    }

    return status.isGranted;
  }
}
