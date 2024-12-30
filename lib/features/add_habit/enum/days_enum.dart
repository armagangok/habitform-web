enum Days {
  mon,
  tue,
  wed,
  thu,
  fri,
  sat,
  sun,
}

extension EasyDaysExtension on Days {
  /// Converts the enum value to a human-readable string
  String toMap() {
    switch (this) {
      case Days.mon:
        return 'Monday';
      case Days.tue:
        return 'Tuesday';
      case Days.wed:
        return 'Wednesday';
      case Days.thu:
        return 'Thursday';
      case Days.fri:
        return 'Friday';
      case Days.sat:
        return 'Saturday';
      case Days.sun:
        return 'Sunday';
    }
  }

  /// Converts the enum value to JSON (uses the same as `toMap` here)
  String toJson() => toMap();

  /// Parses a string back to an enum value
  Days? fromMap(String value) {
    switch (value) {
      case 'Monday':
        return Days.mon;
      case 'Tuesday':
        return Days.tue;
      case 'Wednesday':
        return Days.wed;
      case 'Thursday':
        return Days.thu;
      case 'Friday':
        return Days.fri;
      case 'Saturday':
        return Days.sat;
      case 'Sunday':
        return Days.sun;
      default:
        return null; // Return null if the input doesn't match
    }
  }
}
