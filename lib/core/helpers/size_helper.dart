import 'package:flutter/material.dart';

import 'logger/logger.dart';

class SizeHelper {
  static void getSize(GlobalKey key, Function(Size) callback) {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          
          callback(renderBox.size);
        }
      });
    } catch (e) {
      LogHelper.shared.debugPrint('$e');
    }
  }
}
