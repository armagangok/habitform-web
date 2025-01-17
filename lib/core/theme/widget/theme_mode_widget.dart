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
          title: Text("Theme"),
          onTap: () {
            showCupertinoModalPopup(
              context: context,
              builder: (context) {
                return CupertinoActionSheet(
                  title: Text("Change Appearance"),
                  actions: [
                    CupertinoActionSheetAction(
                      isDefaultAction: themeMode == ThemeMode.system,
                      onPressed: () {
                        context.read<ThemeBloc>().add(SetSystemThemeEvent());
                      },
                      child: Text("System"),
                    ),
                    CupertinoActionSheetAction(
                      isDefaultAction: themeMode == ThemeMode.light,
                      onPressed: () {
                        context.read<ThemeBloc>().add(SetLightThemeEvent());
                      },
                      child: Text("Light"),
                    ),
                    CupertinoActionSheetAction(
                      isDefaultAction: themeMode == ThemeMode.dark,
                      onPressed: () {
                        context.read<ThemeBloc>().add(SetDarkThemeEvent());
                      },
                      child: Text("Dark"),
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
