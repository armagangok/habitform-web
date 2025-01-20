import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'core/constants/debug_constants.dart';
import 'core/core.dart';
import 'core/helpers/notifications/notification_helper.dart';
import 'core/helpers/notifications/timezone.dart';
import 'core/theme/bloc/theme_bloc.dart';
import 'core/theme/theme_data/theme_data.dart';
import 'features/habits/bloc/habit_bloc.dart';
import 'features/habits/home_page.dart';
import 'features/onboarding/bloc/onboarding_bloc.dart';
import 'features/onboarding/pages/onboarding_greeting_page.dart';
import 'features/paywall/bloc/paywall_bloc.dart';
import 'features/paywall/in_app_purchase/iap.dart';
import 'models/app_defaults/app_defaults.dart';
import 'services/app_default.dart';
import 'services/services.dart';
import 'services/user_defaults/user_defaults_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await HiveHelper.shared.initializeHive();

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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this); // Observer ekleniyor

    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    print("AppLifecycleState: $state");

    if (state == AppLifecycleState.detached) {
      print("App is detached (closed)");
      _onAppClosed();
    } else if (state == AppLifecycleState.paused) {
      print("App is paused (backgrounded)");
    } else if (state == AppLifecycleState.resumed) {
      print("App is resumed (foregrounded)");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Observer kaldırılıyor
    super.dispose();
  }

  void _onAppClosed() async {
    try {
      final appDefaults = await AppDefaultsService().gettAppDefault();
      print(appDefaults.toString());
      if (appDefaults != null) {
        final updatedDefaults = AppDefaults(isAppOpenedFirstTime: false);
        await AppDefaultsService().saveAppDefaults(updatedDefaults);
        print(appDefaults.toString());
      }
    } catch (e) {
      print("Error updating app defaults: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ThemeBloc(),
        ),
        BlocProvider(
          create: (_) => HabitBloc(habitService: SingleHabitService()),
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
            debugShowCheckedModeBanner: KDebug.debugModeEnabled,
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
