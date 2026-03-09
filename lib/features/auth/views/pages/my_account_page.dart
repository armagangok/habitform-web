import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/core.dart';
import '../../providers/account_actions_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/account_danger_zone_section.dart';
import '../../widgets/account_linked_accounts_section.dart';
import '../../widgets/account_privacy_section.dart';
import '../../widgets/account_profile_section.dart';
import '../../widgets/account_security_section.dart';
import '../../widgets/auth_header_widget.dart';
import '../../widgets/user_avatar_widget.dart';

class MyAccountPage extends ConsumerWidget {
  final bool isFromHome;
  const MyAccountPage({super.key, this.isFromHome = false});

  Future<void> _pickAndUploadImage(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final source = await showCupertinoModalPopup<ImageSource>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text(LocaleKeys.auth_profile.tr()),
        message: const Text('Profil fotoğrafınızı değiştirmek için bir kaynak seçin.'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(ctx, ImageSource.camera),
            child: const Text('Kamera'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(ctx, ImageSource.gallery),
            child: const Text('Galeri'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(ctx, null), // We use null to signal delete in a second step or just use a separate action
            child: const Text('Fotoğrafı Sil'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: Text(LocaleKeys.common_cancel.tr()),
        ),
      ),
    );

    // Re-show for delete confirmation or handle it directly
    if (source == null) {
      // Check if user clicked delete (we passed null above for simplicity, let's refine)
      return;
    }

    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 75,
    );

    if (pickedFile == null) return;

    try {
      await ref.read(accountActionsProvider.notifier).updateProfilePhoto(pickedFile.path);
      AppFlushbar.shared.successFlushbar('Profil fotoğrafı güncellendi');
    } catch (e) {
      AppFlushbar.shared.errorFlushbar(e.toString());
    }
  }

  Future<void> _handlePhotoAction(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final action = await showCupertinoModalPopup<String>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text(LocaleKeys.auth_profile.tr()),
        message: const Text('Profil fotoğrafınızı yönetin.'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(ctx, 'camera'),
            child: const Text('Kamera'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(ctx, 'gallery'),
            child: const Text('Galeri'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(ctx, 'delete'),
            child: const Text('Fotoğrafı Sil'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: Text(LocaleKeys.common_cancel.tr()),
        ),
      ),
    );

    if (action == null) return;

    if (action == 'delete') {
      try {
        await ref.read(accountActionsProvider.notifier).deleteProfilePhoto();
        AppFlushbar.shared.successFlushbar('Profil fotoğrafı silindi');
      } catch (e) {
        AppFlushbar.shared.errorFlushbar(e.toString());
      }
      return;
    }

    final source = action == 'camera' ? ImageSource.camera : ImageSource.gallery;
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 75,
    );

    if (pickedFile == null) return;

    try {
      await ref.read(accountActionsProvider.notifier).updateProfilePhoto(pickedFile.path);
      AppFlushbar.shared.successFlushbar('Profil fotoğrafı güncellendi');
    } catch (e) {
      AppFlushbar.shared.errorFlushbar(e.toString());
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final accountActionState = ref.watch(accountActionsProvider);
    final userProfile = ref.watch(userProfileProvider).valueOrNull;

    return CupertinoPageScaffold(
      navigationBar: isFromHome
          ? SheetHeader(
              closeButtonPosition: CloseButtonPosition.left,
              title: LocaleKeys.auth_my_account.tr(),
            )
          : CupertinoNavigationBar(
              previousPageTitle: context.tr(LocaleKeys.settings_settings),
              middle: Text(LocaleKeys.auth_my_account.tr()),
            ),
      child: SafeArea(
        bottom: false,
        child: authState.when(
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (_, __) => Center(
            child: Text(
              LocaleKeys.common_error.tr(),
              style: context.bodyMedium,
            ),
          ),
          data: (user) {
            if (user == null || user.isAnonymous) {
              return ListView(
                padding: EdgeInsets.zero,
                children: const [
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: AuthHeaderWidget(),
                  ),
                ],
              );
            }

            final photoUrl = userProfile?.photoUrl ?? user.photoURL;

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 16),
                Center(
                  child: CupertinoCard(
                    borderRadius: BorderRadius.circular(100),
                    borderColor: context.primaryContrastingColor,
                    onTap: accountActionState.isLoading ? null : () => _handlePhotoAction(context, ref),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        UserAvatarWidget(
                          photoUrl: photoUrl,
                          radius: 54,
                        ),
                        if (accountActionState.isLoading)
                          const Positioned.fill(
                            child: Center(
                              child: CupertinoActivityIndicator(radius: 14),
                            ),
                          ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: context.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: context.primaryContrastingColor, width: 2),
                            ),
                            child: const Icon(
                              CupertinoIcons.camera_fill,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AccountProfileSection(user: user),
                const SizedBox(height: 24),
                AccountSecuritySection(user: user),
                const SizedBox(height: 24),
                AccountLinkedAccountsSection(user: user),
                const SizedBox(height: 24),
                const AccountPrivacySection(),
                const SizedBox(height: 24),
                AccountDangerZoneSection(user: user),
                const SizedBox(height: 40),
              ],
            );
          },
        ),
      ),
    );
  }
}
