import 'package:flutter/cupertino.dart';

class HabitTypeSegmentedControl extends StatelessWidget {
  final String selectedSegment;
  final ValueChanged<String> onSegmentChanged;

  const HabitTypeSegmentedControl({
    super.key,
    required this.selectedSegment,
    required this.onSegmentChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: CupertinoSlidingSegmentedControl<String>(
        children: {
          'BasicHabits': Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Basic Habits'),
          ),
          'ChainedHabits': Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Chained Habits'),
          ),
          'HabitsToBreak': Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Break Habits'),
          ),
        },
        onValueChanged: (value) {
          onSegmentChanged(value!);
        },
        groupValue: selectedSegment,
      ),
    );
  }
}
