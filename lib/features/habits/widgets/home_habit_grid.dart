import 'dart:io';

import '/core/core.dart';
import '/models/models.dart';
import '../../../core/widgets/spring_button.dart';
import '../../reminder/extension/easy_day.dart';
import '../../reminder/models/days/days_enum.dart';
import '../bloc/habit_bloc.dart';

class LastDaysModel {
  final Days day;
  final DateTime dateTime;

  LastDaysModel({
    required this.day,
    required this.dateTime,
  });
}

class HomeHabitGrid extends StatefulWidget {
  final Habit habit;
  const HomeHabitGrid({
    super.key,
    required this.habit,
  });

  @override
  State<HomeHabitGrid> createState() => _HomeHabitGridState();
}

class _HomeHabitGridState extends State<HomeHabitGrid> {
  final List<LastDaysModel> _allDays = [];
  late Habit currentHabit;

  // Her gün için bir key map'i oluştur
  final Map<DateTime, GlobalKey<SpringButtonState>> _buttonKeys = {};

  @override
  void initState() {
    super.initState();
    currentHabit = widget.habit;

    DateTime today = DateTime.now();
    for (int i = 29; i >= 0; i--) {
      DateTime day = today.subtract(Duration(days: i));
      _allDays.add(
        LastDaysModel(
          day: getDayEnum(day.weekday),
          dateTime: day,
        ),
      );
      // Her gün için bir key oluştur
      _buttonKeys[day] = GlobalKey<SpringButtonState>();
    }
  }

  @override
  void didUpdateWidget(HomeHabitGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.habit != widget.habit) {
      setState(() {
        currentHabit = widget.habit;
      });
    }
  }

  void _updateCurrentHabit(Habit updatedHabit) {
    if (currentHabit != updatedHabit) {
      setState(() {
        currentHabit = updatedHabit;
      });
    }
  }

  Widget _buildGridItem({
    required double itemSize,
    required DateTime dateTimeInDays,
    required bool isCompletedDate,
    required double spacing,
    required int index,
    required int numberOfItems,
  }) {
    final isToday = dateTimeInDays.isSameDayWith(DateTime.now());
    final habitColor = Color(currentHabit.colorCode);
    final emoji = currentHabit.emoji;

    Widget gridItem = Container(
      width: itemSize,
      height: itemSize,
      margin: EdgeInsets.only(
        right: index != numberOfItems - 1 ? spacing : 0,
      ),
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: isToday ? habitColor : context.primary.withAlpha(50),
            width: isToday ? 1 : 0,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        color: isCompletedDate ? habitColor : habitColor.withValues(alpha: .125),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (emoji != null)
                  Text(
                    emoji,
                    style: TextStyle(
                      fontSize: itemSize * (Platform.isIOS ? .65 : 0.25),
                      height: 1.0,
                      textBaseline: TextBaseline.ideographic,
                    ),
                    textAlign: TextAlign.center,
                  ).animate(target: isCompletedDate ? 1 : 0).fadeIn(duration: 300.ms).scale(begin: Offset(0.5, 0.5), end: Offset(1, 1), duration: 300.ms),
                Text(
                  dateTimeInDays.day.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isCompletedDate ? habitColor.colorRegardingToBrightness : null,
                  ),
                ).animate(target: isCompletedDate ? 1 : 0).moveY(begin: emoji != null ? -10 : 0, end: 0, duration: 300.ms, curve: Curves.easeOutCubic),
              ],
            ),
          ),
        ),
      ),
    );

    return SpringButton(
      key: _buttonKeys[dateTimeInDays],
      onTap: () {
        final event = UpdateHabitForSelectedDayEvent(
          dateToSaveOrRemove: dateTimeInDays,
          habit: currentHabit,
        );
        context.read<HabitBloc>().add(event);
      },
      child: gridItem,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HabitBloc, HabitState>(
      listenWhen: (previous, current) => current is HabitsFetched,
      listener: (context, state) {
        if (state is HabitsFetched) {
          final updatedHabit = state.habits.firstWhere(
            (h) => h.id == currentHabit.id,
            orElse: () => currentHabit,
          );

          if (updatedHabit != currentHabit) {
            final today = DateTime.now();
            final oldCompletionDates = currentHabit.completionDates ?? [];
            final newCompletionDates = updatedHabit.completionDates ?? [];

            final wasCompletedToday = oldCompletionDates.any((date) => date.isSameDayWith(today));
            final isCompletedToday = newCompletionDates.any((date) => date.isSameDayWith(today));

            if (wasCompletedToday != isCompletedToday) {
              final today = DateTime.now();
              _buttonKeys[today]?.currentState?.triggerAnimation();
            }
          }

          _updateCurrentHabit(updatedHabit);
        }
      },
      buildWhen: (previous, current) {
        return current is HabitsFetched;
      },
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final spacing = 8.0;
            final numberOfItems = 7; // 3'ten 7'ye çıkardık
            final availableWidth = constraints.maxWidth;
            final itemSize = (availableWidth - (numberOfItems - 1) * spacing) / numberOfItems;

            // Maksimum boyutu küçülttük çünkü 7 gün göstereceğiz
            final maxItemSize = 60.0; // 120'den 60'a düşürdük
            final finalItemSize = itemSize > maxItemSize ? maxItemSize : itemSize;

            final List<String> dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Gün isimleri satırı
                SizedBox(
                  width: availableWidth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      numberOfItems,
                      (index) {
                        final dateTime = _allDays[_allDays.length - numberOfItems + index].dateTime;
                        final dayName = dayNames[dateTime.weekday - 1];
                        return SizedBox(
                          width: finalItemSize,
                          child: Text(
                            dayName,
                            style: context.bodySmall?.copyWith(
                              fontSize: 10, // Font boyutunu küçülttük
                              color: context.theme.hintColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Günler satırı
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    numberOfItems,
                    (index) {
                      final dateTimeInDays = _allDays[_allDays.length - numberOfItems + index].dateTime;
                      bool isCompletedDate = false;

                      final completionDates = currentHabit.completionDates;
                      if (completionDates != null && completionDates.isNotEmpty) {
                        isCompletedDate = completionDates.any((d) => d.isSameDayWith(dateTimeInDays));
                      }

                      return _buildGridItem(
                        itemSize: finalItemSize,
                        dateTimeInDays: dateTimeInDays,
                        isCompletedDate: isCompletedDate,
                        spacing: spacing,
                        index: index,
                        numberOfItems: numberOfItems,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
