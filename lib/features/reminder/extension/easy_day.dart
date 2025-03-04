import '/core/core.dart';
import '../models/days/days_enum.dart';

extension DaysExtension on Days {
  String get shortenDayName {
    switch (this) {
      case Days.mon:
        return LocaleKeys.days_monday.tr().substring(0, 3);
      case Days.tue:
        return LocaleKeys.days_tuesday.tr().substring(0, 3);
      case Days.wed:
        return LocaleKeys.days_wednesday.tr().substring(0, 3);
      case Days.thu:
        return LocaleKeys.days_thursday.tr().substring(0, 3);
      case Days.fri:
        return LocaleKeys.days_friday.tr().substring(0, 3);
      case Days.sat:
        return LocaleKeys.days_saturday.tr().substring(0, 3);
      case Days.sun:
        return LocaleKeys.days_sunday.tr().substring(0, 3);
    }
  }

  String get getFullDayName {
    switch (this) {
      case Days.mon:
        return LocaleKeys.days_monday.tr();
      case Days.tue:
        return LocaleKeys.days_tuesday.tr();
      case Days.wed:
        return LocaleKeys.days_wednesday.tr();
      case Days.thu:
        return LocaleKeys.days_thursday.tr();
      case Days.fri:
        return LocaleKeys.days_friday.tr();
      case Days.sat:
        return LocaleKeys.days_saturday.tr();
      case Days.sun:
        return LocaleKeys.days_sunday.tr();
    }
  }
}

// Function to map DateTime.weekday to Days enum
Days getDayEnum(int weekday) {
  switch (weekday) {
    case DateTime.monday:
      return Days.mon;
    case DateTime.tuesday:
      return Days.tue;
    case DateTime.wednesday:
      return Days.wed;
    case DateTime.thursday:
      return Days.thu;
    case DateTime.friday:
      return Days.fri;
    case DateTime.saturday:
      return Days.sat;
    case DateTime.sunday:
      return Days.sun;
    default:
      throw Exception('Invalid weekday: $weekday');
  }
}
