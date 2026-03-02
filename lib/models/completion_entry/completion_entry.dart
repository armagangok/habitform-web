import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/adapters.dart';

import '../sync_status.dart';

part 'completion_entry.freezed.dart';
part 'completion_entry.g.dart';

@freezed
@HiveType(typeId: 8)
class CompletionEntry extends HiveObject with _$CompletionEntry {
  factory CompletionEntry({
    @HiveField(0) required String id,
    @HiveField(1) required DateTime date,
    @HiveField(2) required bool isCompleted,
    @Default(1) @HiveField(3) int count,
    @HiveField(4) double? rewardRating,
    @Default(SyncStatus.synced) @HiveField(5) SyncStatus syncStatus,
    @HiveField(6) DateTime? updatedAt,
  }) = _CompletionEntry;

  CompletionEntry._();

  factory CompletionEntry.fromJson(Map<String, dynamic> json) => _$CompletionEntryFromJson(json);
}
