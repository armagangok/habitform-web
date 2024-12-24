import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/extension/datetime_extension.dart';
import '../../../core/extension/easy_context.dart';
import '../../../models/chained_habit_model.dart';
import '../../../models/habit_model.dart';

class ChainedHabitItem extends StatefulWidget {
  const ChainedHabitItem({
    super.key,
    required this.chainedHabit,
  });

  final ChainedHabit chainedHabit;

  @override
  State<ChainedHabitItem> createState() => _ChainedHabitItemState();
}

class _ChainedHabitItemState extends State<ChainedHabitItem> {
  @override
  Widget build(BuildContext context) {
    final isFirstCompleted = widget.chainedHabit.firstHabit?.isCompleted ?? true;
    final isMainAndFirstCompleted = widget.chainedHabit.mainHabit.isCompleted && isFirstCompleted;
    return Card(
      elevation: 0,
      child: IntrinsicHeight(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 8.0),
              child: Text(
                widget.chainedHabit.chainName,
                style: context.cupertinoTextTheme.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            _buildFirstHabit(
              widget.chainedHabit.firstHabit,
            ),
            _buildMainHabit(
              widget.chainedHabit.mainHabit,
              widget.chainedHabit.secondHabit?.isCompleted,
              isFirstCompleted: isFirstCompleted,
            ),
            _buildSecondHabit(
              widget.chainedHabit.secondHabit,
              isMainCompleted: isMainAndFirstCompleted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _verticalDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 40.0),
      child: SizedBox(
        height: 24,
        child: VerticalDivider(
          color: context.cupertinoTextTheme.color?.withAlpha(100),
          width: 0,
          thickness: 1,
        ),
      ),
    );
  }

  Widget _buildFirstHabit(Habit? firstHabit) {
    if (firstHabit == null) return SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Opacity(
          opacity: firstHabit.isCompleted ? 1 : .65,
          child: CupertinoListTile(
            leadingSize: 40,
            leading: firstHabit.icon != null
                ? Text(
                    firstHabit.icon ?? "",
                    style: context.cupertinoTextTheme.copyWith(fontSize: 30),
                  )
                : null,
            title: Text(
              firstHabit.habitName,
              style: TextStyle(
                decoration: firstHabit.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Text(
              firstHabit.completeTime.toHHMM(),
              style: TextStyle(
                decoration: firstHabit.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            trailing: CupertinoCheckbox(
              value: firstHabit.isCompleted,
              onChanged: (val) {
                setState(() {
                  if (val == false && widget.chainedHabit.mainHabit.isCompleted) {
                    // Eğer ikinci alışkanlık işaretliyse birinci iptal edilemez
                    _showWarningDialog("You need to uncheck the second habit first.");
                  } else if (val != null) {
                    firstHabit.isCompleted = val;
                    HapticFeedback.heavyImpact();
                  }
                });
              },
            ),
          ),
        ),
        Opacity(
          opacity: firstHabit.isCompleted ? 1 : .65,
          child: _verticalDivider(),
        ),
      ],
    );
  }

  Widget _buildMainHabit(
    Habit mainHabit,
    bool? isSecondVisible, {
    required bool isFirstCompleted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Opacity(
          opacity: mainHabit.isCompleted ? 1 : .65,
          child: CupertinoListTile(
            leadingSize: 40,
            leading: mainHabit.icon != null
                ? Text(
                    mainHabit.icon ?? "",
                    style: context.cupertinoTextTheme.copyWith(fontSize: 30),
                  )
                : null,
            title: Text(
              mainHabit.habitName,
              style: TextStyle(
                decoration: mainHabit.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Text(
              mainHabit.completeTime.toHHMM(),
              style: TextStyle(
                decoration: mainHabit.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            trailing: CupertinoCheckbox(
              value: mainHabit.isCompleted,
              onChanged: (val) {
                setState(() {
                  if (val == false && widget.chainedHabit.secondHabit?.isCompleted == true) {
                    // Eğer üçüncü alışkanlık işaretliyse ikinci iptal edilemez
                    _showWarningDialog("You need to uncheck the third habit first.");
                  } else if (val == true && !isFirstCompleted) {
                    // Eğer birinci alışkanlık tamamlanmamışsa ikinci işaretlenemez
                    _showWarningDialog("You need to complete the first habit to proceed.");
                  } else if (val != null) {
                    mainHabit.isCompleted = val;
                    HapticFeedback.heavyImpact();
                  }
                });
              },
            ),
          ),
        ),
        if (isSecondVisible != null)
          Opacity(
            opacity: mainHabit.isCompleted ? 1 : .65,
            child: _verticalDivider(),
          ),
      ],
    );
  }

  Widget _buildSecondHabit(
    Habit? secondHabit, {
    required bool isMainCompleted,
  }) {
    if (secondHabit == null) return SizedBox.shrink();
    return Opacity(
      opacity: secondHabit.isCompleted ? 1 : .65,
      child: CupertinoListTile(
        leadingSize: 40,
        leading: secondHabit.icon != null
            ? Text(
                secondHabit.icon ?? "",
                style: context.cupertinoTextTheme.copyWith(fontSize: 30),
              )
            : null,
        title: Text(
          secondHabit.habitName,
          style: TextStyle(
            decoration: secondHabit.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          secondHabit.completeTime.toHHMM(),
          style: TextStyle(
            decoration: secondHabit.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        trailing: CupertinoCheckbox(
          value: secondHabit.isCompleted,
          onChanged: (val) {
            setState(() {
              if (val == true && !isMainCompleted) {
                // Eğer birinci ve ikinci alışkanlık tamamlanmamışsa üçüncü işaretlenemez
                _showWarningDialog("You need to complete the first and second habits to proceed.");
              } else if (val != null) {
                secondHabit.isCompleted = val;
                HapticFeedback.heavyImpact();
              }
            });
          },
        ),
      ),
    );
  }

  Future<dynamic> _showWarningDialog(String message) {
    return context.cupertinoDialog(
      widget: CupertinoAlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            SizedBox(height: 10),
            Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  12,
                ),
                side: BorderSide(
                  color: context.colors.inverseSurface.withAlpha(50),
                ),
              ),
              elevation: 0,
              child: SizedBox(
                height: 120,
                width: 120,
                child: Image.asset(
                  "assets/illustrations/dots.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text("Okay"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
