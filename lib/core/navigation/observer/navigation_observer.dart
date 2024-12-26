import 'package:flutter/cupertino.dart';

import '../../helpers/logger/logger.dart';

final _logger = LogHelper.shared;

final class CustomNavigatorObserver extends NavigatorObserver {
  @override
  void didRemove(Route route, Route? previousRoute) {
    _logger.debugPrint('Did remove route: ${route.settings.name}.');
    _logger.debugPrint('Did remove previous route: ${previousRoute?.settings.name}');
    debugPrint(StackTrace.current.toString()); // Bu satır navigasyonu tetikleyen yeri gösterir
    super.didRemove(route, previousRoute);
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    _logger.debugPrint('Previous route: ${previousRoute?.settings.name}.');
    _logger.debugPrint('Navigated to: ${route.settings.name}');
    debugPrint(StackTrace.current.toString()); // Bu satır navigasyonu tetikleyen yeri gösterir

    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _logger.debugPrint('Previous route: ${previousRoute?.settings.name}.');
    _logger.debugPrint('Popped route: ${route.settings.name}');
    debugPrint(StackTrace.current.toString()); // Bu satır navigasyonu tetikleyen yeri gösterir
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    _logger.debugPrint('Replaced route: ${oldRoute?.settings.name} with ${newRoute?.settings.name}');
    debugPrint(StackTrace.current.toString()); // Bu satır navigasyonu tetikleyen yeri gösterir
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didChangeTop(Route topRoute, Route? previousTopRoute) {
    _logger.debugPrint('Top route: ${topRoute.settings.name}.');
    _logger.debugPrint('Previous Top Route: ${previousTopRoute?.settings.name}');
    debugPrint(StackTrace.current.toString()); // Bu satır navigasyonu tetikleyen yeri gösterir
    super.didChangeTop(topRoute, previousTopRoute);
  }
}
