import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:habitrise/core/navigation/contract/base_navigation_service.dart';

final navigator = NavigationService.shared;

class NavigationService extends INavigationService {
  static final NavigationService _shared = NavigationService._();
  static NavigationService get shared => _shared;
  NavigationService._();

  GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  @override
  Future<void> navigateTo({required String path, Object? data}) async {
    try {
      await navigatorKey.currentState?.pushNamed(
        path,
        arguments: data,
      );
    } catch (e, s) {
      log(e.toString());
      log(s.toString());
    }
  }

  @override
  Future<void> navigateAndClear({required String path, Object? data}) async {
    try {
      await navigatorKey.currentState?.pushNamedAndRemoveUntil(
        path,
        (Route<dynamic> route) => false,
        arguments: data,
      );
    } catch (e, s) {
      log(e.toString());
      log(s.toString());
    }
  }

  @override
  void pop() async {
    navigatorKey.currentState?.pop();
  }
}
