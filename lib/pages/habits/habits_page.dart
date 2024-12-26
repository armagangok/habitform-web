import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habitrise/core/widgets/trailing_button.dart';

import '../../core/extension/datetime_extension.dart';
import 'bloc/basic_habit/habit_bloc.dart';
import 'bloc/chain_habit/chain_habit_bloc.dart';
import 'widgets/chained_habit_item.dart';
import 'widgets/habit_item.dart';
import 'widgets/habit_type_widget.dart';

class HabitsPage extends StatefulWidget {
  const HabitsPage({super.key});

  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage> with SingleTickerProviderStateMixin {
  String _selectedSegment = 'BasicHabits';

  late final AnimationController controller;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: Duration(milliseconds: 250));

    context.read<HabitBloc>().add(FetchHabitsEvent());
    context.read<HabitBloc>().add(IdleHabitEvent());
    context.read<ChainHabitBloc>().add((FetchChainedHabitEvent()));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            largeTitle: Text('Habits'),
            trailing: TrailingActionButton(
              onPressed: () {},
              child: Icon(
                CupertinoIcons.add_circled,
                size: 32,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  HabitTypeSegmentedControl(
                    selectedSegment: _selectedSegment,
                    onSegmentChanged: (value) {
                      setState(() => _selectedSegment = value);
                      controller.forward(from: 0);
                    },
                  ),
                  SizedBox(height: 10),
                  if (_selectedSegment == 'BasicHabits') _buildBasicHabits().animate(controller: controller),
                  if (_selectedSegment == 'ChainedHabits') _buildChainedHabits().animate(controller: controller),
                  if (_selectedSegment == 'HabitsToBreak') _buildBasicHabits().animate(controller: controller),
                ],
              ),
            ]),
          )
        ],
      ),
    );
  }

  // Normal Alışkanlıklar için içerik
  Widget _buildBasicHabits() {
    return BlocBuilder<HabitBloc, HabitState>(
      builder: (context, state) {
        switch (state.runtimeType) {
          case const (HabitInitial):
            return SizedBox.shrink();
          case const (HabitsLoading):
            return Center(child: CupertinoActivityIndicator());
          case const (HabitsFetched):
            state as HabitsFetched;
            return ListView.builder(
              itemCount: state.habits.length,
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final habit = state.habits[index];

                return HabitItem(
                  habitName: habit.habitName,
                  subtitle: habit.completeTime.toHHMM(),
                  value: habit.isCompleted,
                );
              },
            );

          case const (HabitsFetchError):
            state as HabitsFetchError;
            return Center(
              child: Text(state.message),
            );

          default:
            return Text("");
        }
      },
    );
  }

  // Zincirlenmiş Alışkanlıklar için içerik
  Widget _buildChainedHabits() {
    return BlocBuilder<ChainHabitBloc, ChainHabitState>(
      builder: (context, state) {
        if (state is ChainHabitInitial) {
          return SizedBox.shrink();
        } else if (state is ChainHabitsLoading) {
          return Center(
            child: CupertinoActivityIndicator(),
          );
        } else if (state is ChainHabitsFetched) {
          return ListView.builder(
            itemCount: state.habits.length,
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final chainedHabit = state.habits[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: ChainedHabitItem(
                  chainedHabit: chainedHabit,
                ),
              );
            },
          );
        } else if (state is ChainHabitsFetchError) {}
        return SizedBox.shrink();
      },
    );
  }
}
