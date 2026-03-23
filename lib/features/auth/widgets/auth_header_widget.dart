import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '../providers/auth_provider.dart';
import 'user_avatar_widget.dart';

class AuthHeaderWidget extends ConsumerWidget {
  const AuthHeaderWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final userProfile = ref.watch(userProfileProvider).valueOrNull;
    final theme = CupertinoTheme.of(context);

    return authState.when(
      data: (user) {
        if (user == null) {
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
                  Navigator.of(context).pushNamed(KRoute.auth);
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
                Navigator.of(context).pushNamed(KRoute.myAccount);
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
