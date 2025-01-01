import 'package:habitrise/core/core.dart';
import 'package:habitrise/features/habits/bloc/single_habit/single_habit_bloc.dart';
import 'package:habitrise/models/models.dart';

class SingleHabitGrid extends StatelessWidget {
  final Habit habit;

  const SingleHabitGrid({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    // Takvim tarihlerini belirleyelim (örneğin, 1 ay için):
    final today = DateTime.now();
    final startOfMonth = DateTime(today.year, today.month, 1);
    final daysInMonth = DateTime(today.year, today.month + 1, 0).day;

    // Ayın günlerini liste olarak oluştur
    final monthDays = List.generate(daysInMonth, (index) {
      return startOfMonth.add(Duration(days: index));
    });

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 14, // Haftalık grid için 7 sütun
        crossAxisSpacing: 2.5,
        mainAxisSpacing: 2.5,
      ),
      itemCount: monthDays.length,
      itemBuilder: (context, index) {
        final day = monthDays[index];

        final result = convertStringListToDateTimeList(habit.completionDates);

        // Tarih tamamlanmış mı kontrol et
        final isCompleted = result?.any((date) => date.year == day.year && date.month == day.month && date.day == day.day) ?? false;

        return CustomButton(
          onTap: () {
            // Şu anki tarihi ISO 8601 formatında al
            final currentDate = monthDays[index];

            // Güncelleme olayını tetikle
            context.read<SingleHabitBloc>().add(
                  UpdateHabitForSelectedDayEvent(
                    habit: habit,
                    selectedDate: currentDate,
                    datesSelected: monthDays,
                  ),
                );
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green : context.primary.withOpacity(.25), // Tamamlanmış tarihler yeşil
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      },
    );
  }
}

List<DateTime>? convertStringListToDateTimeList(List<String>? stringList) {
  if (stringList == null) return null;

  return stringList.map((str) => DateTime.parse(str)).toList();
}
