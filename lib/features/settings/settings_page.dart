import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/core/helpers/url_laucher/url_launcher.dart';
import '/core/theme/widget/theme_mode_widget.dart';
import '../purchase/providers/purchase_provider.dart';
import '../purchase/widgets/membership_info_widget.dart';
import 'widgets/setting_item.dart';
import 'widgets/subscribe_button.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paywallState = ref.watch(purchaseProvider);

    return paywallState.when(
      data: (state) => CupertinoPageScaffold(
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
                    if (state.isSubscriptionActive)
                      Card(
                        child: CupertinoListTile(
                          leading: Assets.app.habitriseDarkTransparent.image(height: 24, width: 24),
                          title: Text(LocaleKeys.subscription_myMembership.tr()),
                          onTap: () {
                            showCupertinoModalBottomSheet(
                              context: context,
                              builder: (_) => MembershipInfoWidget(
                                onCopyCustomerId: () => ref.read(purchaseProvider.notifier).copyCustomerId(),
                              ),
                            );
                          },
                          trailing: CupertinoListTileChevron(),
                        ),
                      )
                    else
                      const SubscribeButton(),
                    SafeArea(
                      child: CustomHeader(
                        child: Card(
                          child: Column(
                            children: [
                              ThemeModeFeature(),
                              // LanguageFeature(),
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
                        ),
                      ),
                    ),
                    CustomHeader(
                      child: Card(
                        child: Column(
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
                              leading: const SettingLeadingWidget(
                                iconData: CupertinoIcons.doc_person_fill,
                                cardColor: Colors.deepOrangeAccent,
                              ),
                              onTap: () => ref.read(purchaseProvider.notifier).copyCustomerId(),
                              title: Text("Rc ID"),
                              trailing: CupertinoButton(
                                padding: EdgeInsets.zero,
                                minSize: 0,
                                child: Icon(
                                  CupertinoIcons.doc_on_clipboard_fill,
                                  color: Colors.deepOrangeAccent,
                                ),
                                onPressed: () => ref.read(purchaseProvider.notifier).copyCustomerId(),
                              ),
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
                                      color: context.bodyLarge?.color?.withValues(alpha: 1),
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
                                color: context.textTheme.bodyLarge?.color?.withValues(alpha: .75),
                              ),
                            )
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
              ),
            ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
