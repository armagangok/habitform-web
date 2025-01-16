// ignore_for_file: public_member_api_docs, sort_constructors_first
import '/core/core.dart';
import '../../../../models/models.dart';
import '../../bloc/habit_bloc.dart';

class SingleHabitDetailGrid extends StatefulWidget {
  final Habit habit;
  const SingleHabitDetailGrid({
    super.key,
    required this.habit,
  });

  @override
  State<SingleHabitDetailGrid> createState() => _SingleHabitDetailGridState();
}

class _SingleHabitDetailGridState extends State<SingleHabitDetailGrid> {
  final List<DateTime> last90Days = [];

  @override
  void initState() {
    super.initState();
    // Son 90 günü oluştur
    DateTime today = DateTime.now();
    for (int i = 150; i >= 0; i--) {
      last90Days.add(today.subtract(Duration(days: i)));
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToEnd();
      setState(() {});
    });
  }

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tamamlanmış tarihleri sırala
    final completionDates = widget.habit.completionDates?..sort();

    DateTime? startDate;
    DateTime? endDate;

    // Eğer en az iki tamamlanmış tarih varsa başlangıç ve bitiş tarihlerini belirle
    if (completionDates != null && completionDates.length > 1) {
      startDate = completionDates.first;
      endDate = completionDates.last;
    }

    return SizedBox(
      height: 200,
      child: GridView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: last90Days.length,
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7, // Haftalık kolon sayısı
          crossAxisSpacing: 6,
          mainAxisSpacing: 11, // Satırlar arası boşluk
          childAspectRatio: 1, // Widget oranı
        ),
        itemBuilder: (context, index) {
          final dateTimeIn90Days = last90Days[index];
          final isToday = dateTimeIn90Days.isToday;

          bool isCompletedDate = completionDates?.any((d) => d.isSameDayWith(dateTimeIn90Days)) ?? false;

          // İki tarih arasındaki öğe mi?
          bool isBetweenDates = false;
          if (startDate != null && endDate != null) {
            isBetweenDates = dateTimeIn90Days.isAfter(startDate) && dateTimeIn90Days.isBefore(endDate);
          }

          final habitColor = widget.habit.colorCode;

          return CustomButton(
            onTap: () {
              final event = UpdateHabitForSelectedDayEvent(
                dateToSaveOrRemove: dateTimeIn90Days,
                habit: widget.habit,
              );

              context.read<HabitBloc>().add(event);
            },
            child: Card(
              elevation: 0.1,
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.white.withAlpha(50),
              color: isCompletedDate
                  ? Color(habitColor)
                  : isBetweenDates
                      ? Color(habitColor).withOpacity(.1) // İki tarih arası
                      : context.theme.cardColor, // Diğer öğeler
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: BorderSide(
                  color: isToday ? context.primary : context.theme.dividerColor.withAlpha(50),
                  width: isToday ? 2.5 : .5,
                ),
              ),
              child: SizedBox(
                height: 24,
                width: 24,
              ),
            ),
          );
        },
      ),
    );
  }
}
