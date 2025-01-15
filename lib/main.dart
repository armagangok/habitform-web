import 'core/constants/debug_constants.dart';
import 'core/core.dart';
import 'core/theme/theme.dart';
import 'core/widgets/habit_color_sheet/cubit/habit_color_cubit.dart';
import 'core/widgets/habit_icon/cubit/habit_icon_cubit.dart';
import 'features/edit_habit/bloc/edit_habit_bloc.dart';
import 'features/habits/bloc/single_habit/single_habit_bloc.dart';
import 'features/onboarding/bloc/onboarding_bloc.dart';
import 'features/overview/overview_page.dart';
import 'features/reminder/bloc/day_selection/day_selection_cubit.dart';
import 'features/reminder/bloc/picker_extend/picker_extend_cubit.dart';
import 'features/reminder/bloc/remind_time/remind_time_cubit.dart';
import 'features/reminder/bloc/reminder/reminder_bloc.dart';
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => singleHabitBloc),
        BlocProvider(create: (_) => OnboardingBloc()),
        BlocProvider(create: (_) => ReminderBloc()),
        BlocProvider(create: (_) => HabitEmojiCubit()),
        BlocProvider(create: (_) => HabitColorCubit()),
        BlocProvider(create: (_) => RemindTimeCubit()),
        BlocProvider(create: (_) => DaySelectionCubit()),
        BlocProvider(create: (_) => PickerExtendCubit()),
        BlocProvider(create: (_) => EditHabitBloc(singleHabitBloc)),
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
