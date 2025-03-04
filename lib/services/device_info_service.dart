// import 'dart:io';

// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:uuid/uuid.dart';

// import '../core/core.dart';
// import '../models/sync/device_info.dart';

// final deviceInfoServiceProvider = Provider<DeviceInfoService>((ref) {
//   return DeviceInfoService.instance;
// });

// class DeviceInfoService {
//   static const _deviceIdKey = 'device_id';
//   final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

//   // Singleton instance
//   DeviceInfoService._();
//   static final DeviceInfoService _instance = DeviceInfoService._();
//   static DeviceInfoService get instance => _instance;

//   Future<String> getDeviceId() async {
//     // Try to get existing device ID from Hive
//     final box = Hive.box<String?>(HiveBoxes.deviceBox);
//     String? deviceId = box.get(_deviceIdKey);

//     // If no device ID exists, create one and store it
//     if (deviceId == null) {
//       deviceId = const Uuid().v4();
//       await box.put(_deviceIdKey, deviceId);
//       LogHelper.shared.debugPrint('Created new device ID: $deviceId');
//     }

//     return deviceId;
//   }

//   Future<DeviceInfo> getDeviceInfo() async {
//     final deviceId = await getDeviceId();
//     final platform = await getPlatformInfo();

//     return DeviceInfo(
//       deviceId: deviceId,
//       lastActive: DateTime.now(),
//       platform: platform,
//     );
//   }

//   Future<String> getPlatformInfo() async {
//     if (Platform.isIOS) {
//       final iosInfo = await _deviceInfo.iosInfo;
//       return '${iosInfo.systemName} ${iosInfo.systemVersion}';
//     } else if (Platform.isAndroid) {
//       final androidInfo = await _deviceInfo.androidInfo;
//       return 'Android ${androidInfo.version.release}';
//     }

//     return Platform.operatingSystem;
//   }
// }
