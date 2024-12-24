import 'package:uuid/uuid.dart';

class UuidHelper {
  const UuidHelper._();

  /// Generates a time-based id.
  static String get uid => const Uuid().v1();
}
