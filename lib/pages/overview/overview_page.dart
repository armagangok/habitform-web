import 'package:flutter/cupertino.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> with SingleTickerProviderStateMixin {
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
            largeTitle: Text('Overview'),
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
