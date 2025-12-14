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

  // Reward rating (α) for this specific completion
  // Represents how enjoyable/rewarding this completion felt (0.5-2.0)
  // null means user hasn't rated this completion yet
  @HiveField(4)
  final double? rewardRating;

  CompletionEntry({
    required this.id,
    required this.date,
    required this.isCompleted,
    this.count = 1,
    this.rewardRating,
  });

  CompletionEntry copyWith({
    String? id,
    DateTime? date,
    bool? isCompleted,
    int? count,
    double? rewardRating,
  }) {
    return CompletionEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      count: count ?? this.count,
      rewardRating: rewardRating ?? this.rewardRating,
    );
  }
}
