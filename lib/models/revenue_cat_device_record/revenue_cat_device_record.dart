/// Snapshot of RevenueCat + device context for one app install (Firestore `revenueCatDevices[installId]`).
class RevenueCatDeviceRecord {
  const RevenueCatDeviceRecord({
    required this.currentAppUserId,
    this.originalAppUserId,
    required this.platform,
    required this.deviceModel,
    required this.appVersion,
  });

  final String currentAppUserId;
  final String? originalAppUserId;
  final String platform;
  final String deviceModel;
  final String appVersion;
}
