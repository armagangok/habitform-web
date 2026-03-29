import '../../core/core.dart';

class PermissionHelper {
  static final PermissionHelper _instance = PermissionHelper._internal();
  factory PermissionHelper() => _instance;
  PermissionHelper._internal();

  /// Browser file flows (save / pick) do not use Android/iOS storage permission APIs.
  Future<bool> checkAndRequestStoragePermission(BuildContext context) async {
    return true;
  }
}
