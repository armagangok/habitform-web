import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/core.dart';

class PermissionHelper {
  static final PermissionHelper _instance = PermissionHelper._internal();
  factory PermissionHelper() => _instance;
  PermissionHelper._internal();

  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  /// Check and request storage permissions
  Future<bool> checkAndRequestStoragePermission(BuildContext context) async {
    // iOS specific permission check
    if (Platform.isIOS) {
      // iOS doesn't need special permission for file access
      // as the file picker already handles permissions
      return true;
    }

    // Android permission check
    if (Platform.isAndroid) {
      // For Android 13 (API 33) and above
      if (await _isAndroid13OrHigher()) {
        if (!context.mounted) return false;
        return await _checkAndRequestPhotosAndDocumentsPermission(context);
      }
      // For Android below 13
      else {
        if (!context.mounted) return false;
        return await _checkAndRequestStoragePermission(context);
      }
    }

    return false;
  }

  /// Check if device is Android 13 (API 33) or higher
  Future<bool> _isAndroid13OrHigher() async {
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfoPlugin.androidInfo;
      return androidInfo.version.sdkInt >= 33;
    }
    return false;
  }

  /// Check and request photos and documents permissions for Android 13+
  Future<bool> _checkAndRequestPhotosAndDocumentsPermission(BuildContext context) async {
    // Check photos and documents permissions
    final photosStatus = await Permission.photos.status;
    final documentsStatus = await Permission.manageExternalStorage.status;

    // If permissions are already granted
    if (photosStatus.isGranted && documentsStatus.isGranted) {
      return true;
    }

    // If any permission is permanently denied
    if (photosStatus.isPermanentlyDenied || documentsStatus.isPermanentlyDenied) {
      if (!context.mounted) return false;
      return await _showPermanentlyDeniedDialog(context);
    }

    // Request permissions
    final photosResult = await Permission.photos.request();
    final documentsResult = await Permission.manageExternalStorage.request();

    // If permissions are granted
    if (photosResult.isGranted && documentsResult.isGranted) {
      return true;
    }

    // If permissions are denied
    if (photosResult.isDenied || documentsResult.isDenied) {
      if (!context.mounted) return false;
      return await _showDeniedDialog(context);
    }

    return false;
  }

  /// Check and request storage permission for Android below 13
  Future<bool> _checkAndRequestStoragePermission(BuildContext context) async {
    // Check storage permission
    final status = await Permission.storage.status;

    // If permission is already granted
    if (status.isGranted) {
      return true;
    }

    // If permission is permanently denied
    if (status.isPermanentlyDenied) {
      if (!context.mounted) return false;
      return await _showPermanentlyDeniedDialog(context);
    }

    // Request permission
    final result = await Permission.storage.request();

    // If permission is granted
    if (result.isGranted) {
      return true;
    }

    // If permission is denied
    if (result.isDenied) {
      if (!context.mounted) return false;
      return await _showDeniedDialog(context);
    }

    return false;
  }

  /// Show dialog when permission is denied
  Future<bool> _showDeniedDialog(BuildContext context) async {
    bool result = false;

    await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(LocaleKeys.permissions_permission_required.tr()),
        content: Text(LocaleKeys.permissions_storage_permission_message.tr()),
        actions: [
          CupertinoDialogAction(
            child: Text(LocaleKeys.permissions_cancel.tr()),
            onPressed: () {
              Navigator.of(context).pop();
              result = false;
            },
          ),
          CupertinoDialogAction(
            child: Text(LocaleKeys.permissions_try_again.tr()),
            onPressed: () {
              Navigator.of(context).pop();
              result = true;
            },
          ),
        ],
      ),
    );

    return result;
  }

  /// Show dialog when permission is permanently denied
  Future<bool> _showPermanentlyDeniedDialog(BuildContext context) async {
    bool result = false;

    await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(LocaleKeys.permissions_permission_required.tr()),
        content: Text(LocaleKeys.permissions_storage_permission_settings_message.tr()),
        actions: [
          CupertinoDialogAction(
            child: Text(LocaleKeys.permissions_cancel.tr()),
            onPressed: () {
              Navigator.of(context).pop();
              result = false;
            },
          ),
          CupertinoDialogAction(
            child: Text(LocaleKeys.permissions_settings.tr()),
            onPressed: () {
              openAppSettings();
              Navigator.of(context).pop();
              result = false;
            },
          ),
        ],
      ),
    );

    return result;
  }
}
