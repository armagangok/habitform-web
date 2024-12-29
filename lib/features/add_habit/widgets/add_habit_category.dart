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
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: CupertinoSlidingSegmentedControl<String>(
        children: {
          'BasicHabits': Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Single Habit'),
          ),
          'ChainedHabits': Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Chained Habit'),
          ),
        },
        onValueChanged: (value) {
          debugPrint(value);
          onSegmentChanged(value!);
        },
        groupValue: selectedSegment,
      ),
    );
  }
}
