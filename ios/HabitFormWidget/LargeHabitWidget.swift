//
//  LargeHabitWidget.swift
//  HabitFormWidget
//
//  Created by Armagan Gok on 4.10.2025.
//

import AppIntents
import Foundation
import SwiftUI
import WidgetKit

struct LargeHabitWidget: Widget {
    let kind: String = "LargeHabitWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind, intent: HabitConfigurationIntent.self, provider: LargeHabitProvider()
        ) { entry in
            LargeHabitWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Habit Heatmap")
        .description("GitHub-style heatmap showing your habit completion over time")
        .supportedFamilies([.systemLarge])
    }
}

struct LargeHabitProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> LargeHabitEntry {
        LargeHabitEntry(
            date: Date(),
            habit: Habit(
                id: "placeholder",
                habitName: "Meditation",
                habitDescription: "Daily mindfulness practice",
                emoji: "🧘‍♀️",
                dailyTarget: 1,
                colorCode: 0x9B59B6,
                status: .active,
                categoryIds: [],
                difficulty: .moderate,
                completions: [:]
            ),
            heatmapData: generatePlaceholderHeatmapData()
        )
    }

    func snapshot(for configuration: HabitConfigurationIntent, in context: Context) async
        -> LargeHabitEntry
    {
        let habits = HabitDataManager.shared.loadHabits()
        let habit =
            habits.first(where: { $0.id == configuration.habit?.id })
            ?? placeholder(in: context).habit
        let heatmapData = HabitDataManager.shared.getHabitCompletionData(for: habit.id, days: 90)

        return LargeHabitEntry(date: Date(), habit: habit, heatmapData: heatmapData)
    }

    func timeline(for configuration: HabitConfigurationIntent, in context: Context) async
        -> Timeline<LargeHabitEntry>
    {
        let habits = HabitDataManager.shared.loadHabits()
        let habit =
            habits.first(where: { $0.id == configuration.habit?.id })
            ?? placeholder(in: context).habit
        let heatmapData = HabitDataManager.shared.getHabitCompletionData(for: habit.id, days: 90)

        let currentDate = Date()
        let entry = LargeHabitEntry(date: currentDate, habit: habit, heatmapData: heatmapData)

        // Update every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }

    private func generatePlaceholderHeatmapData() -> [Date: Bool] {
        var data: [Date: Bool] = [:]
        let calendar = Calendar.current

        for i in 0..<90 {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                data[date] = Bool.random()  // Random completion for demo
            }
        }

        return data
    }
}

struct LargeHabitEntry: TimelineEntry {
    let date: Date
    let habit: Habit
    let heatmapData: [Date: Bool]
}

struct LargeHabitWidgetEntryView: View {
    var entry: LargeHabitProvider.Entry

    private var habitColor: Color {
        Color(hex: entry.habit.colorCode)
    }

    private var completionRatio: Double {
        let count = entry.habit.completionCountToday
        let target = entry.habit.dailyTarget
        return target > 0 ? min(Double(count) / Double(target), 1.0) : 0.0
    }

    private func monthName(for monthIndex: Int) -> String {
        let calendar = Calendar.current
        let today = Date()
        let monthsAgo = 2 - monthIndex  // 0 = 2 months ago, 1 = 1 month ago, 2 = current month
        if let date = calendar.date(byAdding: .month, value: -monthsAgo, to: today) {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"
            return formatter.string(from: date)
        }
        return "MMM"
    }

    private func getDateForGrid(monthIndex: Int, week: Int, day: Int) -> Date? {
        let calendar = Calendar.current
        let today = Date()
        let monthsAgo = 2 - monthIndex  // 0 = 2 months ago, 1 = 1 month ago, 2 = current month

        guard let monthDate = calendar.date(byAdding: .month, value: -monthsAgo, to: today) else {
            return nil
        }

        let year = calendar.component(.year, from: monthDate)
        let month = calendar.component(.month, from: monthDate)

        // Get first day of month and its weekday
        guard
            let firstDayOfMonth = calendar.date(
                from: DateComponents(year: year, month: month, day: 1))
        else {
            return nil
        }

        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth) - 1  // 0 = Sunday, 6 = Saturday

        // Calculate the day number
        let dayNumber = week * 7 + day + 1 - firstWeekday

        // Check if day is in the month
        let daysInMonth = calendar.range(of: .day, in: .month, for: firstDayOfMonth)?.count ?? 30

        if dayNumber > 0 && dayNumber <= daysInMonth {
            return calendar.date(from: DateComponents(year: year, month: month, day: dayNumber))
        }

        return nil
    }

    private func isDateInMonth(_ date: Date, monthIndex: Int) -> Bool {
        let calendar = Calendar.current
        let today = Date()
        let monthsAgo = 2 - monthIndex  // 0 = 2 months ago, 1 = 1 month ago, 2 = current month

        guard let monthDate = calendar.date(byAdding: .month, value: -monthsAgo, to: today) else {
            return false
        }

        let targetYear = calendar.component(.year, from: monthDate)
        let targetMonth = calendar.component(.month, from: monthDate)
        let dateYear = calendar.component(.year, from: date)
        let dateMonth = calendar.component(.month, from: date)

        return targetYear == dateYear && targetMonth == dateMonth
    }

    private func getMonthWeeks(monthIndex: Int) -> Int {
        let calendar = Calendar.current
        let today = Date()
        let monthsAgo = 2 - monthIndex  // 0 = 2 months ago, 1 = 1 month ago, 2 = current month

        guard let monthDate = calendar.date(byAdding: .month, value: -monthsAgo, to: today) else {
            return 6
        }

        let year = calendar.component(.year, from: monthDate)
        let month = calendar.component(.month, from: monthDate)

        guard
            let firstDayOfMonth = calendar.date(
                from: DateComponents(year: year, month: month, day: 1)),
            let lastDayOfMonth = calendar.date(
                byAdding: DateComponents(month: 1, day: -1), to: firstDayOfMonth)
        else {
            return 6
        }

        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth) - 1  // 0 = Sunday, 6 = Saturday
        let daysInMonth = calendar.component(.day, from: lastDayOfMonth)

        // Calculate how many weeks we need
        let totalCells = firstWeekday + daysInMonth
        let weeksNeeded = (totalCells + 6) / 7  // Round up to nearest week

        return weeksNeeded
    }

    private var completionStats: (total: Int, completed: Int, streak: Int) {
        let total = entry.heatmapData.count
        let completed = entry.heatmapData.values.filter { $0 }.count
        let streak = entry.habit.currentStreak

        return (total, completed, streak)
    }

    var body: some View {
        VStack(spacing: 8) {
            // Header with habit name and emoji
            HStack {
                // Habit name on the left
                Text(entry.habit.habitName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Spacer()

                // Emoji circle on the right
                ZStack {
                    Circle()
                        .fill(habitColor.opacity(0.12))
                        .overlay(
                            Circle()
                                .stroke(habitColor.opacity(0.25), lineWidth: 1)
                        )
                        .frame(width: 36, height: 36)

                    Text(entry.habit.emoji ?? "🎯")
                        .font(.system(size: 20))
                }
            }

            Spacer()

            // Stats row - Current Streak, Longest Streak, Formation Probability
            // Stats row - 3 separate cards
            HStack(spacing: 8) {
                // Current Streak Card
                VStack(alignment: .leading, spacing: 2) {
                    Text("Current")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 12))
                            .foregroundColor(habitColor)
                        Text("\(entry.habit.currentStreak)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(habitColor.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(habitColor.opacity(0.15), lineWidth: 1)
                        )
                )

                // Longest Streak Card
                VStack(alignment: .leading, spacing: 2) {
                    Text("Longest")
                        .font(.system(size: 11  , weight: .medium))
                        .foregroundColor(.secondary)
                    HStack(spacing: 4) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 12))
                            .foregroundColor(habitColor)
                        Text("\(entry.habit.longestStreak)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(habitColor.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(habitColor.opacity(0.15), lineWidth: 1)
                        )
                )

                // Formation Probability Card
                VStack(alignment: .leading, spacing: 2) {
                    Text("Probability")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                    HStack(spacing: 4) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 12))
                            .foregroundColor(habitColor)
                        Text("\(Int(entry.habit.formationProbability * 100))%")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(habitColor.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(habitColor.opacity(0.15), lineWidth: 1)
                        )
                )
            }

            Spacer()

            // Heatmap - 3 months view (like habit_data_widget.dart)
            HStack(spacing: 12) {
                // First Month
                VStack(spacing: 4) {
                    Text(monthName(for: 0))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)

                    HStack(spacing: 2) {
                        ForEach(0..<getMonthWeeks(monthIndex: 0), id: \.self) { week in
                            VStack(spacing: 2) {
                                ForEach(0..<7, id: \.self) { day in
                                    let date = getDateForGrid(monthIndex: 0, week: week, day: day)
                                    if let date = date, isDateInMonth(date, monthIndex: 0) {
                                        let isCompleted =
                                            entry.habit.completions[
                                                DateFormatter.habitDateKey.string(from: date)]?
                                            .isCompleted ?? false
                                        let isToday = Calendar.current.isDate(
                                            date, inSameDayAs: Date())

                                        Rectangle()
                                            .fill(
                                                isCompleted
                                                    ? habitColor.opacity(0.8)
                                                    : habitColor.opacity(0.2)
                                            )
                                            .frame(width: 14, height: 14)
                                            .cornerRadius(3.5)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 3.5)
                                                    .stroke(
                                                        isToday
                                                            ? (Color.primary.opacity(0.8))
                                                            : Color.clear, lineWidth: 1)
                                            )
                                    } else {
                                        Rectangle()
                                            .fill(Color.clear)
                                            .frame(width: 14, height: 14)
                                    }
                                }
                            }
                        }
                    }

                }

                // Second Month
                VStack(spacing: 4) {
                    Text(monthName(for: 1))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)

                    HStack(spacing: 2) {
                        ForEach(0..<getMonthWeeks(monthIndex: 1), id: \.self) { week in
                            VStack(spacing: 2) {
                                ForEach(0..<7, id: \.self) { day in
                                    let date = getDateForGrid(monthIndex: 1, week: week, day: day)
                                    if let date = date, isDateInMonth(date, monthIndex: 1) {
                                        let isCompleted =
                                            entry.habit.completions[
                                                DateFormatter.habitDateKey.string(from: date)]?
                                            .isCompleted ?? false
                                        let isToday = Calendar.current.isDate(
                                            date, inSameDayAs: Date())

                                        Rectangle()
                                            .fill(
                                                isCompleted
                                                    ? habitColor.opacity(0.8)
                                                    : habitColor.opacity(0.2)
                                            )
                                            .frame(width: 14, height: 14)
                                            .cornerRadius(3.5)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 3.5)
                                                    .stroke(
                                                        isToday
                                                            ? (Color.primary.opacity(0.8))
                                                            : Color.clear, lineWidth: 1)
                                            )
                                    } else {
                                        Rectangle()
                                            .fill(Color.clear)
                                            .frame(width: 14, height: 14)
                                    }
                                }
                            }
                        }
                    }
                }

                // Third Month(Current Month)
                VStack(spacing: 4) {
                    Text(monthName(for: 2))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)

                    HStack(spacing: 2) {
                        ForEach(0..<getMonthWeeks(monthIndex: 2), id: \.self) { week in
                            VStack(spacing: 2) {
                                ForEach(0..<7, id: \.self) { day in
                                    let date = getDateForGrid(monthIndex: 2, week: week, day: day)
                                    if let date = date, isDateInMonth(date, monthIndex: 2) {
                                        let isCompleted =
                                            entry.habit.completions[
                                                DateFormatter.habitDateKey.string(from: date)]?
                                            .isCompleted ?? false
                                        let isToday = Calendar.current.isDate(
                                            date, inSameDayAs: Date())

                                        Rectangle()
                                            .fill(
                                                isCompleted
                                                    ? habitColor.opacity(0.8)
                                                    : habitColor.opacity(0.2)
                                            )
                                            .frame(width: 14, height: 14)
                                            .cornerRadius(3.5)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 3.5)
                                                    .stroke(
                                                        isToday
                                                            ? (Color.primary.opacity(0.8))
                                                            : Color.clear, lineWidth: 1)
                                            )
                                    } else {
                                        Rectangle()
                                            .fill(Color.clear)
                                            .frame(width: 14, height: 14)
                                    }
                                }
                            }
                        }
                    }
                }

            }
        }

        Spacer()
        Spacer()
        Spacer()

        // Complete button at the bottom
        Button(
            intent: CompleteHabitIntent(habitId: entry.habit.id)
        ) {
            HStack(spacing: 6) {

                Text(entry.habit.isCompletedToday ? "Completed" : "Complete")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(entry.habit.isCompletedToday ? .white : habitColor)

                Image(
                    systemName: entry.habit.isCompletedToday
                        ? "checkmark.circle.fill" : "circle"
                )
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(entry.habit.isCompletedToday ? .white : habitColor)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 90)
                    .fill(
                        entry.habit.isCompletedToday ? habitColor : habitColor.opacity(0.1)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 90)
                            .stroke(habitColor, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

private func heatmapColor(for isCompleted: Bool, isToday: Bool) -> Color {
    if isToday {
        return isCompleted ? Color.green : Color.blue.opacity(0.3)
    } else {
        return isCompleted ? Color.green.opacity(0.6) : Color.gray.opacity(0.3)
    }
}

#Preview(as: .systemLarge) {
    LargeHabitWidget()
} timeline: {
    LargeHabitEntry(
        date: .now,
        habit: Habit(
            id: "preview",
            habitName: "Meditation",
            habitDescription: "Daily mindfulness practice",
            emoji: "🧘‍♀️",
            dailyTarget: 1,
            colorCode: 0x9B59B6,
            status: .active,
            categoryIds: [],
            difficulty: .moderate,
            completions: [:]
        ),
        heatmapData: [:]
    )
}
