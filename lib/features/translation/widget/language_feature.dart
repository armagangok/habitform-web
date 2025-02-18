import '/core/core.dart';
import '../../settings/widgets/setting_item.dart';

class LanguageFeature extends StatelessWidget {
  const LanguageFeature({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoListTile(
      title: Text(LocaleKeys.settings_language.tr()),
      onTap: () {
        showCupertinoModalPopup(
          context: context,
          builder: (context) {
            return CupertinoActionSheet(
              title: Text(LocaleKeys.settings_language.tr()),
              actions: [
                CupertinoActionSheetAction(
                  isDefaultAction: context.locale.languageCode == "en",
                  onPressed: () {
                    context.setLocale(const Locale('en', 'US'));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("🇬🇧 "),
                      Text(LocaleKeys.languages_english.tr()),
                      Text(" 🇬🇧"),
                    ],
                  ),
                ),
                CupertinoActionSheetAction(
                  isDefaultAction: context.locale.languageCode == "tr",
                  onPressed: () {
                    context.setLocale(const Locale('tr', 'TR'));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("🇹🇷 "),
                      Text(LocaleKeys.languages_turkish.tr()),
                      Text(" 🇹🇷"),
                    ],
                  ),
                ),
              ],
              cancelButton: CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: navigator.pop,
                child: Text(LocaleKeys.common_ok.tr()),
              ),
            );
          },
        );
      },
      leading: const SettingLeadingWidget(
        iconData: CupertinoIcons.globe,
        cardColor: CupertinoColors.systemBlue,
      ),
      trailing: CupertinoListTileChevron(),
    );
  }
}
