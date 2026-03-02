import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../providers/auth_provider.dart';

class AuthHeaderWidget extends ConsumerWidget {
  const AuthHeaderWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final theme = CupertinoTheme.of(context);

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
                  Navigator.of(context).pushNamed(KRoute.auth);
                },
              ),
            ],
          );
        }

        final imageUrl = user.photoURL;
        final displayName = user.displayName;
        final email = user.email;

        return CupertinoListSection.insetGrouped(
          footer: const SizedBox.shrink(),
          children: [
            CupertinoListTile(
              onTap: () {
                Navigator.of(context).pushNamed(KRoute.myAccount);
              },
              leading: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                    )
                  : Icon(
                      CupertinoIcons.person_crop_circle_fill,
                      color: theme.primaryColor,
                      size: 30,
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
