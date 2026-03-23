import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '/core/helpers/logger/logger.dart';

/// Lightweight device + app build info for Firestore (RevenueCat device rows).
final class DeviceMetadataService {
  const DeviceMetadataService._();

  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  static Future<({String platform, String deviceModel, String appVersion})> collect() async {
    final appVersion = await _readAppVersion();

    try {
      if (Platform.isIOS) {
        final ios = await _deviceInfo.iosInfo;
        final deviceModel = '${ios.name} ${ios.model} (${ios.utsname.machine})';
        return (platform: 'ios', deviceModel: deviceModel, appVersion: appVersion);
      }
      if (Platform.isAndroid) {
        final android = await _deviceInfo.androidInfo;
        final deviceModel = '${android.manufacturer} ${android.model}';
        return (platform: 'android', deviceModel: deviceModel, appVersion: appVersion);
      }
    } catch (e) {
      LogHelper.shared.debugPrint('⚠️ DeviceMetadataService: device info failed: $e');
    }

    return (platform: Platform.operatingSystem, deviceModel: 'unknown', appVersion: appVersion);
  }

  /// [PackageInfo] can throw [MissingPluginException] after hot restart until a full rebuild registers the plugin.
  static Future<String> _readAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } on MissingPluginException catch (e) {
      LogHelper.shared.debugPrint(
        '⚠️ PackageInfo plugin not linked ($e). Stop and run again (full rebuild), or appVersion will be unknown.',
      );
      return 'unknown';
    } catch (e) {
      LogHelper.shared.debugPrint('⚠️ PackageInfo unavailable: $e');
      return 'unknown';
    }
  }
}
