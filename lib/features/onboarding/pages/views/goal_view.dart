// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import '/core/extension/easy_context.dart';
// import '/core/widgets/category_picker.dart';
// import '/features/onboarding/widgets/onboarding_message.dart';
// import '../../bloc/onboarding_bloc.dart';
// import '../../enum/user_goal_enum.dart';

// class GoalView extends StatelessWidget {
//   const GoalView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<OnboardingBloc, OnboardingState>(
//       builder: (context, state) {
//         return SafeArea(
//           child: Padding(
//             padding: EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Spacer(),
//                 OnboardingTitle(data: 'onboarding.goals.title'.tr()),
//                 SizedBox(height: 10),
//                 OnboardingMessage(data: "Select one or more goals that resonate with you from the categories below. We will create the best habit template for you 🚀"),
//                 Spacer(),
//                 MultiCategoryWidget<UserGoal>(
//                   categories: UserGoal.allGoals,
//                   onCategorySelected: (selectedGoals) {
//                     context.read<OnboardingBloc>().add(SelectGoalEvent(goals: selectedGoals));
//                   },
//                   categoryLabelBuilder: (goal) => goal.title,
//                 ),
//                 Spacer(flex: 3),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// class OnboardingTitle extends StatelessWidget {
//   final String data;
//   const OnboardingTitle({
//     super.key,
//     required this.data,
//     this.textAlign,
//   });

//   final TextAlign? textAlign;

//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       data,
//       style: context.displayLarge?.copyWith(
//         fontSize: 20,
//         fontWeight: FontWeight.bold,
//       ),
//       textAlign: textAlign ?? TextAlign.start,
//     );
//   }
// }
