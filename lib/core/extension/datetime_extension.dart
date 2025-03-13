import 'package:intl/intl.dart';

extension EasyDateTime on DateTime {
  // Returns the time in HH:mm format
  String toHHMM() {
    return DateFormat('HH:mm').format(this);
  }

  // Checks if the date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  // Checks if two dates are on the same calendar day
  bool isSameDayWith(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  // Normalize the date to include only year, month, and day (no time)
  DateTime get normalized => DateTime(year, month, day);

  // Get ISO8601 date string (YYYY-MM-DD)
  String get toIso8601DateString => toIso8601String().split('T')[0];

  // Calculate the number of days between this date and another date
  int daysDifference(DateTime other) {
    final normalized1 = normalized;
    final normalized2 = other.normalized;
    return normalized1.difference(normalized2).inDays.abs();
  }

  // Check if the date is exactly one day after another date
  bool isNextDayOf(DateTime other) {
    final normalizedThis = normalized;
    final normalizedOther = other.normalized;

    // Tam olarak bir gün sonra mı kontrolü
    final nextDay = DateTime(normalizedOther.year, normalizedOther.month, normalizedOther.day + 1);
    return normalizedThis.isSameDayWith(nextDay);
  }

  // Check if the date is exactly one day before another date
  bool isPreviousDayOf(DateTime other) {
    final normalizedThis = normalized;
    final normalizedOther = other.normalized;

    // Tam olarak bir gün önce mi kontrolü
    final previousDay = DateTime(normalizedOther.year, normalizedOther.month, normalizedOther.day - 1);
    return normalizedThis.isSameDayWith(previousDay);
  }

  // Check if the date is between two other dates (exclusive)
  bool isBetween(DateTime start, DateTime end) {
    final normalizedThis = normalized;
    final normalizedStart = start.normalized;
    final normalizedEnd = end.normalized;
    return normalizedThis.isAfter(normalizedStart) && normalizedThis.isBefore(normalizedEnd);
  }

  // Check if this date is completed in the given completions map
  bool isCompletedInEntries(Map<String, dynamic> completions) {
    final dateKey = toIso8601DateString;
    return completions.containsKey(dateKey) && completions[dateKey]?.isCompleted == true;
  }
}
