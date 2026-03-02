import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../../core/helpers/url_laucher/url_launcher.dart';

class AccountPrivacySection extends ConsumerWidget {
  const AccountPrivacySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoListSection.insetGrouped(
      header: Text(LocaleKeys.auth_data_and_privacy.tr()),
      children: [
        CupertinoListTile(
          leading: CupertinoCard(
            color: CupertinoColors.systemGreen,
            borderRadius: BorderRadius.circular(5),
            padding: const EdgeInsets.all(2),
            child: Icon(CupertinoIcons.arrow_down_doc_fill, color: Colors.white.withValues(alpha: .9), size: 18),
          ),
          title: Text(LocaleKeys.auth_data_export.tr()),
          onTap: () => navigator.navigateTo(path: KRoute.dataManagement),
          trailing: const CupertinoListTileChevron(),
        ),
        CupertinoListTile(
          leading: CupertinoCard(
            color: CupertinoColors.activeBlue,
            borderRadius: BorderRadius.circular(5),
            padding: const EdgeInsets.all(2),
            child: Icon(CupertinoIcons.hand_raised_fill, color: Colors.white.withValues(alpha: .9), size: 18),
          ),
          title: Text(LocaleKeys.auth_privacy_policy.tr()),
          onTap: UrlLauncherHelper.openPrivacyPolicy,
          trailing: const CupertinoListTileChevron(),
        ),
      ],
    );
  }
}
