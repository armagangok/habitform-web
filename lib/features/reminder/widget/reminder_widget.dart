import 'package:habitrise/features/reminder/widget/select_time_item.dart';

import '/core/core.dart';
import '../bloc/picker_extend/picker_extend_cubit.dart';
import '../bloc/remind_time/remind_time_cubit.dart';
import '../bloc/reminder/reminder_bloc.dart';
import '../models/days/days_enum.dart';
import 'days_grid_view.dart';
import 'selection_buttons.dart';

extension DaysExtension on Days {
  String get capitalized {
    // İlk harfi büyük yapmak için:
    final name = this.name; // Enum adını al
    return name[0].toUpperCase() + name.substring(1); // İlk harfi büyüt ve geri kalanı ekle
  }
}

class ReminderPage extends StatelessWidget {
  const ReminderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReminderBloc, ReminderState>(
      builder: (context, state) {
        return CupertinoPageScaffold(
          navigationBar: SheetHeader(
            closeButtonPosition: CloseButtonPosition.left,
            title: "Reminder",
          ),
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              SafeArea(
                bottom: false,
                child: SizedBox(height: 20),
              ),
              Column(
                children: [
                  CupertinoListSection(
                    backgroundColor: Colors.transparent,
                    header: Text("DAYS"),
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
              Column(
                children: [
                  Column(
                    children: [
                      CupertinoListSection(
                        header: Text("TIME"),
                        backgroundColor: Colors.transparent,
                        children: [
                          SelectTimeItem(),
                        ],
                      ),
                      BlocBuilder<PickerExtendCubit, bool>(
                        builder: (context, state) {
                          final isExpanded = state;
                          return AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            height: isExpanded ? 300 : 0,
                            child: CupertinoDatePicker(
                              mode: CupertinoDatePickerMode.time,
                              initialDateTime: DateTime.now().copyWith(hour: 12, minute: 0, second: 0),
                              use24hFormat: true, // Change to false for AM/PM format
                              onDateTimeChanged: (val) {
                                context.read<RemindTimeCubit>().updateTime(val, context);
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
