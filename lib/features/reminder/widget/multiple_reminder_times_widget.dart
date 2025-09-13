import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '../models/multiple_reminder/multiple_reminder_model.dart';
import '../provider/reminder_provider.dart';

class _TimePickerModal extends StatefulWidget {
  final Function(DateTime) onTimeSelected;
  final DateTime? initialTime;

  const _TimePickerModal({
    required this.onTimeSelected,
    this.initialTime,
  });

  @override
  State<_TimePickerModal> createState() => _TimePickerModalState();
}

class _TimePickerModalState extends State<_TimePickerModal> {
  late DateTime selectedTime;

  @override
  void initState() {
    super.initState();
    selectedTime = widget.initialTime ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      color: context.scaffoldBackgroundColor,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: context.scaffoldBackgroundColor,
              border: Border(
                bottom: BorderSide(
                  color: context.selectionHandleColor.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    LocaleKeys.common_cancel.tr(),
                    style: context.bodyMedium.copyWith(
                      color: context.primary,
                    ),
                  ),
                ),
                Text(
                  widget.initialTime != null ? 'Edit time' : 'Choose a time',
                  style: context.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    widget.onTimeSelected(selectedTime);
                    Navigator.pop(context);
                  },
                  child: Text(
                    LocaleKeys.common_done.tr(),
                    style: context.bodyMedium.copyWith(
                      color: context.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.time,
              initialDateTime: selectedTime,
              onDateTimeChanged: (DateTime newTime) {
                setState(() {
                  selectedTime = newTime;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MultipleReminderTimesWidget extends ConsumerStatefulWidget {
  const MultipleReminderTimesWidget({super.key});

  @override
  ConsumerState<MultipleReminderTimesWidget> createState() => _MultipleReminderTimesWidgetState();
}

class _MultipleReminderTimesWidgetState extends ConsumerState<MultipleReminderTimesWidget> {
  @override
  Widget build(BuildContext context) {
    final reminderState = ref.watch(reminderProvider);
    final multipleReminders = reminderState.reminder?.multipleReminders;

    if (multipleReminders == null || multipleReminders.reminderTimes.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reminder times',
            style: context.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: context.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.selectionHandleColor.withOpacity(0.2),
                style: BorderStyle.solid,
              ),
            ),
            child: CupertinoListSection.insetGrouped(
              children: [
                Column(
                  children: [
                    Icon(
                      CupertinoIcons.clock,
                      size: 32,
                      color: context.selectionHandleColor.withOpacity(0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No reminder times set',
                      style: context.bodyMedium.copyWith(
                        color: context.selectionHandleColor.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap "Add another time" below to get started',
                      style: context.bodySmall.copyWith(
                        color: context.selectionHandleColor.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _addReminderTime,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: context.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.primary.withOpacity(0.3),
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.add_circled,
                    size: 20,
                    color: context.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Add another time',
                    style: context.bodyMedium.copyWith(
                      color: context.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return CupertinoListSection.insetGrouped(
      header: Text('Reminder times'),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...multipleReminders.sortedReminderTimes.asMap().entries.map((entry) {
                final index = entry.key;
                final time = entry.value;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => _editReminderTime(index, time),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: context.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: context.selectionHandleColor.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.clock,
                            size: 20,
                            color: context.primary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            time.toHHMM(),
                            style: context.bodyLarge.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            CupertinoIcons.pencil,
                            size: 16,
                            color: context.selectionHandleColor.withOpacity(0.6),
                          ),
                          const SizedBox(width: 8),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () => _removeReminderTime(index),
                            minimumSize: Size(0, 0),
                            child: Icon(
                              CupertinoIcons.minus_circle_fill,
                              size: 20,
                              color: CupertinoColors.systemRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _addReminderTime,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: context.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: context.primary.withOpacity(0.3),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.add_circled,
                        size: 20,
                        color: context.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Add another time',
                        style: context.bodyMedium.copyWith(
                          color: context.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _addReminderTime() async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => _TimePickerModal(
        onTimeSelected: (time) {
          _addTimeToList(time);
        },
      ),
    );
  }

  void _editReminderTime(int index, DateTime currentTime) async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => _TimePickerModal(
        initialTime: currentTime,
        onTimeSelected: (time) {
          _updateTimeInList(index, time);
        },
      ),
    );
  }

  void _addTimeToList(DateTime time) {
    final currentReminder = ref.read(reminderProvider).reminder;
    if (currentReminder == null) return;

    final currentMultipleReminders = currentReminder.multipleReminders;
    final newTimes = List<DateTime>.from(currentMultipleReminders?.reminderTimes ?? []);
    newTimes.add(time);

    final updatedMultipleReminders = MultipleReminderModel(
      id: currentMultipleReminders?.id ?? UuidHelper.uidInt,
      reminderTimes: newTimes,
      days: currentReminder.days,
    );

    ref.read(reminderProvider.notifier).updateMultipleReminders(updatedMultipleReminders);
  }

  void _updateTimeInList(int index, DateTime time) {
    final currentReminder = ref.read(reminderProvider).reminder;
    if (currentReminder?.multipleReminders == null) return;

    final currentTimes = List<DateTime>.from(currentReminder!.multipleReminders!.reminderTimes);
    if (index >= 0 && index < currentTimes.length) {
      currentTimes[index] = time;

      final updatedMultipleReminders = MultipleReminderModel(
        id: currentReminder.multipleReminders!.id,
        reminderTimes: currentTimes,
        days: currentReminder.days,
      );

      ref.read(reminderProvider.notifier).updateMultipleReminders(updatedMultipleReminders);
    }
  }

  void _removeReminderTime(int index) {
    final currentReminder = ref.read(reminderProvider).reminder;
    if (currentReminder?.multipleReminders == null) return;

    final currentTimes = List<DateTime>.from(currentReminder!.multipleReminders!.reminderTimes);
    if (index >= 0 && index < currentTimes.length) {
      currentTimes.removeAt(index);

      if (currentTimes.isEmpty) {
        // If no times left, clear multiple reminders
        ref.read(reminderProvider.notifier).clearMultipleReminders();
      } else {
        final updatedMultipleReminders = MultipleReminderModel(
          id: currentReminder.multipleReminders!.id,
          reminderTimes: currentTimes,
          days: currentReminder.days,
        );
        ref.read(reminderProvider.notifier).updateMultipleReminders(updatedMultipleReminders);
      }
    }
  }
}
