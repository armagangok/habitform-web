// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:hive_flutter/hive_flutter.dart';

part 'app_defaults.g.dart';

@HiveType(typeId: 6)
class AppDefaults extends HiveObject {
  @HiveField(0)
  bool? isAppOpenedFirstTime;
  AppDefaults({
    this.isAppOpenedFirstTime,
  });

  AppDefaults copyWith({
    bool? isAppOpenedFirstTime,
  }) {
    return AppDefaults(
      isAppOpenedFirstTime: isAppOpenedFirstTime ?? this.isAppOpenedFirstTime,
    );
  }

  @override
  String toString() => 'AppDefaults(isAppOpenedFirstTime: $isAppOpenedFirstTime)';
}
