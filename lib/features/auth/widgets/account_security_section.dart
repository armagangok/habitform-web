import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../providers/account_actions_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/auth_validators.dart';

class AccountSecuritySection extends ConsumerStatefulWidget {
  const AccountSecuritySection({super.key, required this.user});

  final User user;

  @override
  ConsumerState<AccountSecuritySection> createState() => _AccountSecuritySectionState();
}

class _AccountSecuritySectionState extends ConsumerState<AccountSecuritySection> {
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _showChangeEmailSheet() async {
    _emailController.text = '';
    await showAppModalSheet<void>(
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
            middle: Text(LocaleKeys.auth_change_email.tr()),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () async {
                final email = _emailController.text.trim();
                final error = AuthValidators.validateEmail(email);
                if (error != null) {
                  LogHelper.shared.errorPrint(error);
                  return;
                }
                try {
                  await ref.read(accountActionsProvider.notifier).updateEmail(email);
                  if (ctx.mounted) {
                    Navigator.of(ctx).pop();
                    AppFlushbar.shared.successFlushbar(LocaleKeys.auth_email_update_sent.tr());
                  }
                } catch (e) {
                  if (ctx.mounted) AppFlushbar.shared.errorFlushbar(e.toString());
                }
              },
              child: Text(LocaleKeys.common_save.tr()),
            ),
          ),
          child: SafeArea(
            child: CupertinoListSection.insetGrouped(
              children: [
                CupertinoTextField(
                  controller: _emailController,
                  placeholder: 'user@example.com',
                  keyboardType: TextInputType.emailAddress,
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

  Future<void> _showChangePasswordSheet() async {
    final authService = ref.read(authServiceProvider);
    if (!authService.hasEmailPasswordProvider) {
      AppFlushbar.shared.warningFlushbar(LocaleKeys.auth_password_change_email_only.tr());
      return;
    }
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
    await showAppModalSheet<void>(
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
            middle: Text(LocaleKeys.auth_change_password.tr()),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () async {
                final current = _currentPasswordController.text;
                final newPw = _newPasswordController.text;
                final confirm = _confirmPasswordController.text;
                var err = AuthValidators.validatePassword(current);
                if (err != null) {
                  AppFlushbar.shared.errorFlushbar(err.tr());
                  return;
                }
                err = AuthValidators.validatePassword(newPw);
                if (err != null) {
                  AppFlushbar.shared.errorFlushbar(err.tr());
                  return;
                }
                err = AuthValidators.validateConfirmPassword(confirm, newPw);
                if (err != null) {
                  AppFlushbar.shared.errorFlushbar(err.tr());
                  return;
                }
                try {
                  await ref.read(accountActionsProvider.notifier).updatePassword(current, newPw);
                  if (ctx.mounted) {
                    Navigator.of(ctx).pop();
                    AppFlushbar.shared.successFlushbar(LocaleKeys.auth_password_updated.tr());
                  }
                } catch (e) {
                  if (ctx.mounted) AppFlushbar.shared.errorFlushbar(e.toString());
                }
              },
              child: Text(LocaleKeys.common_save.tr()),
            ),
          ),
          child: SafeArea(
            child: ListView(
              shrinkWrap: true,
              children: [
                CupertinoListSection.insetGrouped(
                  header: Text(LocaleKeys.auth_current_password.tr()),
                  children: [
                    CupertinoTextField(
                      controller: _currentPasswordController,
                      placeholder: '••••••••',
                      obscureText: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      style: context.bodyLarge,
                    ),
                  ],
                ),
                CupertinoListSection.insetGrouped(
                  header: Text(LocaleKeys.auth_new_password.tr()),
                  children: [
                    CupertinoTextField(
                      controller: _newPasswordController,
                      placeholder: '••••••••',
                      obscureText: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      style: context.bodyLarge,
                    ),
                  ],
                ),
                CupertinoListSection.insetGrouped(
                  header: Text(LocaleKeys.auth_confirm_password.tr()),
                  children: [
                    CupertinoTextField(
                      controller: _confirmPasswordController,
                      placeholder: '••••••••',
                      obscureText: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      style: context.bodyLarge,
                    ),
                  ],
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
      header: Text(LocaleKeys.auth_security.tr()),
      children: [
        CupertinoListTile(
          leading: CupertinoCard(
            color: CupertinoColors.systemBlue,
            borderRadius: BorderRadius.circular(5),
            padding: const EdgeInsets.all(2),
            child: Icon(CupertinoIcons.mail_solid, color: Colors.white.withValues(alpha: .9), size: 18),
          ),
          title: Text(LocaleKeys.auth_change_email.tr()),
          onTap: _showChangeEmailSheet,
          trailing: const CupertinoListTileChevron(),
        ),
        if (hasEmailPassword)
          CupertinoListTile(
            leading: CupertinoCard(
              color: CupertinoColors.systemGreen,
              borderRadius: BorderRadius.circular(5),
              padding: const EdgeInsets.all(2),
              child: Icon(CupertinoIcons.lock_fill, color: Colors.white.withValues(alpha: .9), size: 18),
            ),
            title: Text(LocaleKeys.auth_change_password.tr()),
            onTap: _showChangePasswordSheet,
            trailing: const CupertinoListTileChevron(),
          ),
        // CupertinoListTile(
        //   leading: CupertinoCard(
        //     color: CupertinoColors.systemIndigo,
        //     borderRadius: BorderRadius.circular(5),
        //     padding: const EdgeInsets.all(2),
        //     child: Icon(CupertinoIcons.shield_fill, color: Colors.white.withValues(alpha: .9), size: 18),
        //   ),
        //   title: Text(LocaleKeys.auth_two_factor_not_enabled.tr(), maxLines: 4),
        // ),
      ],
    );
  }
}
