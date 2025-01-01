import '/core/core.dart';
import '/models/models.dart';
import '../../habits/bloc/single_habit/single_habit_bloc.dart';

class SingleHabitGrid extends StatefulWidget {
  final Habit habit;

  const SingleHabitGrid({super.key, required this.habit});

  @override
  State<SingleHabitGrid> createState() => _SingleHabitGridState();
}

class _SingleHabitGridState extends State<SingleHabitGrid> {
  late final DateTime today;
  late final List<DateTime> days;

  @override
  void initState() {
    // Bugünü al
    today = DateTime.now();

// Bugün dahil, bugünden önceki 90 günü ve sonraki 7 günü kapsayan tarihleri oluştur
    days = List.generate(35, (index) {
      // 90 gün geriye giderek başlayın, bugüne ve 7 güne kadar ekleyin
      return today.subtract(Duration(days: 90)).add(Duration(days: index));
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7, // Haftalık grid için 7 sütun
        crossAxisSpacing: 2.5,
        mainAxisSpacing: 2.5,
      ),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];

        final result = convertStringListToDateTimeList(widget.habit.completionDates);

        // Tarih tamamlanmış mı kontrol et
        final isCompleted = result?.any((date) => date.year == day.year && date.month == day.month && date.day == day.day) ?? false;

        return CustomButton(
          onTap: () {
            // Şu anki tarihi ISO 8601 formatında al
            final currentDate = days[index];

            // Güncelleme olayını tetikle
            context.read<SingleHabitBloc>().add(
                  UpdateHabitForSelectedDayEvent(
                    habit: widget.habit,
                    selectedDate: currentDate,
                    days: days,
                  ),
                );
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green : context.primary.withValues(alpha: .2), // Tamamlanmış tarihler yeşil
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
