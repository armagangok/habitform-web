/// State model for statistics
class StatisticsState {
  // Overall Progress Stats
  final int totalCompletedDays;
  final double completionRate;
  final int activeDaysCount;
  final int longestStreak;

  // Progress Charts Data - Genel ilerleme verileri (tüm alışkanlıklar)
  final Map<String, double> weeklyProgress;
  final Map<String, double> monthlyProgress;

  // Habit-specific Statistics
  final Map<String, HabitStatistic> habitStatistics;

  // Analysis and Insights
  final String mostProductiveDay;
  final String mostSkippedDay;
  final double averageHabitDuration;

  // Time-based Comparisons
  final MonthlyComparison monthlyComparison;

  // Habit-specific Progress Charts Data - Alışkanlık bazlı ilerleme verileri
  final Map<String, Map<String, double>> habitWeeklyProgressMap;
  final Map<String, Map<String, double>> habitMonthlyProgressMap;

  const StatisticsState({
    required this.totalCompletedDays,
    required this.completionRate,
    required this.activeDaysCount,
    required this.longestStreak,
    required this.weeklyProgress,
    required this.monthlyProgress,
    required this.habitStatistics,
    required this.mostProductiveDay,
    required this.mostSkippedDay,
    required this.averageHabitDuration,
    required this.monthlyComparison,
    this.habitWeeklyProgressMap = const {},
    this.habitMonthlyProgressMap = const {},
  });

  // Factory constructor for initial state with default values
  factory StatisticsState.initial() => StatisticsState(
        totalCompletedDays: 0,
        completionRate: 0,
        activeDaysCount: 0,
        longestStreak: 0,
        weeklyProgress: {},
        monthlyProgress: {},
        habitStatistics: {},
        mostProductiveDay: '',
        mostSkippedDay: '',
        averageHabitDuration: 0,
        monthlyComparison: MonthlyComparison(
          thisMonthRate: 0,
          lastMonthRate: 0,
          difference: 0,
          isImprovement: false,
        ),
        habitWeeklyProgressMap: {},
        habitMonthlyProgressMap: {},
      );

  // CopyWith method for immutability
  StatisticsState copyWith({
    int? totalCompletedDays,
    double? completionRate,
    int? activeDaysCount,
    int? longestStreak,
    Map<String, double>? weeklyProgress,
    Map<String, double>? monthlyProgress,
    Map<String, HabitStatistic>? habitStatistics,
    String? mostProductiveDay,
    String? mostSkippedDay,
    double? averageHabitDuration,
    MonthlyComparison? monthlyComparison,
    Map<String, Map<String, double>>? habitWeeklyProgressMap,
    Map<String, Map<String, double>>? habitMonthlyProgressMap,
  }) {
    return StatisticsState(
      totalCompletedDays: totalCompletedDays ?? this.totalCompletedDays,
      completionRate: completionRate ?? this.completionRate,
      activeDaysCount: activeDaysCount ?? this.activeDaysCount,
      longestStreak: longestStreak ?? this.longestStreak,
      weeklyProgress: weeklyProgress ?? this.weeklyProgress,
      monthlyProgress: monthlyProgress ?? this.monthlyProgress,
      habitStatistics: habitStatistics ?? this.habitStatistics,
      mostProductiveDay: mostProductiveDay ?? this.mostProductiveDay,
      mostSkippedDay: mostSkippedDay ?? this.mostSkippedDay,
      averageHabitDuration: averageHabitDuration ?? this.averageHabitDuration,
      monthlyComparison: monthlyComparison ?? this.monthlyComparison,
      habitWeeklyProgressMap: habitWeeklyProgressMap ?? this.habitWeeklyProgressMap,
      habitMonthlyProgressMap: habitMonthlyProgressMap ?? this.habitMonthlyProgressMap,
    );
  }

  /// Belirli bir alışkanlığa göre istatistikleri filtreler
  /// [habitId] filtrelenecek alışkanlığın ID'si
  StatisticsState filterByHabit(String habitId) {
    // Belirtilen ID için alışkanlık istatistiği mevcut değilse, tüm istatistikleri döndür
    if (!habitStatistics.containsKey(habitId)) {
      return this;
    }

    final habitStat = habitStatistics[habitId]!;

    // Alışkanlığa özel haftalık ve aylık ilerleme verilerini al
    final habitWeekly = habitWeeklyProgressMap[habitId] ?? {};
    final habitMonthly = habitMonthlyProgressMap[habitId] ?? {};

    // Sadece belirli alışkanlık için istatistikleri içeren yeni bir state oluştur
    return StatisticsState(
      // Seçili alışkanlığın tamamlanma bilgileri
      totalCompletedDays: habitStat.completedDays,
      completionRate: habitStat.progressPercentage,

      // Diğer genel metrikler değişmez
      activeDaysCount: activeDaysCount,
      longestStreak: longestStreak,

      // Alışkanlığa özel haftalık ve aylık ilerleme verilerini kullan
      // Not: Burada habitWeeklyProgressMap ve habitMonthlyProgressMap'ten alınan verileri kullanıyoruz
      weeklyProgress: habitWeekly,
      monthlyProgress: habitMonthly,

      // Sadece seçili alışkanlığın istatistiğini içerecek şekilde habitStatistics'i güncelle
      habitStatistics: {habitId: habitStat},

      // Diğer bilgiler aynı kalır
      mostProductiveDay: mostProductiveDay,
      mostSkippedDay: mostSkippedDay,
      averageHabitDuration: averageHabitDuration,
      monthlyComparison: monthlyComparison,

      // Alışkanlığa özel ilerleme haritalarını da güncelle
      // Not: Burada sadece seçilen alışkanlığın verilerini tutuyoruz
      habitWeeklyProgressMap: {habitId: habitWeekly},
      habitMonthlyProgressMap: {habitId: habitMonthly},
    );
  }
}

/// Statistics for a specific habit
class HabitStatistic {
  final String habitId;
  final String habitName;
  final int totalDays;
  final int completedDays;
  final double progressPercentage;
  final DateTime startDate;

  const HabitStatistic({
    required this.habitId,
    required this.habitName,
    required this.totalDays,
    required this.completedDays,
    required this.progressPercentage,
    required this.startDate,
  });
}

/// Monthly comparison data model
class MonthlyComparison {
  final double thisMonthRate;
  final double lastMonthRate;
  final double difference;
  final bool isImprovement;

  const MonthlyComparison({
    required this.thisMonthRate,
    required this.lastMonthRate,
    required this.difference,
    required this.isImprovement,
  });
}
