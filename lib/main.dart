import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/core/theme/theme_data/theme_data.dart';
import '/features/onboarding/providers/onboarding_provider.dart';
import '/features/purchase/services/purchase_service.dart';
import '/services/app_default.dart';
import '/services/local_habit_service.dart';
import 'core/constants/debug_constants.dart';
import 'core/helpers/notifications/notification_helper.dart';
import 'core/helpers/notifications/timezone.dart';
import 'core/theme/providers/theme_provider.dart';
import 'features/home/views/pages/home_page.dart';
import 'features/onboarding/pages/onboarding_main_page.dart';
import 'features/onboarding/providers/onboarding_state.dart';
import 'features/purchase/providers/purchase_provider.dart';

// Flag to enable debug mode
const bool enableDebugMode = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await HiveHelper.shared.initializeHive();

  // Run habit migration
  await LocalHabitService.instance.migrateHabitsToNewModel();

  await dotenv.load(fileName: ".env");

  // Initialize notification plugin
  await NotificationHelper.shared.initializeNotificationPlugin;

  // Configure RevenueCat SDK
  await PurchaseService.configureSDK();

  // Otomatik restore işlemini kaldırdık
  // Kullanıcı restore işlemini manuel olarak başlatmalı

  await TimeZoneHelper.initializeTimeZone();
  await AppDefaultsService().initializeAppDefaults();

  runApp(
    ProviderScope(
      child: EasyLocalization(
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('tr', 'TR'),
        ],
        path: 'assets/translations',
        fallbackLocale: const Locale('en', 'US'),
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    ref.read(purchaseProvider);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final onboardingState = ref.watch(onboardingProvider);

    return MaterialApp(
      darkTheme: Themes.darkTheme,
      theme: Themes.lightTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService.shared.navigatorKey,
      onGenerateRoute: NavigationRoute.shared.generateRoute,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: _buildHomeScreen(onboardingState),
    );
  }

  Widget _buildHomeScreen(OnboardingState onboardingState) {
    if (KDebug.onboardingDebugMode || onboardingState.isFirstLaunch) {
      return const OnboardingMainPage();
    }

    return HomePage();
  }
}
