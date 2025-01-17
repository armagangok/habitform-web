import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/habit_color_sheet/cubit/habit_color_cubit.dart';
import '../../../core/widgets/habit_icon/cubit/habit_icon_cubit.dart';

class AddHabitProvider extends StatelessWidget {
  final Widget child;

  const AddHabitProvider({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => HabitEmojiCubit()),
        BlocProvider(create: (_) => HabitColorCubit()),
      ],
      child: child,
    );
  }
}
