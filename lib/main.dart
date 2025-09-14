import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitrise/features/onboarding/pages/onboarding_welcome_page.dart';

import '/core/core.dart';
import '/core/theme/theme_data/theme_data.dart';
import '/features/habit_category/provider/provider_setup.dart';
import '/features/onboarding/providers/onboarding_provider.dart';
import '/features/purchase/services/purchase_service.dart';
import '/services/app_default.dart';
import '/services/app_lifecycle_service.dart';
import 'core/constants/debug_constants.dart';
import 'core/helpers/notifications/notification_helper.dart';
import 'core/helpers/notifications/timezone.dart';
import 'core/theme/providers/theme_provider.dart';
import 'features/home/provider/home_provider.dart';
import 'features/home/views/pages/home_page.dart';
import 'features/purchase/providers/purchase_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await HiveHelper.shared.initializeHive();

  await dotenv.load(fileName: ".env");

  // Initialize notification plugin
  await NotificationHelper.shared.initializeNotificationPlugin;

  // Configure RevenueCat SDK
  await PurchaseService.configureSDK();

  // Otomatik restore işlemini kaldırdık
  // Kullanıcı restore işlemini manuel olarak başlatmalı

  await TimeZoneHelper.initializeTimeZone();
  await AppDefaultsService().initializeAppDefaults();

  // Initialize app lifecycle service for smart notifications
  AppLifecycleService().initialize();

  // Setup habit category providers
  final habitCategoryOverrides = await setupHabitCategoryProviders();

  runApp(
    ProviderScope(
      overrides: [
        ...habitCategoryOverrides,
      ],
      child: EasyLocalization(
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('tr', 'TR'),
          Locale('zh', 'CN'),
          Locale('es', 'ES'),
          Locale('hi', 'IN'),
          Locale('ar', 'SA'),
          Locale('bn', 'BD'),
          Locale('pt', 'BR'),
          Locale('ru', 'RU'),
          Locale('ja', 'JP'),
          Locale('id', 'ID'),
          Locale('it', 'IT'),
          Locale('nl', 'NL'),
          Locale('sv', 'SE'),
          Locale('no', 'NO'),
          Locale('fi', 'FI'),
          Locale('he', 'IL'),
          Locale('ko', 'KR'),
          Locale('da', 'DK'),
          Locale('ca', 'ES'),
          Locale('th', 'TH'),
          Locale('vi', 'VN'),
          Locale('cs', 'CZ'),
          Locale('pl', 'PL'),
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
    ref.read(homeProvider);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);

    final cupertinoTheme = themeMode == ThemeMode.dark ? Themes.cupertinoDarkTheme : Themes.cupertinoLightTheme;

    return CupertinoApp(
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(
              1,
            ),
          ),
          child: child!,
        );
      },
      theme: cupertinoTheme,
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService.shared.navigatorKey,
      onGenerateRoute: NavigationRoute.shared.generateRoute,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: _buildHomeScreen,
    );
  }

  Widget get _buildHomeScreen {
    final onboardingState = ref.watch(onboardingProvider);
    if (KDebug.onboardingDebugMode || onboardingState.isFirstLaunch) {
      return const OnboardingWelcomePage();
    }

    return HomePage();
  }
}
