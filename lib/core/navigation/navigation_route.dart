import '/features/archived_habits/pages/archived_habits_page.dart';
import '/features/export_import_data/data_export_import_page.dart';
import '/features/habit_category/page/habit_category_page.dart';
import '/features/home/views/pages/home_page.dart';
import '/features/settings/pages/notifications_page.dart';
import '/features/settings/settings_page.dart';
import '../core.dart';
import '../../features/habit_icon/icon_picker_page.dart';

@immutable
final class NavigationRoute {
  const NavigationRoute._();
  static final shared = NavigationRoute._();

  Route<dynamic> generateRoute(RouteSettings args) {
    switch (args.name) {
      case KRoute.homePage:
        return _getRoute(page: const HomePage(), settings: args);

      case KRoute.settings:
        return _getRoute(page: const SettingsPage(), settings: args);

      case KRoute.notifications:
        return _getRoute(page: const NotificationsPage(), settings: args);

      case KRoute.archivedHabits:
        return _getRoute(page: const ArchivedHabitsPage(), settings: args);

      case KRoute.dataManagement:
        return _getRoute(page: const DataExportImportPage(), settings: args);

      case KRoute.iconPage:
        return _getRoute(page: const IconPickerPage(), settings: args);

      case KRoute.habitCategoryPage:
        return _getRoute(page: const HabitCategoryPage(), settings: args);

      default:
        return CupertinoPageRoute(
          builder: (context) => const CupertinoPageScaffold(
            child: Center(
              child: Text("404"),
            ),
          ),
        );
    }
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
