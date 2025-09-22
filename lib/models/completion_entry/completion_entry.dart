import 'package:hive_flutter/adapters.dart';

part 'completion_entry.g.dart';

@HiveType(typeId: 8)
class CompletionEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final bool isCompleted;

  // Number of completions recorded for the given date
  @HiveField(3, defaultValue: 1)
  final int count;

  CompletionEntry({
    required this.id,
    required this.date,
    required this.isCompleted,
    this.count = 1,
  });

  CompletionEntry copyWith({
    String? id,
    DateTime? date,
    bool? isCompleted,
    int? count,
  }) {
    return CompletionEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      count: count ?? this.count,
    );
  }
}
