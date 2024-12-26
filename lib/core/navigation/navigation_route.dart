import 'package:flutter/cupertino.dart';
import 'package:habitrise/pages/overview/overview_page.dart';
import 'package:habitrise/pages/tab_bar/hom_tab_bar_page.dart';

import '../../pages/habits/habits_page.dart';
import '../../pages/onboarding/pages/onboarding_final/onboarding_final_page.dart';
import '../../pages/onboarding/pages/onboarding_greeting.dart';
import '../../pages/onboarding/pages/onboarding_page.dart';
import '../extension/easy_context.dart';
import 'constant/routes.dart';

class NavigationRoute {
  static final NavigationRoute _shared = NavigationRoute._();
  static NavigationRoute get shared => _shared;

  NavigationRoute._();

  Route<dynamic> generateRoute(RouteSettings args) {
    switch (args.name) {
      case KRoute.habitsPage:
        return _getRoute(page: const HabitsPage(), settings: args);

      case KRoute.onboardingPage:
        return _getRoute(page: const OnboardingPage(), settings: args);

      case KRoute.onboardingGreeting:
        return _getRoute(page: const OnboardingGreeting(), settings: args);

      case KRoute.onboardingFinalPage:
        return _getRoute(page: const OnboardingFinalPage(), settings: args);

      case KRoute.homeTabScaffoldPage:
        return _getRoute(page: const HomeTabScaffoldPage(), settings: args);

      case KRoute.overviewPage:
        return _getRoute(page: const OverviewPage(), settings: args);

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
