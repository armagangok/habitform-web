import 'dart:math';

import 'package:uuid/uuid.dart';

class UuidHelper {
  const UuidHelper._();

  static final _uuidPlugin = const Uuid();

  /// Generates a time-based id.
  static String get uid => _uuidPlugin.v1();
  static String get uid2 => _uuidPlugin.v4();
  static int get uidInt => Random().nextInt(2147483647);
}
