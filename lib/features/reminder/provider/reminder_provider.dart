import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/day_selection/day_selection_cubit.dart';
import '../bloc/picker_extend/picker_extend_cubit.dart';
import '../bloc/remind_time/remind_time_cubit.dart';
import '../bloc/reminder/reminder_bloc.dart';

class ReminderProvider extends StatelessWidget {
  final Widget child;

  const ReminderProvider({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final reminderBloc = context.read<ReminderBloc>();

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: reminderBloc),
        BlocProvider(create: (_) => RemindTimeCubit()),
        BlocProvider(create: (_) => DaySelectionCubit()),
        BlocProvider(create: (_) => PickerExtendCubit()),
      ],
      child: child,
    );
  }
}
