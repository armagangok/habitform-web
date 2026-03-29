import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/core/theme/theme_data/theme_data.dart';
import '/features/habit_category/provider/provider_setup.dart';
import '/features/onboarding/providers/onboarding_provider.dart';
import '/features/purchase/services/purchase_service.dart';
import '/services/app_default.dart';
import '/services/widget_sync_service.dart';
import 'core/constants/debug_constants.dart';
import 'core/helpers/notifications/timezone.dart';
import 'core/theme/providers/theme_provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/habit_category/provider/habit_category_provider.dart';
import 'features/home/provider/home_provider.dart';
import 'features/home/views/pages/home_page.dart';
import 'features/onboarding/pages/onboarding_welcome_page.dart';
import 'features/purchase/providers/purchase_provider.dart';
import 'firebase_options.dart';
import 'services/analytics_service.dart';
import 'services/crashlytics_service.dart';
import 'services/habit_service/habit_service_interface.dart';
import 'services/habit_service/local_habit_service.dart';

void main() {
  runZonedGuarded(
    () async => await _bootstrap(),
    (e, s) {
      LogHelper.shared.errorPrint('Bootstrap error: $e', e, s);
      CrashlyticsService.recordError(e, s, fatal: true);
    },
  );
}

Future<void> _bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      CrashlyticsService.recordError(
        details.exception,
        details.stack,
        reason: details.exceptionAsString(),
      );
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      CrashlyticsService.recordError(error, stack, fatal: true);
      return true;
    };

    await EasyLocalization.ensureInitialized();
    await HiveHelper.shared.initializeHive();
    await dotenv.load(fileName: ".env");

    // Otomatik restore islemini kaldirdik
    // Kullanici restore islemini manuel olarak baslatmali
    await TimeZoneHelper.initializeTimeZone();
    await AppDefaultsService().initializeAppDefaults();

    // Migrate existing habits: copy reminderTime to completionTime if available
    await LocalHabitService.instance.migrateCompletionTimeFromReminders();

    // // Initialize app lifecycle service for smart notifications
    // AppLifecycleService.shared.initialize();

    // Initialize widget sync service for iOS widgets
    await WidgetSyncService().initialize();

    // Setup habit category providers
    final habitCategoryOverrides = await setupHabitCategoryProviders();

    runApp(
      ProviderScope(
        overrides: [...habitCategoryOverrides],
        child: EasyLocalization(
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('fr', 'FR'),
            Locale('tr', 'TR'),
            Locale('zh', 'Hans'),
            Locale('it', 'IT'),
            Locale('ar', 'SA'),
            Locale('ja', 'JP'),
            Locale('fi', 'FI'),
            Locale('es', 'ES'),
          ],
          path: 'assets/translations',
          fallbackLocale: const Locale('en', 'US'),
          child: const MyApp(),
        ),
      ),
    );
  } catch (error, stack) {
    LogHelper.shared.errorPrint('Bootstrap error: $error', error, stack);
    CrashlyticsService.recordError(
      error,
      stack,
      fatal: true,
      reason: 'bootstrap_failed_before_run_app',
    );
    runApp(
      BootstrapErrorApp(
        errorMessage: error.toString(),
        stackTrace: stack,
      ),
    );
  }
}

class BootstrapErrorApp extends StatelessWidget {
  const BootstrapErrorApp({required this.errorMessage, required this.stackTrace, super.key});

  final String errorMessage;
  final StackTrace stackTrace;

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      home: CupertinoPageScaffold(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      'App failed to initialize.\n$errorMessage',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Stack trace:\n$stackTrace',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
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
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Set provider container for WidgetSyncService
    WidgetSyncService().setProviderContainer(ProviderScope.containerOf(context));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      authStateProvider,
      (previous, next) {
        next.whenData(
          (user) async {
            if (user != null) {
              await AnalyticsService.setUserId(user.uid);
              await CrashlyticsService.setUserId(user.uid);
              await PurchaseService.logIn(user.uid);
              await habitService.syncFromRemote();

              // Re-validate home data
              ref.invalidate(homeProvider);
              ref.invalidate(homeSummariesProvider);

              // Let purchaseProvider handle the subscription state correctly
              // instead of manually overwriting Hive here with potentially stale Firestore data
              ref.invalidate(purchaseProvider);
            } else {
              final hadUser = previous?.valueOrNull != null;
              if (hadUser) {
                await AnalyticsService.setUserId(null);
                await CrashlyticsService.setUserId(null);
                // Invalidate providers to reset their state
                ref.invalidate(homeProvider);
                ref.invalidate(homeSummariesProvider);
                ref.invalidate(purchaseProvider);
                ref.invalidate(habitCategoryProvider);
                ref.invalidate(selectedCategoriesProvider);
              }
            }
          },
        );
      },
    );

    final themeMode = ref.watch(themeProvider);
    // EasyLocalization drives locale; no custom provider to avoid conflicts

    final cupertinoTheme = themeMode == ThemeMode.dark ? Themes.cupertinoDarkTheme : Themes.cupertinoLightTheme;

    return CupertinoApp(
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1)),
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
    if (!onboardingState.hasCheckedFirstLaunch || onboardingState.isLoading) {
      return const CupertinoPageScaffold(
        child: Center(
          child: CupertinoActivityIndicator(),
        ),
      );
    }

    if (KDebug.onboardingDebugMode || onboardingState.isFirstLaunch) {
      return const OnboardingWelcomePage();
    }

    return const HomePage();
  }
}
