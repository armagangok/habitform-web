// import '/core/core.dart';
// import '../bloc/paywall_bloc.dart';
// import 'paywall_widget.dart';

// class UnlockPremiumDialog extends StatelessWidget {
//   const UnlockPremiumDialog({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<PaywallBloc, PaywallState>(
//       builder: (context, state) {
//         if (state is! PaywallLoaded) {
//           return SizedBox.shrink();
//         }

//         if (state.isSubscriptionActive) {
//           return SizedBox.shrink();
//         }

//         return CupertinoButton(
//           padding: EdgeInsets.zero,
//           onPressed: () {
//             showCupertinoModalBottomSheet(
//               expand: true,
//               elevation: 0,
//               enableDrag: false,
//               context: context,
//               builder: (contextFromSheet) => PaywallWidget(),
//             );
//           },
//           child: Card(
//             color: context.primary,
//             child: Padding(
//               padding: EdgeInsets.all(12),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     LocaleKeys.unlockPremium.tr(),
//                     style: context.titleMedium?.copyWith(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   SizedBox(width: 8),
//                   Icon(
//                     CupertinoIcons.sparkles,
//                     color: Colors.white,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
