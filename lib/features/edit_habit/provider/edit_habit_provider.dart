import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/habit_color_sheet/cubit/habit_color_cubit.dart';
import '../../../core/widgets/habit_icon/cubit/habit_icon_cubit.dart';
import '../../../models/models.dart';
import '../../habits/bloc/habit_bloc.dart';
import '../bloc/edit_habit_bloc.dart';

class EditHabitProvider extends StatelessWidget {
  final Widget child;
  final Habit habit;

  const EditHabitProvider({
    super.key,
    required this.child,
    required this.habit,
  });

  @override
  Widget build(BuildContext context) {
    final habitBloc = context.read<HabitBloc>();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => HabitEmojiCubit()),
        BlocProvider(create: (_) => HabitColorCubit()),
        BlocProvider(create: (_) => EditHabitBloc(habitBloc)),
      ],
      child: child,
    );
  }
}
