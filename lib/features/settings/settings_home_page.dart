import 'package:habitrise/core/helpers/spacing_helper.dart';
import 'package:habitrise/features/language/widget/language_feature.dart';
import 'package:permission_handler/permission_handler.dart';

import '/core/core.dart';
import '/core/helpers/url_laucher/url_launcher.dart';
import '/core/theme/widget/theme_mode_widget.dart';
import 'widgets/setting_item.dart';
import 'widgets/subscribe_button.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: Duration(milliseconds: 250));

    super.initState();
  }

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
                  SubscribeButton(),
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
                            backgroundColor: Colors.transparent,
                            leading: const SettingLeadingWidget(
                              iconData: CupertinoIcons.heart_fill,
                              cardColor: Colors.pinkAccent,
                            ),
                            title: Text(LocaleKeys.settings_support.tr()),
                            subtitle: Text(LocaleKeys.settings_support_subtitle.tr()),
                            onTap: () {},
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
                          onTap: () {},
                          trailing: CupertinoListTileChevron(),
                        ),
                        CupertinoListTile(
                          leading: const SettingLeadingWidget(
                            iconData: CupertinoIcons.hand_point_right_fill,
                            cardColor: CupertinoColors.activeBlue,
                          ),
                          title: Text(LocaleKeys.settings_terms.tr()),
                          onTap: () {},
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
                              color: context.textTheme.bodySmall?.color?.withOpacity(.75),
                            ),
                          )
                        ],
                      ),
                      CustomButton(
                        onTap: UrlLauncherHelper.openTwitter,
                        child: Text(
                          LocaleKeys.common_made_by.tr(),
                          style: context.bodySmall,
                        ),
                      )
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

class CustomDivider extends StatelessWidget {
  final Color color;
  final double thickness;
  final double indent;
  final double endIndent;

  const CustomDivider({
    super.key,
    this.color = CupertinoColors.separator,
    this.thickness = .5,
    this.indent = 28.0,
    this.endIndent = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: indent,
        end: endIndent,
      ),
      child: Container(
        height: thickness,
        color: color,
      ),
    );
  }
}
