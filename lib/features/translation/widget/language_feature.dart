import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';

class LanguageFeature extends ConsumerWidget {
  const LanguageFeature({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoListTile(
      title: Text(context.tr(LocaleKeys.settings_language)),
      onTap: () {
        showCupertinoModalPopup(
          context: context,
          builder: (context) {
            return CupertinoActionSheet(
              title: Text(context.tr(LocaleKeys.settings_language)),
              actions: [
                _buildLanguageAction(context, 'en', 'US', "🇬🇧", context.tr(LocaleKeys.languages_english)),
                _buildLanguageAction(context, 'tr', 'TR', "🇹🇷", context.tr(LocaleKeys.languages_turkish)),
                _buildLanguageAction(context, 'zh', 'Hans', "🇨🇳", context.tr(LocaleKeys.languages_chinese)),
                _buildLanguageAction(context, 'es', 'ES', "🇪🇸", context.tr(LocaleKeys.languages_spanish)),
                _buildLanguageAction(context, 'it', 'IT', "🇮🇹", context.tr(LocaleKeys.languages_italian)),
                _buildLanguageAction(context, 'ar', 'SA', "🇸🇦", context.tr(LocaleKeys.languages_arabic)),
                _buildLanguageAction(context, 'fi', 'FI', "🇫🇮", context.tr(LocaleKeys.languages_finnish)),
                _buildLanguageAction(context, 'ja', 'JP', "🇯🇵", context.tr(LocaleKeys.languages_japanese)),
              ],
              cancelButton: CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: navigator.pop,
                child: Text(context.tr(LocaleKeys.common_cancel)),
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
      trailing: const CupertinoListTileChevron(),
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
