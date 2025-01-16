import 'package:habitrise/core/core.dart';
import 'package:habitrise/features/reminder/bloc/picker_extend/picker_extend_cubit.dart';
import 'package:habitrise/features/reminder/bloc/reminder/reminder_bloc.dart';

import '../../models/days/days_enum.dart';
import '../remind_time/remind_time_cubit.dart';

enum DaySelection { empty, selected, allSelected }

class DaySelectionCubit extends Cubit<DaySelection> {
  DaySelectionCubit() : super(DaySelection.empty);

  final allDays = Days.values;

  List<Days> selectedDays = [];

  void initializeDaySelection(List<Days> initialSelectedDays) {
    selectedDays = initialSelectedDays;

    if (selectedDays.isEmpty) {
      emit(DaySelection.empty);
    } else if (selectedDays.length == 7) {
      emit(DaySelection.allSelected);
    } else {
      emit(DaySelection.selected);
    }
  }

  setSelection(DaySelection selection) => emit(selection);

  void setSelectionByChecking() {
    if (state == DaySelection.allSelected) {
      selectedDays.clear();

      if (selectedDays.isEmpty) {
        setSelection(DaySelection.empty);
      }

      if (selectedDays.isNotEmpty) {
        setSelection(DaySelection.selected);
      }

      if (selectedDays.length == 7) {
        setSelection(DaySelection.allSelected);
      }
      return;
    }

    if (state == DaySelection.empty || state == DaySelection.selected) {
      selectedDays.addAll(Days.values);

      if (selectedDays.isEmpty) {
        setSelection(DaySelection.empty);
      }

      if (selectedDays.isNotEmpty) {
        setSelection(DaySelection.selected);
      }

      if (selectedDays.length == 7) {
        setSelection(DaySelection.allSelected);
      }
    }
  }

  void selectAll(BuildContext context) {
    selectedDays.clear();
    selectedDays.addAll(Days.values);

    emit(DaySelection.allSelected);

    context.read<ReminderBloc>().add(UpdateReminderDaysEvent(days: selectedDays));
  }

  void deselectAll(BuildContext context) {
    selectedDays.clear();

    emit(DaySelection.empty);

    context.read<ReminderBloc>().add(UpdateReminderDaysEvent(days: null));
    context.read<ReminderBloc>().add(UpdateReminderTimeEvent(time: null));
    context.read<RemindTimeCubit>().updateTime(null, context);
    context.read<PickerExtendCubit>().setValue(false);
  }

  void selectOneByOne(Days day, bool isSelected, BuildContext context) {
    if (isSelected) {
      selectedDays.remove(day);
    } else {
      selectedDays.add(day);
    }

    if (selectedDays.isEmpty) {
      emit(DaySelection.empty);
    }

    if (selectedDays.isNotEmpty) {
      emit(DaySelection.selected);
    }

    if (selectedDays.length == 7) {
      emit(DaySelection.allSelected);
    }

    context.read<ReminderBloc>().add(UpdateReminderDaysEvent(days: selectedDays));
  }
}
