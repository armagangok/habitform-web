import 'package:hive_flutter/hive_flutter.dart';

part 'sync_status.g.dart';

@HiveType(typeId: 20)
enum SyncStatus {
  @HiveField(0)
  synced,

  @HiveField(1)
  pending,

  @HiveField(2)
  deleted,
}
