import '/core/core.dart';
import '../../../features/settings/widgets/setting_item.dart';
import '../bloc/theme_bloc.dart';

class ThemeModeFeature extends StatelessWidget {
  const ThemeModeFeature({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final themeMode = state.themeMode;
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
                return CupertinoActionSheet(
                  title: Text(LocaleKeys.settings_theme.tr()),
                  actions: [
                    CupertinoActionSheetAction(
                      isDefaultAction: themeMode == ThemeMode.system,
                      onPressed: () {
                        context.read<ThemeBloc>().add(SetSystemThemeEvent());
                      },
                      child: Text(LocaleKeys.settings_system.tr()),
                    ),
                    CupertinoActionSheetAction(
                      isDefaultAction: themeMode == ThemeMode.light,
                      onPressed: () {
                        context.read<ThemeBloc>().add(SetLightThemeEvent());
                      },
                      child: Text(LocaleKeys.settings_light_mode.tr()),
                    ),
                    CupertinoActionSheetAction(
                      isDefaultAction: themeMode == ThemeMode.dark,
                      onPressed: () {
                        context.read<ThemeBloc>().add(SetDarkThemeEvent());
                      },
                      child: Text(LocaleKeys.settings_dark_mode.tr()),
                    ),
                  ],
                  cancelButton: CupertinoActionSheetAction(
                    isDestructiveAction: true,
                    onPressed: navigator.pop,
                    child: Text("Cancel"),
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
