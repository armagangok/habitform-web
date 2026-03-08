import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../providers/account_actions_provider.dart';
import '../utils/auth_validators.dart';

class AccountProfileSection extends ConsumerStatefulWidget {
  const AccountProfileSection({super.key, required this.user});

  final User user;

  @override
  ConsumerState<AccountProfileSection> createState() => _AccountProfileSectionState();
}

class _AccountProfileSectionState extends ConsumerState<AccountProfileSection> {
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.displayName ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _showChangeNameSheet() async {
    _nameController.text = widget.user.displayName ?? '';
    await showCupertinoSheet<void>(
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
            middle: Text(LocaleKeys.auth_change_display_name.tr()),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () async {
                final name = _nameController.text.trim();
                final error = AuthValidators.validateDisplayName(name);
                if (error != null) {
                  AppFlushbar.shared.errorFlushbar(error.tr());
                  return;
                }
                try {
                  await ref.read(accountActionsProvider.notifier).updateDisplayName(name);
                  if (ctx.mounted) {
                    Navigator.of(ctx).pop();
                    AppFlushbar.shared.successFlushbar(LocaleKeys.auth_display_name_updated.tr());
                  }
                } catch (e) {
                  if (ctx.mounted) AppFlushbar.shared.errorFlushbar(e.toString());
                }
              },
              child: Text(LocaleKeys.common_save.tr()),
            ),
          ),
          child: ListView(
            children: [
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CupertinoTextField(
                  controller: _nameController,
                  placeholder: LocaleKeys.auth_change_display_name.tr(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  style: context.bodyLarge,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final user = widget.user;
    final createdAt = user.metadata.creationTime;
    final emailVerified = user.emailVerified;

    return CupertinoListSection.insetGrouped(
      header: Text(LocaleKeys.auth_profile.tr()),
      children: [
        CupertinoListTile(
          leading: user.photoURL != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    user.photoURL!,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                  ),
                )
              : Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.person_fill,
                    color: theme.primaryColor,
                    size: 24,
                  ),
                ),
          title: Text(user.displayName ?? user.email ?? ''),
          subtitle: Text(
            user.email ?? '',
            style: context.bodySmall.copyWith(color: CupertinoColors.secondaryLabel.resolveFrom(context)),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (emailVerified) Icon(CupertinoIcons.checkmark_seal_fill, color: CupertinoColors.systemGreen, size: 18),
              if (emailVerified) const SizedBox(width: 4),
              const CupertinoListTileChevron(),
            ],
          ),
        ),
        if (createdAt != null)
          CupertinoListTile(
            leading: CupertinoCard(
              color: CupertinoColors.systemBlue,
              borderRadius: BorderRadius.circular(5),
              padding: const EdgeInsets.all(2),
              child: Icon(CupertinoIcons.calendar, color: Colors.white.withValues(alpha: .9), size: 18),
            ),
            title: Text(LocaleKeys.auth_account_created.tr()),
            subtitle: Text(
              '${createdAt.day}/${createdAt.month}/${createdAt.year}',
              style: context.bodySmall.copyWith(color: CupertinoColors.secondaryLabel.resolveFrom(context)),
            ),
          ),
        CupertinoListTile(
          leading: CupertinoCard(
            color: CupertinoColors.systemOrange,
            borderRadius: BorderRadius.circular(5),
            padding: const EdgeInsets.all(2),
            child: Icon(CupertinoIcons.pencil, color: Colors.white.withValues(alpha: .9), size: 18),
          ),
          title: Text(LocaleKeys.auth_change_display_name.tr()),
          onTap: _showChangeNameSheet,
          trailing: const CupertinoListTileChevron(),
        ),
      ],
    );
  }
}
