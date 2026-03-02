import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';

class LanguageFeature extends ConsumerWidget {
  const LanguageFeature({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoListTile(
      title: Text(LocaleKeys.settings_language.tr()),
      onTap: () {
        showCupertinoModalPopup(
          context: context,
          builder: (context) {
            return CupertinoActionSheet(
              title: Text(LocaleKeys.settings_language.tr()),
              actions: [
                _buildLanguageAction(context, 'en', 'US', "🇬🇧", LocaleKeys.languages_english.tr()),
                _buildLanguageAction(context, 'tr', 'TR', "🇹🇷", LocaleKeys.languages_turkish.tr()),
                _buildLanguageAction(context, 'zh', 'Hans', "🇨🇳", LocaleKeys.languages_chinese.tr()),
                _buildLanguageAction(context, 'es', 'ES', "🇪🇸", LocaleKeys.languages_spanish.tr()),
                _buildLanguageAction(context, 'it', 'IT', "🇮🇹", LocaleKeys.languages_italian.tr()),
                _buildLanguageAction(context, 'ar', 'SA', "🇸🇦", LocaleKeys.languages_arabic.tr()),
                _buildLanguageAction(context, 'fi', 'FI', "🇫🇮", LocaleKeys.languages_finnish.tr()),
                _buildLanguageAction(context, 'ja', 'JP', "🇯🇵", LocaleKeys.languages_japanese.tr()),
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
      leading: CupertinoCard(
        color: CupertinoColors.systemBlue,
        borderRadius: BorderRadius.circular(5),
        padding: const EdgeInsets.all(2),
        child: Icon(
          CupertinoIcons.globe,
          color: Colors.white.withValues(alpha: .9),
        ),
      ),
      trailing: CupertinoListTileChevron(),
    );
  }

  Widget _buildLanguageAction(BuildContext context, String languageCode, String countryCode, String flag, String languageName) {
    return CupertinoActionSheetAction(
      isDefaultAction: context.locale.languageCode == languageCode,
      onPressed: () {
        context.setLocale(Locale(languageCode, countryCode));
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("$flag "),
          Text(languageName),
          Text(" $flag"),
        ],
      ),
    );
  }
}
