import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/core/helpers/url_laucher/url_launcher.dart';
import '/core/theme/widget/theme_mode_widget.dart';
import '../purchase/providers/purchase_provider.dart';
import 'widgets/setting_item.dart';
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
                paywallState.when(
                  data: (state) => state.isSubscriptionActive ? const SubscribeButton() : const SubscribeButton(),
                  error: (error, stack) => SizedBox.shrink(),
                  loading: () => CupertinoListSection.insetGrouped(
                    children: [
                      CupertinoListTile(
                        title: CupertinoActivityIndicator(),
                      )
                    ],
                  ),
                ),
                CupertinoListSection.insetGrouped(
                  children: [
                    ThemeModeFeature(),
                    CupertinoListTile(
                      leading: SettingLeadingWidget(
                        iconData: CupertinoIcons.bell_fill,
                        cardColor: CupertinoColors.systemGreen,
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
                      leading: const SettingLeadingWidget(
                        iconData: CupertinoIcons.archivebox_fill,
                        cardColor: CupertinoColors.systemIndigo,
                      ),
                      title: Text(LocaleKeys.settings_habitArchive.tr()),
                      onTap: () {
                        navigator.navigateTo(path: KRoute.archivedHabits);
                      },
                      trailing: CupertinoListTileChevron(),
                    ),
                    CupertinoListTile(
                      leading: SettingLeadingWidget(
                        padding: 2.5,
                        iconData: FontAwesomeIcons.database,
                        cardColor: Colors.deepPurpleAccent,
                      ),
                      title: Text(LocaleKeys.settings_data_export_import.tr()),
                      onTap: () {
                        navigator.navigateTo(path: KRoute.dataManagement);
                      },
                      trailing: CupertinoListTileChevron(),
                    ),
                    CupertinoListTile(
                      leading: const SettingLeadingWidget(
                        iconData: CupertinoIcons.doc_person_fill,
                        cardColor: Colors.blueAccent,
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
                      leading: const SettingLeadingWidget(
                        iconData: CupertinoIcons.hand_raised_fill,
                        cardColor: CupertinoColors.activeBlue,
                      ),
                      title: Text(LocaleKeys.settings_privacy.tr()),
                      onTap: UrlLauncherHelper.openPrivacyPolicy,
                      trailing: CupertinoListTileChevron(),
                    ),
                    CupertinoListTile(
                      leading: const SettingLeadingWidget(
                        iconData: CupertinoIcons.hand_point_right_fill,
                        cardColor: CupertinoColors.activeBlue,
                      ),
                      title: Text(LocaleKeys.settings_terms.tr()),
                      onTap: UrlLauncherHelper.openTermsOfUse,
                      trailing: CupertinoListTileChevron(),
                    ),
                    CupertinoListTile(
                      leading: const SettingLeadingWidget(
                        iconData: CupertinoIcons.mail_solid,
                        cardColor: CupertinoColors.activeBlue,
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
                                  color: Colors.deepOrange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
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
