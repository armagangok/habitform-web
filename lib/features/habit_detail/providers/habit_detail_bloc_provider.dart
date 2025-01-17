import '../../../core/core.dart';
import '../../../models/models.dart';
import '../bloc/habit_detail_bloc.dart';

class HabitDetailProvider extends StatelessWidget {
  final Widget child;

  final Habit habit;

  const HabitDetailProvider({
    super.key,
    required this.child,
    required this.habit,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => HabitDetailBloc()
            ..add(
              InitializeHabitDetailEvent(habit: habit),
            ),
        ),
      ],
      child: child,
    );
  }
}
