import 'package:intl/intl.dart';

import '/models/completion_entry/completion_entry.dart';

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

  // Checks if this date has a completed habit entry in the given completions map
  bool isCompletedInEntries(Map<String, CompletionEntry> completions) {
    return completions.values.any((completion) => completion.date.year == year && completion.date.month == month && completion.date.day == day && completion.isCompleted);
  }

  // Normalize the date to include only year, month, and day (no time)
  DateTime get normalized => DateTime(year, month, day);

  // Get ISO8601 date string (YYYY-MM-DD)
  String get toIso8601DateString => toIso8601String().split('T')[0];

  // Get all completions for a specific month and year
  static List<DateTime> getCompletionsForMonth(Map<String, CompletionEntry> completions, int year, int month) {
    return completions.values.where((completion) => completion.isCompleted && completion.date.year == year && completion.date.month == month).map((completion) => completion.date).toList();
  }

  // Check if the date has a completion in a specific month
  bool isCompletedInMonth(Map<String, CompletionEntry> completions, int year, int month) {
    return completions.values.any((completion) => completion.isCompleted && completion.date.year == year && completion.date.month == month && completion.date.day == day);
  }

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
}

extension MonthAbbreviation on DateTime {
  String get monthAbbreviation {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }
}

extension CompletionEntryUtils on Map<String, CompletionEntry> {
  // Get all completions for a specific month and year
  List<DateTime> getCompletionsForMonth(int year, int month) {
    return values.where((completion) => completion.isCompleted && completion.date.year == year && completion.date.month == month).map((completion) => completion.date).toList();
  }

  // Calculate the longest streak of consecutive days completed
  int calculateLongestStreak() {
    // Tamamlanmış günleri al ve kronolojik sırala
    final completions = values.where((completion) => completion.isCompleted).map((completion) => completion.date.normalized).toList();

    // Boş liste kontrolü
    if (completions.isEmpty) return 0;

    // Mükerrer günleri kaldır (aynı günde birden fazla kayıt olmaması için)
    final uniqueDates = <DateTime>{};
    for (var date in completions) {
      uniqueDates.add(date);
    }

    // Kronolojik sıralama yap
    final sortedDates = uniqueDates.toList()..sort((a, b) => a.compareTo(b));

    if (sortedDates.isEmpty) return 0;
    if (sortedDates.length == 1) return 1;

    int currentStreak = 1;
    int longestStreak = 1;

    for (int i = 1; i < sortedDates.length; i++) {
      // Mevcut tarih ile önceki tarih arasındaki fark tam olarak 1 gün mü?
      final expectedPreviousDay = DateTime(sortedDates[i].year, sortedDates[i].month, sortedDates[i].day - 1);

      if (sortedDates[i - 1].isSameDayWith(expectedPreviousDay)) {
        // Ardışık günler - streak'i artır
        currentStreak++;
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
      } else {
        // Ardışık değil - yeni streak başlat
        currentStreak = 1;
      }
    }

    return longestStreak;
  }

  // Calculate the current streak (consecutive days until today or yesterday)
  int calculateCurrentStreak() {
    // Tamamlanmış günleri al
    final completions = values.where((completion) => completion.isCompleted).map((completion) => completion.date.normalized).toList();

    if (completions.isEmpty) return 0;

    // Mükerrer günleri kaldır
    final uniqueDates = <DateTime>{};
    for (var date in completions) {
      uniqueDates.add(date);
    }

    // Azalan sıralama yap (en yeni tarihten eskiye)
    final sortedDates = uniqueDates.toList()..sort((a, b) => b.compareTo(a));

    final today = DateTime.now().normalized;
    final yesterday = DateTime(today.year, today.month, today.day - 1);

    // En son tamamlanan gün bugün veya dün değilse, streak yoktur
    if (!sortedDates.first.isSameDayWith(today) && !sortedDates.first.isSameDayWith(yesterday)) {
      return 0;
    }

    int streak = 1;
    DateTime currentDate = sortedDates.first;

    // Ardışık günleri geriye doğru kontrol et
    for (int i = 1; i < sortedDates.length; i++) {
      final expectedNextDay = DateTime(currentDate.year, currentDate.month, currentDate.day - 1);

      if (sortedDates[i].isSameDayWith(expectedNextDay)) {
        // Ardışık bir gün bulundu
        streak++;
        currentDate = sortedDates[i];
      } else {
        // Ardışık olmayan bir gün bulundu, streak sona erdi
        break;
      }
    }

    return streak;
  }
}
