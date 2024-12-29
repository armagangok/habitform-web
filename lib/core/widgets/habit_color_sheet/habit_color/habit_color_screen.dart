import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habitrise/core/widgets/habit_color_sheet/habit_color/habit_color_cubit.dart';
import 'package:habitrise/core/widgets/habit_color_sheet/habit_color/habit_color_state.dart';

class HabitColorScreen extends StatefulWidget {
  const HabitColorScreen({super.key});

  @override
  HabitColorScreenState createState() => HabitColorScreenState();
}

class HabitColorScreenState extends State<HabitColorScreen> {
  final screenCubit = HabitColorCubit();

  @override
  void initState() {
    screenCubit.loadInitialData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<HabitColorCubit, HabitColorState>(
        bloc: screenCubit,
        listener: (BuildContext context, HabitColorState state) {
          if (state.error != null) {
            // TODO your code here
          }
        },
        builder: (BuildContext context, HabitColorState state) {
          if (state.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          return buildBody(state);
        },
      ),
    );
  }

  Widget buildBody(HabitColorState state) {
    return ListView(
      children: [
        // TODO your code here
      ],
    );
  }
}
