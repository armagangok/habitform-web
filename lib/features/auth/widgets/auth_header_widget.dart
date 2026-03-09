import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/features/purchase/page/pre_paywall_page.dart';
import '../../purchase/providers/purchase_provider.dart';
import '../providers/auth_provider.dart';
import 'user_avatar_widget.dart';

class AuthHeaderWidget extends ConsumerWidget {
  const AuthHeaderWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final userProfile = ref.watch(userProfileProvider).valueOrNull;
    final theme = CupertinoTheme.of(context);

    final paywallState = ref.watch(purchaseProvider);
    final isPro = paywallState.valueOrNull?.isSubscriptionActive ?? false;

    void showProAlert() {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text("Pro Özellik"),
          content: const Text("Alışkanlıklarınızı senkronize edebilmek için ve farklı cihazlarda da cross-device support olması için pro olun"),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text("İptal"),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.pop(context);
                showCupertinoSheet(
                  enableDrag: false,
                  context: context,
                  builder: (context) => PrePaywallPage(
                    isFromOnboarding: false,
                    isFromSettings: true,
                  ),
                );
              },
              child: const Text("Pro Ol"),
            ),
          ],
        ),
      );
    }

    return authState.when(
      data: (user) {
        if (user == null || user.isAnonymous) {
          return CupertinoListSection.insetGrouped(
            footer: Text(
              LocaleKeys.auth_my_account_description.tr(),
            ),
            children: [
              CupertinoListTile(
                leading: Icon(
                  CupertinoIcons.person_crop_circle_fill,
                  color: theme.primaryColor,
                  size: 30,
                ),
                title: Text(LocaleKeys.auth_my_account.tr()),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  if (isPro) {
                    Navigator.of(context).pushNamed(KRoute.auth);
                  } else {
                    showProAlert();
                  }
                },
              ),
            ],
          );
        }

        final imageUrl = userProfile?.photoUrl ?? user.photoURL;
        final displayName = userProfile?.displayName ?? user.displayName;
        final email = userProfile?.email ?? user.email;

        return CupertinoListSection.insetGrouped(
          footer: const SizedBox.shrink(),
          children: [
            CupertinoListTile(
              onTap: () {
                if (isPro) {
                  Navigator.of(context).pushNamed(KRoute.myAccount);
                } else {
                  showProAlert();
                }
              },
              leading: UserAvatarWidget(
                photoUrl: imageUrl,
                radius: 18,
              ),
              title: Text(displayName ?? email ?? ''),
              trailing: CupertinoListTileChevron(),
            ),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(child: CupertinoActivityIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
