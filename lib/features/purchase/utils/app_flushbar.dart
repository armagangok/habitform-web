import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class AppFlushbar {
  static final AppFlushbar shared = AppFlushbar._();
  AppFlushbar._();

  void successFlushbar(String message) {
    Flushbar(
      message: message,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.green,
      flushbarPosition: FlushbarPosition.TOP,
    ).show(navigatorKey.currentContext!);
  }

  void errorFlushbar(String message) {
    Flushbar(
      message: message,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.red,
      flushbarPosition: FlushbarPosition.TOP,
    ).show(navigatorKey.currentContext!);
  }
}

final navigatorKey = GlobalKey<NavigatorState>();
