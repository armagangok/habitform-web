import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/debug_constants.dart';
import 'core/navigation/navigation.dart';
import 'pages/home/bloc/basic_habit/habit_bloc.dart';
import 'pages/home/bloc/chain_habit/chain_habit_bloc.dart';
import 'pages/onboarding/bloc/onboarding_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => HabitBloc()),
        BlocProvider(create: (_) => ChainHabitBloc()),
        BlocProvider(create: (_) => OnboardingBloc()),
      ],
      child: CupertinoApp(
        debugShowCheckedModeBanner: KDebug.debugModeEnabled,
        navigatorKey: NavigationService.shared.navigatorKey,
        // navigatorObservers: [
        //   customObserver,
        // ],
        initialRoute: KRoute.onboardingGreeting,
        onGenerateRoute: NavigationRoute.shared.generateRoute,
        theme: CupertinoThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.grey.shade900,
          barBackgroundColor: Color(0xffF5EFE7).withAlpha(100),
          scaffoldBackgroundColor: Color(
            0xffF5EFE7,
          ),
          applyThemeToAll: true,
          textTheme: CupertinoTextThemeData(
            primaryColor: Colors.grey.shade900,
          ),
        ),
      ),
    );
  }
}
