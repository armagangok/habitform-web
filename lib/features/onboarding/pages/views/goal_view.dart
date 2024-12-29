// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habitrise/core/extension/easy_context.dart';
import 'package:habitrise/core/widgets/category_picker.dart';
import 'package:habitrise/features/onboarding/widgets/onboarding_message.dart';

import '../../bloc/onboarding_bloc.dart';

class GoalView extends StatelessWidget {
  const GoalView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Spacer(),
                OnboardingTitle(data: "What’s your main goal/goals for using HabitRise?"),
                SizedBox(height: 10),
                OnboardingMessage(data: "Select one or more goals that resonate with you from the categories below. We will create the best habit template for you 🚀"),
                Spacer(),
                MultiCategoryWidget(
                  categories: [
                    "Better productivity",
                    "Build a routine",
                    "Break bad habits",
                    "Get healthier",
                    "Time management",
                    "Reduce stress",
                    "Other",
                  ],
                  onCategorySelected: (val) {
                    context.read<OnboardingBloc>().add(SelectGoalEvent(goals: val));
                  },
                ),
                Spacer(flex: 3),
              ],
            ),
          ),
        );
      },
    );
  }
}

class OnboardingTitle extends StatelessWidget {
  final String data;
  const OnboardingTitle({
    super.key,
    required this.data,
    this.textAlign,
  });

  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: context.displayLarge.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      textAlign: textAlign ?? TextAlign.start,
    );
  }
}
