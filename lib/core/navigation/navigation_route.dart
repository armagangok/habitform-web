import 'package:flutter/cupertino.dart';

import '../../features/habits/home_page.dart';
import '../../features/onboarding/pages/onboarding_greeting_page.dart';
import '../extension/easy_context.dart';
import 'constant/routes.dart';

class NavigationRoute {
  static final NavigationRoute _shared = NavigationRoute._();
  static NavigationRoute get shared => _shared;

  NavigationRoute._();

  Route<dynamic> generateRoute(RouteSettings args) {
    switch (args.name) {
      case KRoute.onboardingGreeting:
        return _getRoute(page: const OnboardingGreetingPage(), settings: args);

      case KRoute.home:
        return _getRoute(page: const HomePage(), settings: args);

      default:
        return CupertinoPageRoute(
          builder: (context) => CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(previousPageTitle: "Back"),
            child: Center(
              child: Text(
                "${args.name}",
                style: context.bodyLarge,
              ),
            ),
          ),
        );
    }
  }

  PageRoute _getRoute({required Widget page, RouteSettings? settings}) {
    return CupertinoPageRoute(
      builder: (context) => page,
      settings: settings,
    );
  }
}
