import '/core/core.dart';
import '/models/chained_habit/chained_habit_model.dart';

class ChainedHabitGrid extends StatefulWidget {
  final ChainedHabit chainedHabit;

  const ChainedHabitGrid({super.key, required this.chainedHabit});

  @override
  State<ChainedHabitGrid> createState() => _ChainedHabitGridState();
}

class _ChainedHabitGridState extends State<ChainedHabitGrid> {
  late final List<DateTime> monthDays;

  @override
  void initState() {
    // Takvim tarihlerini belirleyelim (örneğin, 1 ay için):
    final today = DateTime.now();
    final startOfMonth = DateTime(today.year, today.month, 1);
    final daysInMonth = DateTime(today.year, today.month + 1, 0).day;

    // Ayın günlerini liste olarak oluştur
    monthDays = List.generate(daysInMonth, (index) {
      return startOfMonth.add(Duration(days: index));
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
        crossAxisCount: 1, // Haftalık grid için 7 sütun
        crossAxisSpacing: 2.5,
        mainAxisSpacing: 2.5,
      ),
      itemCount: monthDays.length,
      itemBuilder: (context, index) {
        final day = monthDays[index];

        // Tarih tamamlanmış mı kontrol et
        final isCompleted = widget.chainedHabit.completionDates.any((date) => date.year == day.year && date.month == day.month && date.day == day.day);

        return Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isCompleted ? Colors.green : Colors.grey[400], // Tamamlanmış tarihler yeşil
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
    );
  }
}
