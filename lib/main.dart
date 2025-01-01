import 'package:habitrise/core/helpers/hive/hive_helper.dart';

import 'core/constants/debug_constants.dart';
import 'core/core.dart';
import 'core/widgets/habit_color_sheet/cubit/habit_color_cubit.dart';
import 'core/widgets/habit_icon/cubit/habit_icon_cubit.dart';
import 'features/add_habit/bloc/cubit/reminder_time_cubit.dart';
import 'features/habits/bloc/chain_habit/chain_habit_bloc.dart';
import 'features/habits/bloc/single_habit/single_habit_bloc.dart';
import 'features/onboarding/bloc/onboarding_bloc.dart';
import 'features/tab_bar/hom_tab_bar_page.dart';
import 'services/single_habit/single_habit_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveHelper.shared.initializeHive();
  

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SingleHabitBloc(habitService: SingleHabitService.shared)),
        BlocProvider(create: (_) => ChainHabitBloc()),
        BlocProvider(create: (_) => OnboardingBloc()),
        BlocProvider(create: (_) => ReminderCubit()),
        BlocProvider(create: (_) => HabitIconCubit()),
        BlocProvider(create: (_) => HabitColorCubit()),
      ],
      child: CupertinoApp(
        debugShowCheckedModeBanner: KDebug.debugModeEnabled,
        navigatorKey: NavigationService.shared.navigatorKey,
        // initialRoute: KRoute.homeTabScaffoldPage,
        onGenerateRoute: NavigationRoute.shared.generateRoute,
        home: HomeTabScaffoldPage(),
        theme: CupertinoThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.grey.shade900,
          barBackgroundColor: Color(0xffF5EFE7).withAlpha(0),
          scaffoldBackgroundColor: Color(0xffF5EFE7),
          applyThemeToAll: true,
          textTheme: CupertinoTextThemeData(
            primaryColor: Colors.grey.shade900,
          ),
        ),
      ),
    );
  }
}
