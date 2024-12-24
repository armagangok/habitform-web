import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'pages/home/bloc/basic_habit/habit_bloc.dart';
import 'pages/home/bloc/chain_habit/chain_habit_bloc.dart';
import 'pages/home/home_page.dart';

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
      ],
      child: CupertinoApp(
        theme: CupertinoThemeData(
          brightness: Brightness.light,
          primaryColor: Color(0xff3E5879),
          barBackgroundColor: Color(0xffF5EFE7).withAlpha(100),
          scaffoldBackgroundColor: Color(
            0xffF5EFE7,
          ),
          applyThemeToAll: true,
          textTheme: CupertinoTextThemeData(
            primaryColor: Color(0xff3E5879),
          ),
        ),
        home: HomePage(),
      ),
    );
  }
}
