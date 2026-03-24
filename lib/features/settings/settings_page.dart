import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/core/helpers/url_laucher/url_launcher.dart';
import '/core/theme/widget/theme_mode_widget.dart';
import '../../core/widgets/custom_list_tile.dart';
import '../auth/widgets/auth_header_widget.dart';
import '../purchase/providers/purchase_provider.dart';
import '../translation/widget/language_feature.dart';
import 'widgets/membership_info_button.dart';
import 'widgets/pro_features_section.dart';
import 'widgets/review_request_section.dart';
import 'widgets/subscribe_button.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                const AuthHeaderWidget(),

                Consumer(
                  builder: (context, ref, child) {
                    final paywallState = ref.watch(purchaseProvider);
                    return paywallState.valueOrNull?.isSubscriptionActive ?? false ? const MembershipInfoButton() : const SubscribeButton();
                  },
                ),

                const ReviewRequestSection(),

                // Pro Features Section
                const ProFeaturesSection(),

                // Theme Mode and Language Section
                const CustomSection(
                  child: Column(
                    children: [
                      ThemeModeFeature(),
                      LanguageFeature(),
                    ],
                  ),
                ),

                // Privacy and Terms Section

                CustomSection(
                  child: Column(
                    children: [
                      CustomListTile(
                        leading: CupertinoCard(
                          color: CupertinoColors.activeBlue,
                          borderRadius: BorderRadius.circular(5),
                          padding: const EdgeInsets.all(2),
                          child: Icon(
                            CupertinoIcons.hand_raised_fill,
                            color: Colors.white.withValues(alpha: .9),
                          ),
                        ),
                        title: context.tr(LocaleKeys.settings_privacy),
                        onTap: UrlLauncherHelper.openPrivacyPolicy,
                        trailing: const CupertinoListTileChevron(),
                      ),
                      CustomListTile(
                        leading: CupertinoCard(
                          color: CupertinoColors.activeBlue,
                          borderRadius: BorderRadius.circular(5),
                          padding: const EdgeInsets.all(2),
                          child: Icon(
                            CupertinoIcons.hand_point_right_fill,
                            color: Colors.white.withValues(alpha: .9),
                          ),
                        ),
                        title: context.tr(LocaleKeys.settings_terms),
                        onTap: UrlLauncherHelper.openTermsOfUse,
                        trailing: const CupertinoListTileChevron(),
                      ),
                      CustomListTile(
                        leading: CupertinoCard(
                          color: CupertinoColors.activeBlue,
                          borderRadius: BorderRadius.circular(5),
                          padding: const EdgeInsets.all(2),
                          child: Icon(
                            CupertinoIcons.mail_solid,
                            color: Colors.white.withValues(alpha: .9),
                          ),
                        ),
                        title: context.tr(LocaleKeys.settings_feedback),
                        onTap: UrlLauncherHelper.requestEmail,
                        trailing: const CupertinoListTileChevron(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
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
                                text: context.tr(LocaleKeys.settings_app_name_habit),
                                style: context.bodyLarge.copyWith(
                                  color: context.bodyLarge.color?.withValues(alpha: 1),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: context.tr(LocaleKeys.settings_app_name_rise),
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
                      padding: const EdgeInsets.only(top: 5.0) + const EdgeInsets.only(bottom: 30.0),
                      child: CustomButton(
                        onPressed: UrlLauncherHelper.openTwitter,
                        child: Text(
                          context.tr(LocaleKeys.common_made_by),
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
