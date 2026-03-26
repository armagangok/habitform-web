import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../../core/widgets/custom_list_tile.dart';
import '../../purchase/providers/purchase_provider.dart';

class MembershipInfoButton extends ConsumerWidget {
  const MembershipInfoButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomSection(
      child: Column(
        children: [
          CustomListTile(
            leading: FaIcon(
              FontAwesomeIcons.info,
              color: context.primaryContrastingColor,
            ),
            title: context.tr(LocaleKeys.membership_info_title),
            onTap: () async {
              await ref.read(purchaseProvider.notifier).presentCustomerCenter();
            },
            trailing: const CupertinoListTileChevron(),
            additionalInfo: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CupertinoCard(
                  color: context.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  child: Text(
                    'Pro',
                    style: context.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//                               Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Text(
//                                     LocaleKeys.membership_info_title.tr(),
//                                     style: context.titleMedium.copyWith(fontWeight: FontWeight.bold),
//                                   ),
//                                   const SizedBox(width: 8),
//                                   CupertinoCard(
//                                     color: context.primary,
//                                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
//                                     child: Text(
//                                       'Pro',
//                                       style: context.titleMedium.copyWith(
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               Text(
//                                 LocaleKeys.membership_info_description.tr(),
//                                 style: context.bodySmall.copyWith(
//                                   color: context.cupertinoTextTheme.textStyle.color?.withValues(alpha: 0.7),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const CupertinoListTileChevron(),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
