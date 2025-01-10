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
