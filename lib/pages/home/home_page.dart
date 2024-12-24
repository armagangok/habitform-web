import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/extension/datetime_extension.dart';
import 'bloc/basic_habit/habit_bloc.dart';
import 'bloc/chain_habit/chain_habit_bloc.dart';
import 'widgets/chained_habit_item.dart';
import 'widgets/habit_item.dart';
import 'widgets/habit_type_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
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
          const CupertinoSliverNavigationBar(
            leading: Icon(CupertinoIcons.person_2),
            largeTitle: Text('Home'),
            trailing: Icon(CupertinoIcons.add_circled),
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
                  SizedBox(height: 15),
                  (_selectedSegment == 'BasicHabits' ? _buildBasicHabits() : _buildChainedHabits()).animate(controller: controller).fadeIn(),
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
                child: Card(
                  surfaceTintColor: Colors.transparent,
                  elevation: .5,
                  child: Column(
                    children: [
                      ChainedHabitItem(
                        chainedHabit: chainedHabit,
                      ),
                    ],
                  ),
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
