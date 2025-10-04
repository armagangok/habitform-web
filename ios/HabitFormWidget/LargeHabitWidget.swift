//
//  LargeHabitWidget.swift
//  HabitFormWidget
//
//  Created by Armagan Gok on 4.10.2025.
//

import AppIntents
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

    private var heatmapGrid: [Date?] {
        let calendar = Calendar.current
        let today = Date()
        var grid: [Date?] = Array(repeating: nil, count: 13)

        // Fill grid with week start dates (13 weeks, 1 date per week)
        for week in 0..<13 {
            let daysBack = (12 - week) * 7
            if let date = calendar.date(byAdding: .day, value: -daysBack, to: today) {
                // Get the start of the week (Sunday)
                let weekStart = calendar.dateInterval(of: .weekOfYear, for: date)?.start
                grid[week] = weekStart
            }
        }

        return grid
    }

    private var completionStats: (total: Int, completed: Int, streak: Int) {
        let total = entry.heatmapData.count
        let completed = entry.heatmapData.values.filter { $0 }.count
        let streak = entry.habit.currentStreak

        return (total, completed, streak)
    }

    var body: some View {
        VStack(spacing: 16) {
            // Header with habit name and completion button side by side
            HStack {
                HStack(spacing: 8) {
                    // Emoji circle
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

                    Text(entry.habit.habitName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                // Stats only
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(completionStats.completed)/\(completionStats.total)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)

                }
            }

            // Heatmap - GitHub style (13 weeks vertical)
            VStack(spacing: 3) {

                // Heatmap grid - 7 rows x 13 columns
                ForEach(0..<7, id: \.self) { dayIndex in
                    HStack(spacing: 3) {
                        ForEach(Array(heatmapGrid.enumerated()), id: \.offset) {
                            weekIndex, weekStartDate in
                            if let weekStartDate = weekStartDate {
                                let calendar = Calendar.current
                                let dayDate =
                                    calendar.date(
                                        byAdding: .day, value: dayIndex, to: weekStartDate)
                                    ?? weekStartDate
                                let isCompleted = entry.heatmapData[dayDate] ?? false
                                let isToday = calendar.isDate(dayDate, inSameDayAs: Date())

                                Button(intent: CompleteHabitIntent(habitId: entry.habit.id)) {
                                    Rectangle()
                                        .fill(
                                            isCompleted
                                                ? habitColor.opacity(0.8) : habitColor.opacity(0.2)
                                        )
                                        .frame(width: 16, height: 16)
                                        .cornerRadius(3)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 3)
                                                .stroke(
                                                    isToday ? habitColor : Color.clear, lineWidth: 1
                                                )
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                            } else {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(width: 16, height: 16)
                            }
                        }
                    }
                }
            }
            Spacer()

            // Legend

            HStack {
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Rectangle()
                            .fill(habitColor.opacity(0.2))
                            .frame(width: 12, height: 12)
                            .cornerRadius(2)
                        Text("None")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }

                    HStack(spacing: 4) {
                        Rectangle()
                            .fill(habitColor.opacity(0.8))
                            .frame(width: 12, height: 12)
                            .cornerRadius(2)
                        Text("Completed")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }

                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 90)
                        .fill(habitColor.opacity(0.12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 90)
                                .stroke(habitColor.opacity(0.25), lineWidth: 1)
                        )
                )

                Spacer()

                Text("Last 90 days")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)

            }

        }
        .padding(0)
    }

    private func heatmapColor(for isCompleted: Bool, isToday: Bool) -> Color {
        if isToday {
            return isCompleted ? Color.green : Color.blue.opacity(0.3)
        } else {
            return isCompleted ? Color.green.opacity(0.6) : Color.gray.opacity(0.3)
        }
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
