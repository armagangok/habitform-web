import 'package:habitrise/core/core.dart';
import 'package:habitrise/features/settings/settings_home/widgets/setting_item.dart';

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
        title: "Settings",
        closeButtonPosition: CloseButtonPosition.left,
      ),
      child: ListView(
        padding: EdgeInsets.all(15),
        children: [
          SafeArea(
            bottom: false,
            child: Card(
              child: CupertinoListSection(
                header: Text("SECTION"),
                topMargin: 8,
                footer: null,
                margin: EdgeInsets.zero,
                additionalDividerMargin: 0,
                backgroundColor: context.theme.cardColor,
                children: [
                  CupertinoListTile(
                    backgroundColor: Colors.transparent,
                    title: Text("Settings"),
                    onTap: () {},
                    trailing: CupertinoListTileChevron(),
                  ),
                  CupertinoListTile(
                    title: Text("Settings"),
                    onTap: () {},
                    trailing: CupertinoListTileChevron(),
                  ),
                  CupertinoListTile(
                    title: Text("Settings"),
                    onTap: () {},
                    trailing: CupertinoListTileChevron(),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 30),
          Card(
            child: CupertinoListSection(
              topMargin: 0,
              footer: null,
              margin: EdgeInsets.zero,
              additionalDividerMargin: 0,
              backgroundColor: context.theme.cardColor,
              children: [
                CupertinoListTile(
                  backgroundColor: Colors.transparent,
                  leading: const SettingLeadingWidget(
                    iconData: CupertinoIcons.hand_raised_fill,
                    cardColor: CupertinoColors.activeBlue,
                  ),
                  title: Text("Privacy"),
                  onTap: () {},
                  trailing: CupertinoListTileChevron(),
                ),
                CupertinoListTile(
                  leading: const SettingLeadingWidget(
                    iconData: CupertinoIcons.hand_point_right_fill,
                    cardColor: CupertinoColors.activeBlue,
                  ),
                  title: Text("Terms"),
                  onTap: () {},
                  trailing: CupertinoListTileChevron(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
