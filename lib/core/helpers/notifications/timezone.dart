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
    final deviceTimeZone = await FlutterNativeTimezone.getLocalTimezone();
    final normalizedTimeZone = _normalizeTimeZone(deviceTimeZone);

    try {
      tz.setLocalLocation(tz.getLocation(normalizedTimeZone));
      LogHelper.shared.debugPrint(
        'Current Timezone: $deviceTimeZone -> $normalizedTimeZone',
      );
    } catch (error) {
      // Keep app startup resilient when OEM/device returns an unsupported alias.
      const fallback = 'UTC';
      tz.setLocalLocation(tz.getLocation(fallback));
      LogHelper.shared.debugPrint(
        'Timezone resolution failed for "$deviceTimeZone". Falling back to $fallback. Error: $error',
      );
    }
  }

  static String _normalizeTimeZone(String rawTimeZone) {
    final knownAliases = <String, String>{
      'Asia/Calcutta': 'Asia/Kolkata',
      'US/Eastern': 'America/New_York',
      'US/Central': 'America/Chicago',
      'US/Mountain': 'America/Denver',
      'US/Pacific': 'America/Los_Angeles',
      'Etc/UTC': 'UTC',
    };

    return knownAliases[rawTimeZone] ?? rawTimeZone;
  }
}
