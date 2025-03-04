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

  CompletionEntry({
    required this.id,
    required this.date,
    required this.isCompleted,
  });

  CompletionEntry copyWith({
    String? id,
    DateTime? date,
    bool? isCompleted,
  }) {
    return CompletionEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
