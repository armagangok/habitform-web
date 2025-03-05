// import '/core/core.dart';
// import '../../settings/widgets/setting_item.dart';

// class LanguageFeature extends StatelessWidget {
//   const LanguageFeature({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return CupertinoListTile(
//       title: Text(LocaleKeys.settings_language.tr()),
//       onTap: () {
//         showCupertinoModalPopup(
//           context: context,
//           builder: (context) {
//             return CupertinoActionSheet(
//               title: Text(LocaleKeys.settings_language.tr()),
//               actions: [
//                 _buildLanguageAction(context, 'en', 'US', "🇬🇧", LocaleKeys.languages_english.tr()),
//                 _buildLanguageAction(context, 'tr', 'TR', "🇹🇷", LocaleKeys.languages_turkish.tr()),
//                 _buildLanguageAction(context, 'zh', 'CN', "🇨🇳", LocaleKeys.languages_chinese.tr()),
//                 _buildLanguageAction(context, 'es', 'ES', "🇪🇸", LocaleKeys.languages_spanish.tr()),
//                 _buildLanguageAction(context, 'hi', 'IN', "🇮🇳", LocaleKeys.languages_hindi.tr()),
//                 _buildLanguageAction(context, 'ar', 'SA', "🇸🇦", LocaleKeys.languages_arabic.tr()),
//                 _buildLanguageAction(context, 'bn', 'BD', "🇧🇩", LocaleKeys.languages_bengali.tr()),
//                 _buildLanguageAction(context, 'pt', 'BR', "🇧🇷", LocaleKeys.languages_portuguese.tr()),
//                 _buildLanguageAction(context, 'ru', 'RU', "🇷🇺", LocaleKeys.languages_russian.tr()),
//                 _buildLanguageAction(context, 'ja', 'JP', "🇯🇵", LocaleKeys.languages_japanese.tr()),
//                 _buildLanguageAction(context, 'id', 'ID', "🇮🇩", LocaleKeys.languages_indonesian.tr()),
//               ],
//               cancelButton: CupertinoActionSheetAction(
//                 isDestructiveAction: true,
//                 onPressed: navigator.pop,
//                 child: Text(LocaleKeys.common_ok.tr()),
//               ),
//             );
//           },
//         );
//       },
//       leading: const SettingLeadingWidget(
//         iconData: CupertinoIcons.globe,
//         cardColor: CupertinoColors.systemBlue,
//       ),
//       trailing: CupertinoListTileChevron(),
//     );
//   }

//   Widget _buildLanguageAction(BuildContext context, String languageCode, String countryCode, String flag, String languageName) {
//     return CupertinoActionSheetAction(
//       isDefaultAction: context.locale.languageCode == languageCode,
//       onPressed: () {
//         context.setLocale(Locale(languageCode, countryCode));
//       },
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text("$flag "),
//           Text(languageName),
//           Text(" $flag"),
//         ],
//       ),
//     );
//   }
// }
