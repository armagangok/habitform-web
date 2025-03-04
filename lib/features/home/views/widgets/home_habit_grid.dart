import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/models/models.dart';
import '../../../../models/completion_entry/completion_entry.dart';
import '../../../reminder/extension/easy_day.dart';
import '../../../reminder/models/days/days_enum.dart';
import '../../provider/home_provider.dart';

class LastDaysModel {
  final Days day;
  final DateTime dateTime;

  LastDaysModel({
    required this.day,
    required this.dateTime,
  });
}

class HomeHabitGrid extends ConsumerStatefulWidget {
  final Habit habit;
  const HomeHabitGrid({
    super.key,
    required this.habit,
  });

  @override
  ConsumerState<HomeHabitGrid> createState() => _HomeHabitGridState();
}

class _HomeHabitGridState extends ConsumerState<HomeHabitGrid> with SingleTickerProviderStateMixin {
  final List<LastDaysModel> _allDays = [];
  late Habit currentHabit;

  // Her gün için bir key map'i oluştur
  final Map<DateTime, GlobalKey> _buttonKeys = {};

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
      _buttonKeys[day] = GlobalKey();
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

  Widget _buildGridItem({
    required double itemSize,
    required DateTime dateTimeInDays,
    required bool isCompletedDate,
    required double spacing,
    required int index,
    required int numberOfItems,
  }) {
    final isToday = dateTimeInDays.year == DateTime.now().year && dateTimeInDays.month == DateTime.now().month && dateTimeInDays.day == DateTime.now().day;
    final habitColor = Color(currentHabit.colorCode);
    final emoji = currentHabit.emoji;

    // Grid item oluşturma kısmında isCompletedDate kontrolünü düzeltelim
    final completions = currentHabit.completions;
    if (completions.isNotEmpty) {
      isCompletedDate = completions.values.any((completion) => completion.date.year == dateTimeInDays.year && completion.date.month == dateTimeInDays.month && completion.date.day == dateTimeInDays.day && completion.isCompleted // Bu kontrolü ekleyelim
          );
    }

    Widget gridItem = Container(
      width: itemSize,
      height: itemSize,
      margin: EdgeInsets.only(
        right: index != numberOfItems - 1 ? spacing : 0,
      ),
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: isCompletedDate ? habitColor : habitColor.withValues(alpha: .175),
        child: Center(
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: animation,
                  child: child,
                ),
              );
            },
            child: isCompletedDate && emoji != null
                ? Text(
                    emoji,
                    key: ValueKey('emoji'),
                    style: TextStyle(
                      fontSize: itemSize * 0.5,
                      height: 1.0,
                    ),
                  )
                : isToday
                    ? Icon(
                        CupertinoIcons.calendar_today,
                        size: 24,
                      )
                    : null,
          ),
        ),
      ),
    );

    return GestureDetector(
      key: _buttonKeys[dateTimeInDays],
      onTap: () async {
        final viewModel = ref.read(homeProvider.notifier);

        // Completion durumunu kontrol ederken isCompleted'ı da kontrol edelim
        final isCompleted = currentHabit.completions.values.any((completion) => completion.date.year == dateTimeInDays.year && completion.date.month == dateTimeInDays.month && completion.date.day == dateTimeInDays.day && completion.isCompleted);

        final normalizedDate = DateTime(dateTimeInDays.year, dateTimeInDays.month, dateTimeInDays.day);
        final dateKey = normalizedDate.toIso8601String().split('T')[0];

        final completion = CompletionEntry(
          id: dateKey,
          date: dateTimeInDays,
          isCompleted: !isCompleted,
        );

        await viewModel.updateHabitCompletionStatus(currentHabit.id, completion);
      },
      child: gridItem,
    );
  }

  @override
  Widget build(BuildContext context) {
    final habitsAsyncValue = ref.watch(homeProvider);

    return habitsAsyncValue.when(
      data: (habits) {
        // Güncel habit'i al
        final updatedHabit = habits.firstWhere(
          (h) => h.id == currentHabit.id,
          orElse: () => currentHabit,
        );

        // Eğer habit güncellendiyse state'i güncelle
        if (updatedHabit != currentHabit) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              currentHabit = updatedHabit;
            });
          });
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final spacing = 8.0;
            final numberOfItems = 7;
            final availableWidth = constraints.maxWidth;
            final itemSize = (availableWidth - (numberOfItems - 1) * spacing) / numberOfItems;
            final maxItemSize = 60.0;
            final finalItemSize = itemSize > maxItemSize ? maxItemSize : itemSize;
            final List<String> dayNames = [
              LocaleKeys.days_monday.tr().substring(0, 3),
              LocaleKeys.days_tuesday.tr().substring(0, 3),
              LocaleKeys.days_wednesday.tr().substring(0, 3),
              LocaleKeys.days_thursday.tr().substring(0, 3),
              LocaleKeys.days_friday.tr().substring(0, 3),
              LocaleKeys.days_saturday.tr().substring(0, 3),
              LocaleKeys.days_sunday.tr().substring(0, 3),
            ];

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                              fontSize: 11.5,
                              color: context.theme.hintColor,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    numberOfItems,
                    (index) {
                      final dateTimeInDays = _allDays[_allDays.length - numberOfItems + index].dateTime;
                      bool isCompletedDate = false;

                      final completions = currentHabit.completions;
                      if (completions.isNotEmpty) {
                        isCompletedDate = completions.values.any((completion) => completion.date.year == dateTimeInDays.year && completion.date.month == dateTimeInDays.month && completion.date.day == dateTimeInDays.day);
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
      loading: () => Center(child: CupertinoActivityIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
    );
  }
}
