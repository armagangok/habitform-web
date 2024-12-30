import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/core/extension/easy_context.dart';
import '/models/chained_habit_model.dart';
import '/models/habit_model.dart';

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
    final isFirstCompleted = widget.chainedHabit.firstHabit?.isCompletedToday ?? true;
    final isMainAndFirstCompleted = widget.chainedHabit.mainHabit.isCompletedToday && isFirstCompleted;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Text(
            widget.chainedHabit.chainName,
            style: context.cupertinoTextTheme.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Card(
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: context.theme.dividerColor.withAlpha(40),
            ),
          ),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFirstHabit(
                  widget.chainedHabit.firstHabit,
                ),
                _buildMainHabit(
                  widget.chainedHabit.mainHabit,
                  widget.chainedHabit.secondHabit?.isCompletedToday,
                  isFirstCompleted: isFirstCompleted,
                ),
                _buildSecondHabit(
                  widget.chainedHabit.secondHabit,
                  isMainCompleted: isMainAndFirstCompleted,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 30.0),
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
          opacity: firstHabit.isCompletedToday ? 1 : .65,
          child: CupertinoListTile(
            leadingSize: 38,
            leadingToTitle: 10,
            leading: firstHabit.icon != null
                ? Text(
                    firstHabit.icon ?? "",
                    style: context.cupertinoTextTheme.copyWith(fontSize: 30),
                  )
                : null,
            title: Text(
              firstHabit.habitName,
              style: TextStyle(
                decoration: firstHabit.isCompletedToday ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Text(
              firstHabit.completeTime ?? "None",
              style: TextStyle(
                decoration: firstHabit.isCompletedToday ? TextDecoration.lineThrough : null,
              ),
            ),
            trailing: Transform.scale(
              scale: 1.5,
              child: CupertinoCheckbox(
                value: firstHabit.isCompletedToday,
                onChanged: (val) {
                  setState(() {
                    if (val == false && widget.chainedHabit.mainHabit.isCompletedToday) {
                      // Eğer ikinci alışkanlık işaretliyse birinci iptal edilemez
                      _showWarningDialog("You need to uncheck the second habit first.");
                    } else if (val != null) {
                      firstHabit.isCompletedToday = val;
                      HapticFeedback.heavyImpact();
                    }
                  });
                },
              ),
            ),
          ),
        ),
        Opacity(
          opacity: firstHabit.isCompletedToday ? 1 : .65,
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
          opacity: mainHabit.isCompletedToday ? 1 : .65,
          child: CupertinoListTile(
            leadingSize: 38,
            leadingToTitle: 10,
            leading: mainHabit.icon != null
                ? Text(
                    mainHabit.icon ?? "",
                    style: context.cupertinoTextTheme.copyWith(fontSize: 30),
                  )
                : null,
            title: Text(
              mainHabit.habitName,
              style: TextStyle(
                decoration: mainHabit.isCompletedToday ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Text(
              mainHabit.completeTime ?? "None",
              style: TextStyle(
                decoration: mainHabit.isCompletedToday ? TextDecoration.lineThrough : null,
              ),
            ),
            trailing: Transform.scale(
              scale: 1.5,
              child: CupertinoCheckbox(
                value: mainHabit.isCompletedToday,
                onChanged: (val) {
                  setState(() {
                    if (val == false && widget.chainedHabit.secondHabit?.isCompletedToday == true) {
                      // Eğer üçüncü alışkanlık işaretliyse ikinci iptal edilemez
                      _showWarningDialog("You need to uncheck the third habit first.");
                    } else if (val == true && !isFirstCompleted) {
                      // Eğer birinci alışkanlık tamamlanmamışsa ikinci işaretlenemez
                      _showWarningDialog("You need to complete the first habit to proceed.");
                    } else if (val != null) {
                      mainHabit.isCompletedToday = val;
                      HapticFeedback.heavyImpact();
                    }
                  });
                },
              ),
            ),
          ),
        ),
        if (isSecondVisible != null)
          Opacity(
            opacity: mainHabit.isCompletedToday ? 1 : .65,
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
      opacity: secondHabit.isCompletedToday ? 1 : .65,
      child: CupertinoListTile(
        leadingSize: 38,
        leadingToTitle: 10,
        leading: secondHabit.icon != null
            ? Text(
                secondHabit.icon ?? "",
                style: context.cupertinoTextTheme.copyWith(fontSize: 30),
              )
            : null,
        title: Text(
          secondHabit.habitName,
          style: TextStyle(
            decoration: secondHabit.isCompletedToday ? TextDecoration.lineThrough : null,
          ),
          maxLines: 2,
        ),
        subtitle: Text(
          secondHabit.completeTime ?? "None",
          style: TextStyle(
            decoration: secondHabit.isCompletedToday ? TextDecoration.lineThrough : null,
          ),
        ),
        trailing: Transform.scale(
          scale: 1.5,
          child: CupertinoCheckbox(
            value: secondHabit.isCompletedToday,
            onChanged: (val) {
              setState(() {
                if (val == true && !isMainCompleted) {
                  // Eğer birinci ve ikinci alışkanlık tamamlanmamışsa üçüncü işaretlenemez
                  _showWarningDialog("You need to complete the first and second habits to proceed.");
                } else if (val != null) {
                  secondHabit.isCompletedToday = val;
                  HapticFeedback.heavyImpact();
                }
              });
            },
          ),
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
