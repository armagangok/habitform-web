import 'package:hive_flutter/hive_flutter.dart';

part 'user_defaults.g.dart';

@HiveType(typeId: 5)
class UserDefaults extends HiveObject {
  @HiveField(0, defaultValue: '')
  final String userName;

  @HiveField(1, defaultValue: false)
  bool isPro;

  UserDefaults({
    this.userName = "",
    this.isPro = false,
  });

  UserDefaults copyWith({
    bool? isPro,
  }) {
    return UserDefaults(
      userName: userName,
      isPro: isPro ?? this.isPro,
    );
  }
}
