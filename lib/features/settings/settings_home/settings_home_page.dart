import 'package:flutter/cupertino.dart';

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
      child: CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            largeTitle: Text('Settings'),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  // HabitTypeSegmentedControl(
                  //   selectedSegment: _selectedSegment,
                  //   onSegmentChanged: (value) {
                  //     setState(() => _selectedSegment = value);
                  //     controller.forward(from: 0);
                  //   },
                  // ),
                  // SizedBox(height: 10),
                  // if (_selectedSegment == 'BasicHabits') _buildBasicHabits().animate(controller: controller),
                  // if (_selectedSegment == 'ChainedHabits') _buildChainedHabits().animate(controller: controller),
                  // if (_selectedSegment == 'HabitsToBreak') _buildBasicHabits().animate(controller: controller),
                ],
              ),
            ]),
          )
        ],
      ),
    );
  }
}
