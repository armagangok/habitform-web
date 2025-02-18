import 'package:flutter/cupertino.dart';

import '../../features/habits/home_page.dart';
import '../../features/onboarding/pages/onboarding_greeting_page.dart';
import '../../features/settings/pages/notifications_page.dart';
import 'constant/routes.dart';

@immutable
final class NavigationRoute {
  const NavigationRoute._();
  static final shared = NavigationRoute._();

  Route<dynamic> generateRoute(RouteSettings args) {
    switch (args.name) {
      case KRoute.home:
        return _getRoute(page: const HomePage(), settings: args);

      case KRoute.notifications:
        return _normalNavigate(const NotificationsPage());

      default:
        return CupertinoPageRoute(
          builder: (context) => const OnboardingGreetingPage(),
        );
    }
  }

  PageRoute _normalNavigate(Widget page) {
    return CupertinoPageRoute(
      builder: (context) => page,
    );
  }

  PageRoute _getRoute({
    required Widget page,
    required RouteSettings settings,
  }) {
    return CupertinoPageRoute(
      settings: settings,
      builder: (context) => page,
    );
  }
}
