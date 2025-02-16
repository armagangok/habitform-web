import 'package:permission_handler/permission_handler.dart';

import '/core/core.dart';
import '/core/helpers/url_laucher/url_launcher.dart';
import '/core/theme/widget/theme_mode_widget.dart';
import '../../core/helpers/spacing_helper.dart';
import '../../core/widgets/flushbar_widget.dart';
import '../paywall/bloc/paywall_bloc.dart';
import '../paywall/in_app_purchase/copy_helper.dart';
import '../paywall/widgets/membership_info_widget.dart';
import '../translation/widget/language_feature.dart';
import 'widgets/setting_item.dart';
import 'widgets/subscribe_button.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: SheetHeader(
        title: LocaleKeys.settings_settings.tr(),
        closeButtonPosition: CloseButtonPosition.left,
      ),
      child: ListView(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                spacing: KSpacing.betweenListItems,
                children: [
                  SizedBox(height: 10),
                  BlocBuilder<PaywallBloc, PaywallState>(
                    builder: (context, state) {
                      if (state is PaywallResult) {
                        final isSubscriptionActive = state.isSubscriptionActive;
                        return isSubscriptionActive
                            ? Card(
                                child: CupertinoListTile(
                                  leading: Assets.app.habitriseDarkTransparent.image(height: 24, width: 24),
                                  title: Text(LocaleKeys.subscription_myMembership.tr()),
                                  onTap: () {
                                    showCupertinoModalBottomSheet(
                                        context: context,
                                        builder: (_) {
                                          return MembershipInfoWidget();
                                        });
                                  },
                                  trailing: CupertinoListTileChevron(),
                                ),
                              )
                            : SubscribeButton();
                      }

                      return SizedBox.shrink();
                    },
                  ),
                  SafeArea(
                    child: CustomHeader(
                      text: LocaleKeys.common_app.tr(),
                      child: Card(
                        child: Column(
                          children: [
                            ThemeModeFeature(),
                            LanguageFeature(),
                            CupertinoListTile(
                              leading: SettingLeadingWidget(
                                iconData: CupertinoIcons.bell_fill,
                                cardColor: CupertinoColors.systemGreen,
                              ),
                              title: Text(LocaleKeys.settings_notifications.tr()),
                              onTap: openAppSettings,
                              trailing: CupertinoListTileChevron(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  CustomHeader(
                    text: LocaleKeys.common_general.tr(),
                    child: Card(
                      child: Column(
                        children: [
                          CupertinoListTile(
                            leading: const SettingLeadingWidget(
                              iconData: CupertinoIcons.mail_solid,
                              cardColor: CupertinoColors.activeBlue,
                            ),
                            title: Text(LocaleKeys.settings_feedback.tr()),
                            onTap: UrlLauncherHelper.requestEmail,
                            trailing: CupertinoListTileChevron(),
                          ),
                          CupertinoListTile(
                            leading: const SettingLeadingWidget(
                              iconData: CupertinoIcons.doc_person_fill,
                              cardColor: Colors.deepOrangeAccent,
                            ),
                            onTap: () => CopyHelper.shared.copyRCId(context),
                            title: Text("Rc ID"),
                            trailing: CupertinoButton(
                              padding: EdgeInsets.zero,
                              minSize: 0,
                              child: Icon(
                                CupertinoIcons.doc_on_clipboard_fill,
                                color: Colors.deepOrangeAccent,
                              ),
                              onPressed: () => CopyHelper.shared.copyRCId(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    child: Column(
                      children: [
                        CupertinoListTile(
                          backgroundColor: Colors.transparent,
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
                      ],
                    ),
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
                                  text: 'Habit',
                                  style: context.bodyLarge?.copyWith(
                                    color: context.bodyLarge?.color?.withOpacity(1),
                                  ),
                                ),
                                TextSpan(
                                  text: 'Rise',
                                  style: context.bodyLarge?.copyWith(color: context.primary),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            " ${LocaleKeys.common_version.tr()}",
                            style: context.bodyMedium?.copyWith(
                              color: context.textTheme.bodyLarge?.color?.withOpacity(.75),
                            ),
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: CustomButton(
                          onTap: UrlLauncherHelper.openTwitter,
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
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> copyRCId(BuildContext context) async {
  final paywallBloc = context.read<PaywallBloc>();
  final success = await paywallBloc.copyCustomerId();

  if (success) {
    AppFlushbar.shared.successFlushbar("Your customer ID copied successfully\nID:${paywallBloc.customerId}");
  }
}
