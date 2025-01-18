// import '/core/core.dart';
// import '../../bloc/onboarding_bloc.dart';
// import '../../widgets/onboarding_message.dart';

// class NameView extends StatelessWidget {
//   const NameView({super.key});

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
//                 OnboardingTitle(data: "What's your name?"),
//                 SizedBox(height: 10),
//                 OnboardingMessage(data: "Tell your name, so we can address you personally 😊"),
//                 Spacer(),
//                 CupertinoTextField(
//                   placeholder: "Your name goes here",
//                   controller: context.read<OnboardingBloc>().nameTextController,
//                   onChanged: (value) {
//                     context.read<OnboardingBloc>().add(NameChangedEvent(value));
//                   },
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
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       data,
//       style: context.displayLarge?.copyWith(
//         fontSize: 20,
//         fontWeight: FontWeight.bold,
//       ),
//       textAlign: TextAlign.start,
//     );
//   }
// }
