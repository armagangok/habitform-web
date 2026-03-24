import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../providers/account_actions_provider.dart';

class AccountLinkedAccountsSection extends ConsumerWidget {
  const AccountLinkedAccountsSection({super.key, required this.user});

  final User user;

  Future<void> _handleLink(BuildContext context, WidgetRef ref, String providerId) async {
    try {
      if (providerId == 'google.com') {
        await ref.read(accountActionsProvider.notifier).linkGoogle();
      } else if (providerId == 'apple.com') {
        await ref.read(accountActionsProvider.notifier).linkApple();
      } else if (providerId == 'password') {
        await _showEmailPasswordLinkingDialog(context, ref);
        return; // Dialog handles the linking
      }
      AppFlushbar.shared.successFlushbar(LocaleKeys.auth_link_success.tr());
    } catch (e) {
      AppFlushbar.shared.errorFlushbar(e.toString());
    }
  }

  Future<void> _showEmailPasswordLinkingDialog(BuildContext context, WidgetRef ref) async {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    await showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(LocaleKeys.auth_linked_email.tr()),
        content: Column(
          children: [
            const SizedBox(height: 12),
            CupertinoTextField(
              controller: emailController,
              placeholder: LocaleKeys.auth_email.tr(),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 8),
            CupertinoTextField(
              controller: passwordController,
              placeholder: LocaleKeys.auth_password.tr(),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr(LocaleKeys.common_cancel)),
          ),
          CupertinoDialogAction(
            onPressed: () async {
              if (emailController.text.isEmpty || passwordController.text.isEmpty) return;
              Navigator.pop(ctx);
              try {
                await ref.read(accountActionsProvider.notifier).linkEmail(
                      emailController.text.trim(),
                      passwordController.text,
                    );
                AppFlushbar.shared.successFlushbar(LocaleKeys.auth_link_success.tr());
              } catch (e) {
                AppFlushbar.shared.errorFlushbar(e.toString());
              }
            },
            child: Text(context.tr(LocaleKeys.auth_link)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providers = user.providerData;
    final hasGoogle = providers.any((p) => p.providerId == 'google.com');
    final hasApple = providers.any((p) => p.providerId == 'apple.com');
    final hasPassword = providers.any((p) => p.providerId == 'password');
    final actionState = ref.watch(accountActionsProvider);

    return CupertinoListSection.insetGrouped(
      header: Text(context.tr(LocaleKeys.auth_linked_accounts)),
      children: [
        _buildProviderTile(
          context,
          ref,
          icon: FontAwesomeIcons.google,
          iconColor: CupertinoColors.systemOrange,
          title: context.tr(LocaleKeys.auth_linked_google),
          isLinked: hasGoogle,
          providerId: 'google.com',
          isLoading: actionState.isLoading,
        ),
        _buildProviderTile(
          context,
          ref,
          icon: FontAwesomeIcons.apple,
          iconColor: CupertinoColors.black,
          title: context.tr(LocaleKeys.auth_linked_apple),
          isLinked: hasApple,
          providerId: 'apple.com',
          isLoading: actionState.isLoading,
        ),
        _buildProviderTile(
          context,
          ref,
          icon: CupertinoIcons.mail_solid,
          iconColor: CupertinoColors.systemBlue,
          title: context.tr(LocaleKeys.auth_linked_email),
          isLinked: hasPassword,
          providerId: 'password',
          isLoading: actionState.isLoading,
        ),
      ],
    );
  }

  Widget _buildProviderTile(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool isLinked,
    required String providerId,
    required bool isLoading,
  }) {
    return CupertinoListTile(
      leading: CupertinoCard(
        color: iconColor,
        borderRadius: BorderRadius.circular(5),
        padding: const EdgeInsets.all(2),
        child: Icon(icon, color: Colors.white.withValues(alpha: .9), size: 18),
      ),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLinked) ...[
            const Icon(CupertinoIcons.checkmark_circle_fill, color: CupertinoColors.systemGreen, size: 20),
          ] else ...[
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: isLoading ? null : () => _handleLink(context, ref, providerId),
              child: Text(
                context.tr(LocaleKeys.auth_link),
                style: context.bodyMedium.copyWith(
                  color: context.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
