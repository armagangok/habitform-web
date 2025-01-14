import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../core.dart';

class TimeZoneHelper {
  const TimeZoneHelper._();

  static Future<void> initializeTimeZone() async {
    // Initialize timezone database
    tz.initializeTimeZones();

    // Get the user's current timezone from the device
    String currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();

    // Set the local timezone in the Timezone package
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    LogHelper.shared.debugPrint("Current Timezone: $currentTimeZone");
  }
}
