import 'core/constants/debug_constants.dart';
import 'core/core.dart';
import 'core/helpers/notifications/notification_helper.dart';
import 'core/helpers/notifications/timezone.dart';
import 'core/theme/bloc/theme_bloc.dart';
import 'core/theme/theme_data/theme_data.dart';
import 'features/habits/bloc/habit_bloc.dart';
import 'features/habits/home_page.dart';
import 'features/paywall/bloc/paywall_bloc.dart';
import 'features/paywall/in_app_purchase/iap.dart';
import 'features/reminder/bloc/reminder/reminder_bloc.dart';
import 'services/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await HiveHelper.shared.initializeHive();
  await PurchaseService.configureSDK();
  await TimeZoneHelper.initializeTimeZone();
  await NotificationHelper.shared.initializeNotificationPlugin;

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('tr', 'TR'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Global providers
        BlocProvider(
          create: (_) => ThemeBloc(),
        ),
        BlocProvider(
          create: (_) => HabitBloc(habitService: SingleHabitService()),
        ),
        BlocProvider(
          create: (_) => ReminderBloc(),
        ),
        BlocProvider(create: (context) => PaywallBloc()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          final themeMode = state.themeMode;
          return MaterialApp(
            darkTheme: Themes.darkTheme,
            theme: Themes.lightTheme,
            themeMode: themeMode,
            debugShowCheckedModeBanner: KDebug.debugModeEnabled,
            navigatorKey: NavigationService.shared.navigatorKey,
            onGenerateRoute: NavigationRoute.shared.generateRoute,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: HomePage(),
          );
        },
      ),
    );
  }
}
