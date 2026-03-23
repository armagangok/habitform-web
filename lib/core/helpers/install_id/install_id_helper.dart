import 'package:uuid/uuid.dart';

import '../hive/constants/hive_boxes.dart';
import '../hive/constants/hive_keys.dart';
import '../hive/hive_helper.dart';

/// Persists a single UUID per app install for multi-device Firestore rows (RevenueCat device map key).
final class InstallIdHelper {
  const InstallIdHelper._();

  static const _uuid = Uuid();

  static Future<String> getOrCreate() async {
    final hive = HiveHelper.shared;
    final existing = hive.getData<String?>(HiveBoxes.habitRiseDefaults, HiveKeys.installIdKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    final id = _uuid.v4();
    await hive.setData<String?>(HiveBoxes.habitRiseDefaults, HiveKeys.installIdKey, id);
    return id;
  }
}
