import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../providers/account_actions_provider.dart';
import '../providers/auth_provider.dart';

class AccountDangerZoneSection extends ConsumerStatefulWidget {
  const AccountDangerZoneSection({super.key, required this.user});

  final User user;

  @override
  ConsumerState<AccountDangerZoneSection> createState() => _AccountDangerZoneSectionState();
}

class _AccountDangerZoneSectionState extends ConsumerState<AccountDangerZoneSection> {
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _confirmSignOut() async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(LocaleKeys.auth_sign_out.tr()),
        content: Text(LocaleKeys.auth_sign_out_confirmation.tr()),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(LocaleKeys.common_cancel.tr()),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(LocaleKeys.auth_sign_out.tr()),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      try {
        await ref.read(accountActionsProvider.notifier).signOut();
        if (mounted) Navigator.of(context).pop();
      } catch (e) {
        if (mounted) AppFlushbar.shared.errorFlushbar(e.toString());
      }
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final authService = ref.read(authServiceProvider);
    if (!authService.hasEmailPasswordProvider) {
      AppFlushbar.shared.warningFlushbar(LocaleKeys.auth_password_change_email_only.tr());
      return;
    }
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(LocaleKeys.auth_delete_account.tr()),
        content: Text(
          '${LocaleKeys.auth_delete_account_confirmation.tr()}\n\n${LocaleKeys.auth_delete_account_warning.tr()}',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(LocaleKeys.common_cancel.tr()),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(LocaleKeys.auth_delete_account.tr()),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    _passwordController.clear();
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => GestureDetector(
        onTap: context.hideKeyboard,
        child: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(LocaleKeys.common_cancel.tr()),
            ),
            middle: Text(LocaleKeys.auth_delete_account.tr()),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () async {
                final password = _passwordController.text;
                final email = widget.user.email ?? '';
                if (email.isEmpty || password.isEmpty) {
                  AppFlushbar.shared.errorFlushbar(LocaleKeys.auth_confirm_password_required.tr());
                  return;
                }
                try {
                  await ref.read(accountActionsProvider.notifier).deleteAccount(email, password);
                  if (ctx.mounted) {
                    Navigator.of(ctx).pop();
                    Navigator.of(ctx).pop();
                    AppFlushbar.shared.successFlushbar(LocaleKeys.auth_account_deleted.tr());
                  }
                } catch (e) {
                  if (ctx.mounted) AppFlushbar.shared.errorFlushbar(e.toString());
                }
              },
              child: Text(
                LocaleKeys.auth_delete_account.tr(),
                style: const TextStyle(color: CupertinoColors.systemRed, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          child: SafeArea(
            child: CupertinoListSection.insetGrouped(
              header: Text(LocaleKeys.auth_reauth_prompt.tr()),
              children: [
                CupertinoTextField(
                  controller: _passwordController,
                  placeholder: LocaleKeys.auth_password.tr(),
                  obscureText: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  style: context.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.read(authServiceProvider);
    final hasEmailPassword = authService.hasEmailPasswordProvider;

    return CupertinoListSection.insetGrouped(
      header: Text(
        LocaleKeys.auth_danger_zone.tr(),
        style: TextStyle(color: CupertinoColors.systemRed, fontWeight: FontWeight.w600),
      ),
      children: [
        CupertinoListTile(
          leading: CupertinoCard(
            color: CupertinoColors.systemOrange,
            borderRadius: BorderRadius.circular(5),
            padding: const EdgeInsets.all(2),
            child: Icon(CupertinoIcons.square_arrow_right, color: Colors.white.withValues(alpha: .9), size: 18),
          ),
          title: Text(LocaleKeys.auth_sign_out.tr()),
          onTap: _confirmSignOut,
          trailing: const CupertinoListTileChevron(),
        ),
        if (hasEmailPassword)
          CupertinoListTile(
            leading: CupertinoCard(
              color: CupertinoColors.systemRed,
              borderRadius: BorderRadius.circular(5),
              padding: const EdgeInsets.all(2),
              child: Icon(CupertinoIcons.trash_fill, color: Colors.white.withValues(alpha: .9), size: 18),
            ),
            title: Text(
              LocaleKeys.auth_delete_account.tr(),
              style: const TextStyle(color: CupertinoColors.systemRed, fontWeight: FontWeight.w600),
            ),
            onTap: _confirmDeleteAccount,
            trailing: const CupertinoListTileChevron(),
          ),
      ],
    );
  }
}
