import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/core/helpers/url_laucher/url_launcher.dart';
import '/core/theme/widget/theme_mode_widget.dart';
import '../auth/widgets/auth_header_widget.dart';
import '../purchase/providers/purchase_provider.dart';
import '../translation/widget/language_feature.dart';
import 'widgets/membership_info_button.dart';
import 'widgets/review_request_section.dart';
import 'widgets/subscribe_button.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paywallState = ref.watch(purchaseProvider);

    return CupertinoPageScaffold(
      navigationBar: SheetHeader(
        title: LocaleKeys.settings_settings.tr(),
        closeButtonPosition: CloseButtonPosition.left,
      ),
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Column(
              children: [
                AuthHeaderWidget(),
                // Wrap paywall section in RepaintBoundary to prevent unnecessary repaints
                paywallState.valueOrNull?.isSubscriptionActive ?? false ? const MembershipInfoButton() : const SubscribeButton(),
                const ReviewRequestSection(),
                CupertinoListSection.insetGrouped(
                  children: [
                    ThemeModeFeature(),
                    LanguageFeature(),
                    CupertinoListTile(
                      leading: CupertinoCard(
                        color: CupertinoColors.systemGreen,
                        borderRadius: BorderRadius.circular(5),
                        padding: const EdgeInsets.all(2),
                        child: Icon(
                          CupertinoIcons.bell_fill,
                          color: Colors.white.withValues(alpha: .9),
                        ),
                      ),
                      title: Text(LocaleKeys.settings_notifications.tr()),
                      onTap: () => navigator.navigateTo(path: KRoute.notifications),
                      trailing: CupertinoListTileChevron(),
                    ),
                  ],
                ),
                CupertinoListSection.insetGrouped(
                  children: [
                    CupertinoListTile(
                      leading: CupertinoCard(
                        color: CupertinoColors.systemIndigo,
                        borderRadius: BorderRadius.circular(5),
                        padding: const EdgeInsets.all(2),
                        child: Icon(
                          CupertinoIcons.archivebox_fill,
                          color: Colors.white.withValues(alpha: .9),
                        ),
                      ),
                      title: Text(LocaleKeys.settings_habitArchive.tr()),
                      onTap: () {
                        navigator.navigateTo(path: KRoute.archivedHabits);
                      },
                      trailing: CupertinoListTileChevron(),
                    ),
                    CupertinoListTile(
                      leading: CupertinoCard(
                        color: Colors.deepPurpleAccent,
                        borderRadius: BorderRadius.circular(5),
                        padding: const EdgeInsets.all(2.5),
                        child: Icon(
                          FontAwesomeIcons.database,
                          color: Colors.white.withValues(alpha: .9),
                        ),
                      ),
                      title: Text(LocaleKeys.settings_data_export_import.tr()),
                      onTap: () {
                        navigator.navigateTo(path: KRoute.dataManagement);
                      },
                      trailing: CupertinoListTileChevron(),
                    ),
                    CupertinoListTile(
                      leading: CupertinoCard(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(5),
                        padding: const EdgeInsets.all(2),
                        child: Icon(
                          CupertinoIcons.doc_person_fill,
                          color: Colors.white.withValues(alpha: .9),
                        ),
                      ),
                      onTap: () => ref.read(purchaseProvider.notifier).copyCustomerId(),
                      title: Text(LocaleKeys.settings_rc_id.tr()),
                      trailing: CupertinoButton(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        child: Icon(
                          CupertinoIcons.doc_on_clipboard_fill,
                          color: Colors.blueAccent,
                        ),
                        onPressed: () => ref.read(purchaseProvider.notifier).copyCustomerId(),
                      ),
                    ),
                  ],
                ),
                CupertinoListSection.insetGrouped(
                  children: [
                    CupertinoListTile(
                      leading: CupertinoCard(
                        color: CupertinoColors.activeBlue,
                        borderRadius: BorderRadius.circular(5),
                        padding: const EdgeInsets.all(2),
                        child: Icon(
                          CupertinoIcons.hand_raised_fill,
                          color: Colors.white.withValues(alpha: .9),
                        ),
                      ),
                      title: Text(LocaleKeys.settings_privacy.tr()),
                      onTap: UrlLauncherHelper.openPrivacyPolicy,
                      trailing: CupertinoListTileChevron(),
                    ),
                    CupertinoListTile(
                      leading: CupertinoCard(
                        color: CupertinoColors.activeBlue,
                        borderRadius: BorderRadius.circular(5),
                        padding: const EdgeInsets.all(2),
                        child: Icon(
                          CupertinoIcons.hand_point_right_fill,
                          color: Colors.white.withValues(alpha: .9),
                        ),
                      ),
                      title: Text(LocaleKeys.settings_terms.tr()),
                      onTap: UrlLauncherHelper.openTermsOfUse,
                      trailing: CupertinoListTileChevron(),
                    ),
                    CupertinoListTile(
                      leading: CupertinoCard(
                        color: CupertinoColors.activeBlue,
                        borderRadius: BorderRadius.circular(5),
                        padding: const EdgeInsets.all(2),
                        child: Icon(
                          CupertinoIcons.mail_solid,
                          color: Colors.white.withValues(alpha: .9),
                        ),
                      ),
                      title: Text(LocaleKeys.settings_feedback.tr()),
                      onTap: UrlLauncherHelper.requestEmail,
                      trailing: CupertinoListTileChevron(),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: LocaleKeys.settings_app_name_habit.tr(),
                                style: context.bodyLarge.copyWith(
                                  color: context.bodyLarge.color?.withValues(alpha: 1),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: LocaleKeys.settings_app_name_rise.tr(),
                                style: context.bodyLarge.copyWith(
                                  color: context.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0) + EdgeInsets.only(bottom: 30.0),
                      child: CustomButton(
                        onPressed: UrlLauncherHelper.openTwitter,
                        child: Text(
                          LocaleKeys.common_made_by.tr(),
                          style: context.bodySmall,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
