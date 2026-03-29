import 'package:flutter/foundation.dart';

/// This app ships for Flutter web; [appIsIOS]/[appIsAndroid] are false in the browser.
bool get appIsWeb => kIsWeb;

bool get appIsIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

bool get appIsAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

bool get appIsMobile => appIsIOS || appIsAndroid;
