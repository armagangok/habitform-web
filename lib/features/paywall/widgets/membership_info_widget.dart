// import '/core/core.dart';
// import '../bloc/paywall_bloc.dart';
// import 'paywall_widget.dart';

// class MembershipInfoWidget extends StatelessWidget {
//   const MembershipInfoWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<PaywallBloc, PaywallState>(
//       builder: (context, state) {
//         if (state is! PaywallLoaded) {
//           return SizedBox.shrink();
//         }

//         return CupertinoListTile(
//           title: Text(
//             LocaleKeys.membership.tr(),
//             style: context.titleMedium?.copyWith(
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           subtitle: Text(
//             state.isSubscriptionActive ? LocaleKeys.premium.tr() : LocaleKeys.free.tr(),
//             style: context.bodySmall?.copyWith(
//               color: state.isSubscriptionActive ? context.primary : context.bodySmall?.color,
//             ),
//           ),
//           trailing: state.isSubscriptionActive
//               ? Icon(
//                   CupertinoIcons.checkmark_alt_circle_fill,
//                   color: context.primary,
//                 )
//               : CupertinoButton(
//                   padding: EdgeInsets.zero,
//                   onPressed: () {
//                     showCupertinoModalBottomSheet(
//                       expand: true,
//                       elevation: 0,
//                       enableDrag: false,
//                       context: context,
//                       builder: (contextFromSheet) => PaywallWidget(),
//                     );
//                   },
//                   child: Text(
//                     LocaleKeys.upgrade.tr(),
//                     style: context.bodySmall?.copyWith(
//                       color: context.primary,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//         );
//       },
//     );
//   }
// }
