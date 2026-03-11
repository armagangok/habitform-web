import 'dart:developer';

import 'package:flutter/cupertino.dart';

import 'contract/base_navigation_service.dart';

final navigator = NavigationService.shared;

class NavigationService extends INavigationService {
  static final NavigationService _shared = NavigationService._();
  static NavigationService get shared => _shared;
  NavigationService._();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  NavigatorState? get _navigator => navigatorKey.currentState;

  @override
  Future<void> navigateTo({required String path, Object? data}) async {
    try {
      await _navigator?.pushNamed(
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
      await _navigator?.pushNamedAndRemoveUntil(
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
  void pop() {
    final navigator = _navigator;
    if (navigator != null && navigator.canPop()) {
      navigator.pop();
    }
  }
}
