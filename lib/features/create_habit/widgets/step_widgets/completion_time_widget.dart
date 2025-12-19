import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/core.dart';
import '../../provider/create_habit_provider.dart';

/// Widget for selecting completion time (separate from reminder)
class CompletionTimeWidget extends ConsumerStatefulWidget {
  final DateTime? initialTime;
  final void Function(DateTime?)? onCompletionTimeChanged;

  const CompletionTimeWidget({
    super.key,
    this.initialTime,
    this.onCompletionTimeChanged,
  });

  @override
  ConsumerState<CompletionTimeWidget> createState() => _CompletionTimeWidgetState();
}

class _CompletionTimeWidgetState extends ConsumerState<CompletionTimeWidget> {
  bool _isExtended = false;
  DateTime? _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime ?? (widget.onCompletionTimeChanged == null ? ref.read(createHabitProvider).completionTime : null);
  }

  @override
  void didUpdateWidget(CompletionTimeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update selected time if initialTime changed (for edit mode)
    if (widget.onCompletionTimeChanged != null && widget.initialTime != oldWidget.initialTime) {
      _selectedTime = widget.initialTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    // If callback is provided, use _selectedTime for display (edit mode)
    // Otherwise, watch createHabitProvider (create mode)
    final completionTime = widget.onCompletionTimeChanged != null
        ? _selectedTime
        : ref.watch(createHabitProvider).completionTime;

    return CupertinoListSection.insetGrouped(
      header: Text('create_habit.reminder.completion_time_title'.tr()),
      footer: Text(
        'create_habit.reminder.completion_time_description'.tr(),
        style: context.bodySmall.copyWith(
          color: Theme.of(context).hintColor,
        ),
      ),
      children: [
        Column(
          children: [
            CustomButton(
              onPressed: () {
                setState(() {
                  _isExtended = !_isExtended;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'create_habit.reminder.completion_time_select'.tr(),
                      style: context.titleMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          completionTime?.toHHMM() ?? LocaleKeys.common_none.tr(),
                          style: context.titleMedium.copyWith(
                            fontWeight: FontWeight.w500,
                            color: completionTime != null ? context.primary : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          _isExtended ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: context.titleMedium.color,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            AnimatedContainer(
              duration: 350.ms,
              curve: Curves.easeOutCubic,
              height: _isExtended ? 200 : 0,
              child: ClipRect(
                child: OverflowBox(
                  maxHeight: 200,
                  child: AnimatedOpacity(
                    duration: 350.ms,
                    opacity: _isExtended ? 1 : 0,
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.time,
                      initialDateTime: completionTime ?? DateTime.now().copyWith(hour: 12, minute: 0),
                      use24hFormat: true,
                      onDateTimeChanged: (DateTime value) {
                        if (widget.onCompletionTimeChanged != null) {
                          setState(() {
                            _selectedTime = value;
                          });
                          widget.onCompletionTimeChanged!(value);
                        } else {
                          ref.read(createHabitProvider.notifier).updateCompletionTime(value);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
            // Clear button if time is set
            if (completionTime != null)
              CustomButton(
                onPressed: () {
                  if (widget.onCompletionTimeChanged != null) {
                    setState(() {
                      _selectedTime = null;
                      _isExtended = false;
                    });
                    widget.onCompletionTimeChanged!(null);
                  } else {
                    ref.read(createHabitProvider.notifier).updateCompletionTime(null);
                    setState(() {
                      _isExtended = false;
                    });
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        LocaleKeys.common_delete.tr(),
                        style: context.titleMedium.copyWith(
                          color: CupertinoColors.destructiveRed,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
