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
    await showAppModalSheet<void>(
      context: context,
      builder: (ctx) => _ChangeNameSheetBody(nameController: _nameController),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final createdAt = user.metadata.creationTime;

    return CupertinoListSection.insetGrouped(
      header: Text(context.tr(LocaleKeys.auth_profile)),
      children: [
        if (createdAt != null)
          CupertinoListTile(
            leading: CupertinoCard(
              color: CupertinoColors.systemBlue,
              borderRadius: BorderRadius.circular(5),
              padding: const EdgeInsets.all(2),
              child: Icon(CupertinoIcons.calendar, color: Colors.white.withValues(alpha: .9), size: 18),
            ),
            title: Text(context.tr(LocaleKeys.auth_account_created)),
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
            child: Icon(
              CupertinoIcons.pencil,
              color: Colors.white.withValues(alpha: .9),
              size: 18,
            ),
          ),
          title: Text(context.tr(LocaleKeys.auth_change_display_name)),
          onTap: _showChangeNameSheet,
          trailing: const CupertinoListTileChevron(),
        ),
      ],
    );
  }
}

class _ChangeNameSheetBody extends ConsumerStatefulWidget {
  const _ChangeNameSheetBody({required this.nameController});
  final TextEditingController nameController;

  @override
  ConsumerState<_ChangeNameSheetBody> createState() => _ChangeNameSheetBodyState();
}

class _ChangeNameSheetBodyState extends ConsumerState<_ChangeNameSheetBody> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: context.hideKeyboard,
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            child: Text(context.tr(LocaleKeys.common_cancel)),
          ),
          middle: Text(context.tr(LocaleKeys.auth_change_display_name)),
          trailing: _isLoading
              ? const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: CupertinoActivityIndicator(),
                )
              : CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () async {
                    final name = widget.nameController.text.trim();
                    final error = AuthValidators.validateDisplayName(name);
                    if (error != null) {
                      AppFlushbar.shared.errorFlushbar(error.toString());
                      return;
                    }
                    setState(() => _isLoading = true);
                    try {
                      await ref.read(accountActionsProvider.notifier).updateDisplayName(name);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        AppFlushbar.shared.successFlushbar(context.tr(LocaleKeys.auth_display_name_updated));
                      }
                    } catch (e) {
                      if (context.mounted) AppFlushbar.shared.errorFlushbar(e.toString());
                    } finally {
                      if (mounted) setState(() => _isLoading = false);
                    }
                  },
                  child: Text(context.tr(LocaleKeys.common_save)),
                ),
        ),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CupertinoTextField(
                controller: widget.nameController,
                placeholder: context.tr(LocaleKeys.auth_change_display_name),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                style: context.bodyLarge,
                enabled: !_isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
