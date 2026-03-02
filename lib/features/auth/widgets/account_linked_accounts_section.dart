import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';

class AccountLinkedAccountsSection extends ConsumerWidget {
  const AccountLinkedAccountsSection({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providers = user.providerData;
    final hasGoogle = providers.any((p) => p.providerId == 'google.com');
    final hasApple = providers.any((p) => p.providerId == 'apple.com');
    final hasPassword = providers.any((p) => p.providerId == 'password');

    if (!hasGoogle && !hasApple && !hasPassword) {
      return const SizedBox.shrink();
    }

    return CupertinoListSection.insetGrouped(
      header: Text(LocaleKeys.auth_linked_accounts.tr()),
      children: [
        if (hasGoogle)
          CupertinoListTile(
            leading: CupertinoCard(
              color: CupertinoColors.systemOrange,
              borderRadius: BorderRadius.circular(5),
              padding: const EdgeInsets.all(2),
              child: Icon(FontAwesomeIcons.google, color: Colors.white.withValues(alpha: .9), size: 18),
            ),
            title: Text(LocaleKeys.auth_linked_google.tr()),
            trailing: Icon(CupertinoIcons.checkmark_circle_fill, color: CupertinoColors.systemGreen, size: 20),
          ),
        if (hasApple)
          CupertinoListTile(
            leading: CupertinoCard(
              color: CupertinoColors.black,
              borderRadius: BorderRadius.circular(5),
              padding: const EdgeInsets.all(2),
              child: Icon(FontAwesomeIcons.apple, color: Colors.white.withValues(alpha: .9), size: 18),
            ),
            title: Text(LocaleKeys.auth_linked_apple.tr()),
            trailing: Icon(CupertinoIcons.checkmark_circle_fill, color: CupertinoColors.systemGreen, size: 20),
          ),
        if (hasPassword)
          CupertinoListTile(
            leading: CupertinoCard(
              color: CupertinoColors.systemBlue,
              borderRadius: BorderRadius.circular(5),
              padding: const EdgeInsets.all(2),
              child: Icon(CupertinoIcons.mail_solid, color: Colors.white.withValues(alpha: .9), size: 18),
            ),
            title: Text(LocaleKeys.auth_linked_email.tr()),
            trailing: Icon(CupertinoIcons.checkmark_circle_fill, color: CupertinoColors.systemGreen, size: 20),
          ),
      ],
    );
  }
}
