//
//  MediumHabitWidget.swift
//  HabitFormWidget
//
//  Created by Armagan Gok on 4.10.2025.
//

import AppIntents
import Foundation
import SwiftUI
import WidgetKit

struct MediumHabitWidget: Widget {
    let kind: String = "MediumHabitWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind, intent: HabitConfigurationIntent.self, provider: MediumHabitProvider()
        ) { entry in
            MediumHabitWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("7-Day Habit View")
        .description("View your habit progress over the last 7 days")
        .supportedFamilies([.systemMedium])
    }
}

struct MediumHabitProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> MediumHabitEntry {
        MediumHabitEntry(
            date: Date(),
            habit: Habit(
                id: "empty",
                habitName: "No Habits",
                habitDescription: "Create a habit in the app to see it here",
                emoji: "📝",
                dailyTarget: 1,
                colorCode: 0x999999,
                completions: [:],
                archiveDate: nil,
                status: .active,
                categoryIds: [],
                difficulty: .easy
            ),
            weekData: [:]
        )
    }

    func snapshot(for configuration: HabitConfigurationIntent, in context: Context) async
        -> MediumHabitEntry
    {
        let habits = HabitDataManager.shared.loadHabits()

        // If no habits exist, return empty state
        guard !habits.isEmpty else {
            return placeholder(in: context)
        }

        let habit =
            habits.first(where: { $0.id == configuration.habit?.id })
            ?? habits.first!  // Use first habit if configured habit not found
        let weekData = HabitDataManager.shared.getHabitCompletionData(for: habit.id, days: 7)

        return MediumHabitEntry(date: Date(), habit: habit, weekData: weekData)
    }

    func timeline(for configuration: HabitConfigurationIntent, in context: Context) async
        -> Timeline<MediumHabitEntry>
    {
        let habits = HabitDataManager.shared.loadHabits()

        // If no habits exist, return empty state
        guard !habits.isEmpty else {
            let currentDate = Date()
            let entry = placeholder(in: context)
            let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
            return Timeline(entries: [entry], policy: .after(nextUpdate))
        }

        let habit =
            habits.first(where: { $0.id == configuration.habit?.id })
            ?? habits.first!  // Use first habit if configured habit not found
        let weekData = HabitDataManager.shared.getHabitCompletionData(for: habit.id, days: 7)

        let currentDate = Date()
        let entry = MediumHabitEntry(date: currentDate, habit: habit, weekData: weekData)

        // Update every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }

    private func generatePlaceholderWeekData() -> [Date: Bool] {
        var data: [Date: Bool] = [:]
        let calendar = Calendar.current

        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                data[date] = i % 2 == 0  // Alternate completion for demo
            }
        }

        return data
    }
}

struct MediumHabitEntry: TimelineEntry {
    let date: Date
    let habit: Habit
    let weekData: [Date: Bool]
}

struct MediumHabitWidgetEntryView: View {
    var entry: MediumHabitProvider.Entry

    private var habitColor: Color {
        Color(hex: entry.habit.colorCode)
    }

    private var completionRatio: Double {
        let count = entry.habit.completionCountToday
        let target = entry.habit.dailyTarget
        return target > 0 ? min(Double(count) / Double(target), 1.0) : 0.0
    }

    private var sortedWeekData: [(Date, Bool)] {
        entry.weekData.sorted { $0.key > $1.key }
    }

    private var completionRate: Double {
        let completed = entry.weekData.values.filter { $0 }.count
        let total = entry.weekData.count
        guard total > 0 else { return 0.0 }
        return Double(completed) / Double(total)
    }

    var body: some View {
        VStack(spacing: 12) {
            // Header with habit info
            HStack {
                // Left side: Emoji + Habit name
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
                            .font(.system(size: 24)).padding(.all, 2.5)
                    }

                    Text(entry.habit.habitName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                // Right side: Current streak
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(habitColor)
                        .font(.system(size: 16))
                    Text("\(entry.habit.currentStreak)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 90)
                        .fill(habitColor.opacity(0.12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 90)
                                .stroke(habitColor.opacity(0.25), lineWidth: 1)
                        )
                )
            }

            Spacer()

            // 7-day progress view - clickable buttons
            HStack(spacing: 8) {
                ForEach(Array(sortedWeekData.enumerated()), id: \.offset) { index, item in
                    let (date, isCompleted) = item
                    Button(intent: CompleteHabitIntent(habitId: entry.habit.id)) {
                        VStack(spacing: 6) {
                            // Day indicator
                            Text(dayAbbreviation(for: date))
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.secondary)

                            // Completion indicator - larger and more prominent
                            ZStack {
                                Circle()
                                    .fill(isCompleted ? habitColor : habitColor.opacity(0.2))
                                    .frame(width: 34, height: 34)
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                isCompleted ? habitColor : habitColor.opacity(0.4),
                                                lineWidth: 2)
                                    )

                                if isCompleted {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .frame(maxWidth: .infinity)
            }
        }

    }

    private func dayAbbreviation(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
}

#Preview(as: .systemMedium) {
    MediumHabitWidget()
} timeline: {
    MediumHabitEntry(
        date: .now,
        habit: Habit(
            id: "preview",
            habitName: "Exercise",
            habitDescription: "Daily workout",
            emoji: "🏃‍♂️",
            dailyTarget: 1,
            colorCode: 0x50C878,
            completions: [:],
            archiveDate: nil,
            status: .active,
            categoryIds: [],
            difficulty: .moderate
        ),
        weekData: [:]
    )
}
