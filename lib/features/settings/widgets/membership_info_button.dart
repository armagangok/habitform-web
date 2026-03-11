import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../purchase/providers/purchase_provider.dart';

class MembershipInfoButton extends ConsumerWidget {
  const MembershipInfoButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomButton(
      onPressed: () async {
        await ref.read(purchaseProvider.notifier).presentCustomerCenter();
      },
      child: CupertinoListSection.insetGrouped(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.person_crop_circle_badge_checkmark,
                  color: context.primary,
                  size: 28,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            LocaleKeys.membership_info_title.tr(),
                            style: context.titleMedium.copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 8),
                          CupertinoCard(
                            color: context.primary,
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
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
                      Text(
                        LocaleKeys.membership_info_description.tr(),
                        style: context.bodySmall.copyWith(
                          color: context.cupertinoTextTheme.textStyle.color?.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                CupertinoListTileChevron(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
