import 'core/constants/debug_constants.dart';
import 'core/core.dart';
import 'core/theme/theme.dart';
import 'core/widgets/habit_color_sheet/cubit/habit_color_cubit.dart';
import 'core/widgets/habit_icon/cubit/habit_icon_cubit.dart';
import 'features/add_habit/bloc/cubit/reminder_time_cubit.dart';
import 'features/habits/bloc/single_habit/single_habit_bloc.dart';
import 'features/onboarding/bloc/onboarding_bloc.dart';
import 'features/overview/overview_page.dart';
import 'services/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveHelper.shared.initializeHive();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final singleHabitBloc = SingleHabitBloc(habitService: SingleHabitService());
    // final chainedHabitBloc = ChainedHabitBloc(habitService: MockChainedHabitService());
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => singleHabitBloc),
        // BlocProvider(create: (_) => chainedHabitBloc),
        BlocProvider(create: (_) => OnboardingBloc()),

        BlocProvider(create: (_) => ReminderCubit()),
        BlocProvider(create: (_) => HabitIconCubit()),
        BlocProvider(create: (_) => HabitColorCubit()),
      ],
      child: MaterialApp(
        darkTheme: Themes.darkTheme,
        theme: Themes.lightTheme,
        themeMode: ThemeMode.dark,
        debugShowCheckedModeBanner: KDebug.debugModeEnabled,
        navigatorKey: NavigationService.shared.navigatorKey,
        onGenerateRoute: NavigationRoute.shared.generateRoute,
        home: OverviewPage(),
      ),
    );
  }
}
