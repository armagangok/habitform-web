import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'core/core.dart';
import 'core/helpers/notifications/notification_helper.dart';
import 'core/helpers/notifications/timezone.dart';
import 'core/theme/bloc/theme_bloc.dart';
import 'core/theme/theme_data/theme_data.dart';
import 'features/habits/bloc/habit_bloc.dart';
import 'features/habits/home_page.dart';
import 'features/onboarding/bloc/onboarding_bloc.dart';
import 'features/onboarding/pages/onboarding_greeting_page.dart';
import 'features/paywall/in_app_purchase/iap.dart';
import 'services/app_default.dart';
import 'services/services.dart';
import 'services/user_defaults/user_defaults_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await HiveHelper.shared.initializeHive();
  await dotenv.load(fileName: ".env");

  await PurchaseService.configureSDK();
  await TimeZoneHelper.initializeTimeZone();
  await NotificationHelper.shared.initializeNotificationPlugin;
  // await NotificationHelper.shared.listScheduledNotifications();

  if (Platform.isAndroid) {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  }

  await AppDefaultsService().initializeAppDefaults();

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
        BlocProvider(
          create: (_) => ThemeBloc(),
        ),
        BlocProvider(
          create: (_) => HabitBloc(habitService: HabitService()),
        ),
        BlocProvider(create: (context) => PaywallBloc()),
        BlocProvider(
          create: (_) => OnboardingBloc(
            userDefaultsService: UserDefaultsService(),
            appDefaultsService: AppDefaultsService(),
          )..add(CheckFirstLaunchEvent()),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          final themeMode = state.themeMode;
          return MaterialApp(
            darkTheme: Themes.darkTheme,
            theme: Themes.lightTheme,
            themeMode: themeMode,
            debugShowCheckedModeBanner: true,
            navigatorKey: NavigationService.shared.navigatorKey,
            onGenerateRoute: NavigationRoute.shared.generateRoute,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: BlocBuilder<OnboardingBloc, OnboardingState>(
              builder: (context, state) {
                if (state is OnboardingRequired) {
                  return const OnboardingGreetingPage();
                }
                return HomePage();
              },
            ),
          );
        },
      ),
    );
  }
}
