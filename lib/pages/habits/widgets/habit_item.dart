import 'package:flutter/cupertino.dart';

class HabitItem extends StatefulWidget {
  const HabitItem({
    super.key,
    required this.habitName,
    required this.value,
    this.subtitle,
    this.groupValue,
    this.onChanged,
  });

  final String habitName;
  final String? subtitle;
  final bool value;
  final bool? groupValue;
  final void Function(bool?)? onChanged;

  @override
  State<HabitItem> createState() => _HabitItemState();
}

class _HabitItemState extends State<HabitItem> {
  @override
  Widget build(BuildContext context) {
    return CupertinoListTile(
      title: Text(widget.habitName),
      subtitle: widget.subtitle != null ? Text(widget.subtitle!) : null,
      trailing: CupertinoRadio<bool>(
        value: widget.value,
        groupValue: widget.groupValue,
        onChanged: widget.onChanged,
      ),
    );
  }
}
