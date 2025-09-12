import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '../../../features/settings/widgets/setting_item.dart';
import '../providers/theme_provider.dart';

class ThemeModeFeature extends ConsumerWidget {
  const ThemeModeFeature({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoListTile(
      leading: const SettingLeadingWidget(
        iconData: CupertinoIcons.paintbrush_fill,
        cardColor: Colors.deepOrange,
      ),
      trailing: CupertinoListTileChevron(),
      title: Text(LocaleKeys.settings_theme.tr()),
      onTap: () {
        showCupertinoModalPopup(
          context: context,
          builder: (context) {
            return Consumer(
              builder: (context, ref, child) {
                final currentThemeMode = ref.watch(themeProvider);
                return CupertinoActionSheet(
                  title: Text(LocaleKeys.settings_theme.tr()),
                  actions: [
                    CupertinoActionSheetAction(
                      isDefaultAction: currentThemeMode == ThemeMode.system,
                      onPressed: () {
                        ref.read(themeProvider.notifier).setSystemTheme();
                        navigator.pop();
                      },
                      child: Text(LocaleKeys.settings_system.tr()),
                    ),
                    CupertinoActionSheetAction(
                      isDefaultAction: currentThemeMode == ThemeMode.light,
                      onPressed: () {
                        ref.read(themeProvider.notifier).setLightTheme();
                        navigator.pop();
                      },
                      child: Text(LocaleKeys.settings_light_mode.tr()),
                    ),
                    CupertinoActionSheetAction(
                      isDefaultAction: currentThemeMode == ThemeMode.dark,
                      onPressed: () {
                        ref.read(themeProvider.notifier).setDarkTheme();
                        navigator.pop();
                      },
                      child: Text(LocaleKeys.settings_dark_mode.tr()),
                    ),
                  ],
                  cancelButton: CupertinoActionSheetAction(
                    isDestructiveAction: true,
                    onPressed: navigator.pop,
                    child: Text(LocaleKeys.common_cancel.tr()),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
