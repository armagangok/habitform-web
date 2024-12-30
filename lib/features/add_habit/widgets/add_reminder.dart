import 'dart:math';

import '/core/core.dart';
import '../bloc/cubit/reminder_time_cubit.dart';
import '../enum/days_enum.dart';

enum DaySelection { empty, selected, allSelected }

extension _ButtonName on DaySelection {
  String get getButtontext {
    switch (this) {
      case DaySelection.empty || DaySelection.selected:
        return "Select All";

      case DaySelection.allSelected:
        return "Deselect All";
    }
  }
}

extension DaysExtension on Days {
  String get capitalized {
    // İlk harfi büyük yapmak için:
    final name = this.name; // Enum adını al
    return name[0].toUpperCase() + name.substring(1); // İlk harfi büyüt ve geri kalanı ekle
  }
}

class AddReminderPage extends StatefulWidget {
  const AddReminderPage({super.key});

  @override
  State<AddReminderPage> createState() => _AddReminderPageState();
}

class _AddReminderPageState extends State<AddReminderPage> {
  DaySelection daySelection = DaySelection.empty;

  bool isTimePickerExpaned = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: SheetHeader(
        closeButtonPosition: CloseButtonPosition.left,
        title: "Reminder",
        // onClose: () {
        //   // selectedDays.clear();
        //   // context.read<ReminderTimeCubit>().updateReminderModel(null);
        // },
        trailing: TrailingActionButton(
          title: "Save",
          onPressed: navigator.pop,
        ),
      ),
      child: BlocBuilder<ReminderCubit, ReminderTimeState>(
        builder: (context, state) {
          final allDays = context.read<ReminderCubit>().allDays;
          final selectedDays = context.read<ReminderCubit>().selectedDays;
          return ListView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              SafeArea(
                bottom: false,
                child: SizedBox(height: 20),
              ),
              CupertinoListSection(
                backgroundColor: Colors.transparent,
                header: Text("DAYS"),
                children: [
                  CupertinoListTile(
                    title: Column(
                      children: [
                        GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: allDays.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
                          itemBuilder: (context, index) {
                            final day = allDays[index];
                            final isSelected = selectedDays.contains(day); // Günün seçili olup olmadığını kontrol et.

                            return BlocBuilder<ReminderCubit, ReminderTimeState>(
                              builder: (context, state) {
                                return CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    context.read<ReminderCubit>().updateReminderModel(
                                          state.reminderModel?.copyWith(),
                                        );
                                    setState(
                                      () {
                                        if (isSelected) {
                                          selectedDays.remove(day); // Zaten seçiliyse, kaldır.
                                        } else {
                                          selectedDays.add(day); // Seçili değilse, ekle.
                                        }

                                        if (selectedDays.isEmpty) {
                                          daySelection = DaySelection.empty;
                                        }

                                        if (selectedDays.isNotEmpty) {
                                          daySelection = DaySelection.selected;
                                        }

                                        if (selectedDays.length == 7) {
                                          daySelection = DaySelection.allSelected;
                                        }
                                      },
                                    );
                                  },
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(
                                        color: context.theme.dividerColor.withAlpha(75),
                                        width: .75,
                                      ),
                                    ),
                                    elevation: 0.75, // Seçiliyse daha yüksek bir gölge.
                                    color: isSelected ? CupertinoColors.activeBlue : context.cupertinoTheme.scaffoldBackgroundColor,
                                    child: Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: Center(
                                        child: FittedBox(
                                          child: Text(
                                            day.capitalized,
                                            style: TextStyle(
                                              color: isSelected ? CupertinoColors.white : CupertinoColors.black,
                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                            ),
                                            maxLines: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        daySelection != DaySelection.empty
                            ? Align(
                                alignment: Alignment.centerRight,
                                child: CupertinoButton(
                                  onPressed: () {
                                    setState(
                                      () {
                                        if (daySelection == DaySelection.allSelected) {
                                          selectedDays.clear();

                                          if (selectedDays.isEmpty) {
                                            daySelection = DaySelection.empty;
                                          }

                                          if (selectedDays.isNotEmpty) {
                                            daySelection = DaySelection.selected;
                                          }

                                          if (selectedDays.length == 7) {
                                            daySelection = DaySelection.allSelected;
                                          }
                                          return;
                                        }

                                        if (daySelection == DaySelection.empty || daySelection == DaySelection.selected) {
                                          selectedDays.addAll(Days.values);

                                          if (selectedDays.isEmpty) {
                                            daySelection = DaySelection.empty;
                                          }

                                          if (selectedDays.isNotEmpty) {
                                            daySelection = DaySelection.selected;
                                          }

                                          if (selectedDays.length == 7) {
                                            daySelection = DaySelection.allSelected;
                                          }
                                        }
                                      },
                                    );
                                  },
                                  child: Text(
                                    daySelection.getButtontext,
                                    style: TextStyle(fontWeight: FontWeight.bold, color: context.primary),
                                  ).animate().fadeIn(),
                                ),
                              ).animate().fadeIn()
                            : SizedBox.shrink(),
                      ],
                    ),
                  ),
                ],
              ),
              daySelection != DaySelection.empty
                  ? Column(
                      children: [
                        CupertinoListSection(
                          header: Text("TIME"),
                          backgroundColor: Colors.transparent,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CupertinoListTile(
                                  title: Text("Select Time"),
                                  subtitle: BlocBuilder<ReminderCubit, ReminderTimeState>(
                                    builder: (context, state) {
                                      return Text(
                                        state.reminderModel?.reminderTime ?? "None",
                                        style: TextStyle(
                                          color: CupertinoColors.systemBlue,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      );
                                    },
                                  ),
                                  trailing: Transform.rotate(
                                    angle: isTimePickerExpaned ? pi / 2 : 0,
                                    child: CupertinoListTileChevron().animate().fadeIn(),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      isTimePickerExpaned = !isTimePickerExpaned;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        AnimatedSize(
                          duration: Duration(milliseconds: 300),
                          child: SizedBox(
                            height: isTimePickerExpaned ? 140 : 0,
                            child: BlocBuilder<ReminderCubit, ReminderTimeState>(
                              builder: (context, state) {
                                return CupertinoDatePicker(
                                  mode: CupertinoDatePickerMode.time,
                                  initialDateTime: DateTime.now(),
                                  use24hFormat: true, // Change to false for AM/PM format
                                  onDateTimeChanged: (DateTime remindTime) {
                                    context.read<ReminderCubit>().updateReminderModel(
                                          state.reminderModel?.copyWith(
                                            reminderTime: remindTime.toIso8601String(),
                                          ),
                                        );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    )
                  : SizedBox.shrink(),
            ],
          );
        },
      ),
    );
  }
}

//  showCupertinoModalPopup(
//                                 context: context,
//                                 builder: (BuildContext context) {
//                                   return CupertinoPopupSurface(
//                                     child: ListView(
//                                       padding: EdgeInsets.zero,
//                                       shrinkWrap: true,
//                                       children: [
//                                         SizedBox(
//                                           height: 50,
//                                           child: SheetHeader(
//                                             title: "Pick Time",
//                                             closeButtonPosition: CloseButtonPosition.left,
//                                             trailing: TrailingActionButton(
//                                               title: "Save",
//                                               onPressed: () {},
//                                             ),
//                                           ),
//                                         ),

//                                       ],
//                                     ),
//                                   );
//                                 },
//                               );

// Positioned.fill(
//   child: Align(
//     alignment: Alignment.bottomCenter,
//     child: SafeArea(
//       top: false,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20.0),
//         child: SizedBox(
//           width: double.infinity,
//           child: CupertinoButton.filled(
//             sizeStyle: CupertinoButtonSize.large,
//             onPressed: () {
//               // Seçilen günleri kaydetme işlemini burada yapabilirsiniz.
//               debugPrint(
//                 "Selected days: ${selectedDays.map((e) => e.capitalized).join(', ')}",
//               );
//             },
//             child: const Text(
//               "Save",
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),
//       ),
//     ),
//   ),
// ),
