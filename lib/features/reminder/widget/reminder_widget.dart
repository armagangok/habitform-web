import 'package:habitrise/features/reminder/widget/select_time_item.dart';

import '/core/core.dart';
import '../bloc/picker_extend/picker_extend_cubit.dart';
import '../bloc/remind_time/remind_time_cubit.dart';
import '../bloc/reminder/reminder_bloc.dart';
import '../provider/reminder_provider.dart';
import 'days_grid_view.dart';
import 'selection_buttons.dart';

class ReminderPage extends StatelessWidget {
  const ReminderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final reminderBloc = context.read<ReminderBloc>();
    return BlocProvider.value(
      value: reminderBloc,
      child: ReminderProvider(
        child: _ReminderPageContent(),
      ),
    );
  }
}

class _ReminderPageContent extends StatefulWidget {
  @override
  State<_ReminderPageContent> createState() => _ReminderPageContentState();
}

class _ReminderPageContentState extends State<_ReminderPageContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reminderState = context.read<ReminderBloc>().state;
      if (reminderState.reminder?.reminderTime != null) {
        context.read<RemindTimeCubit>().initializeTime(reminderState.reminder!.reminderTime);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReminderBloc, ReminderState>(
      builder: (context, state) {
        final reminder = state.reminder;
        return CupertinoPageScaffold(
          navigationBar: SheetHeader(
            closeButtonPosition: CloseButtonPosition.left,
            title: LocaleKeys.habit_reminder.tr(),
          ),
          child: ListView(
            children: [
              SafeArea(
                bottom: false,
                child: Column(
                  spacing: 20,
                  children: [
                    Column(
                      children: [
                        CupertinoListSection(
                          backgroundColor: Colors.transparent,
                          header: Text(LocaleKeys.common_days.tr()),
                          children: [
                            CupertinoListTile(
                              padding: EdgeInsets.all(10),
                              title: DaysGridViewBuilder(),
                            ),
                          ],
                        ),
                        SelectionButtons(),
                      ],
                    ),
                    BlocBuilder<PickerExtendCubit, bool>(
                      builder: (context, state) {
                        final isExpanded = state;
                        return AnimatedContainer(
                          duration: 300.ms,
                          child: Column(
                            children: [
                              CupertinoListSection(
                                header: Text(LocaleKeys.reminder_time.tr().toUpperCase()),
                                backgroundColor: Colors.transparent,
                                children: [
                                  SelectTimeItem(),
                                ],
                              ),
                              AnimatedContainer(
                                duration: 300.ms,
                                height: isExpanded ? 300 : 0,
                                child: CupertinoDatePicker(
                                  mode: CupertinoDatePickerMode.time,
                                  initialDateTime: reminder?.reminderTime ?? DateTime.now().copyWith(hour: 12, minute: 0, second: 0),
                                  use24hFormat: true,
                                  onDateTimeChanged: (val) {
                                    context.read<RemindTimeCubit>().updateTime(val);
                                    context.read<ReminderBloc>().add(UpdateReminderTimeEvent(time: val));
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
