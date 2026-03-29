import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '/core/helpers/logger/logger.dart';

/// Browser + app metadata for optional analytics / sync payloads.
final class DeviceMetadataService {
  const DeviceMetadataService._();

  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  static Future<({String platform, String deviceModel, String appVersion})> collect() async {
    final appVersion = await _readAppVersion();

    try {
      final webInfo = await _deviceInfo.webBrowserInfo;
      final deviceModel = webInfo.userAgent ?? 'web';
      return (platform: 'web', deviceModel: deviceModel, appVersion: appVersion);
    } catch (e) {
      LogHelper.shared.debugPrint('⚠️ DeviceMetadataService: web browser info failed: $e');
    }

    return (platform: 'web', deviceModel: 'unknown', appVersion: appVersion);
  }

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
