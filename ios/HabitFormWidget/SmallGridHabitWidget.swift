//
//  SmallGridHabitWidget.swift
//  HabitFormWidget
//
//  Created by Armagan Gok on 4.10.2025.
//

import AppIntents
import Foundation
import SwiftUI
import WidgetKit

struct SmallGridHabitWidget: Widget {
    let kind: String = "SmallGridHabitWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind, intent: HabitConfigurationIntent.self, provider: SmallGridHabitProvider()
        ) { entry in
            SmallGridHabitWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("60-Day Habit Grid")
        .description("View your habit progress over the last 60 days in a compact grid")
        .supportedFamilies([.systemSmall])
    }
}

struct SmallGridHabitProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SmallGridHabitEntry {
        SmallGridHabitEntry(
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
            )
        )
    }

    func snapshot(for configuration: HabitConfigurationIntent, in context: Context) async
        -> SmallGridHabitEntry
    {
        let habits = HabitDataManager.shared.loadHabits()

        // If no habits exist, return empty state
        guard !habits.isEmpty else {
            return placeholder(in: context)
        }

        let habit =
            habits.first(where: { $0.id == configuration.habit?.id })
            ?? habits.first!  // Use first habit if configured habit not found

        return SmallGridHabitEntry(date: Date(), habit: habit)
    }

    func timeline(for configuration: HabitConfigurationIntent, in context: Context) async
        -> Timeline<SmallGridHabitEntry>
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

        let currentDate = Date()
        let entry = SmallGridHabitEntry(date: currentDate, habit: habit)

        // Update every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }
}

struct SmallGridHabitEntry: TimelineEntry {
    let date: Date
    let habit: Habit
}

struct SmallGridHabitWidgetEntryView: View {
    var entry: SmallGridHabitProvider.Entry

    private var habitColor: Color {
        Color(hex: entry.habit.colorCode)
    }

    private var completionRatio: Double {
        let count = entry.habit.completionCountToday
        let target = entry.habit.dailyTarget
        return target > 0 ? min(Double(count) / Double(target), 1.0) : 0.0
    }

    private var gridData: [Date] {
        let calendar = Calendar.current
        let today = Date()
        var dates: [Date] = []

        // Last 60 days (6 rows x 10 columns) to maximize horizontal space
        for i in 0..<60 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                dates.append(date)
            }
        }

        return dates.reversed()  // Oldest to newest
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header with emoji and name
            Spacer()
            HStack {
                // Habit name - now has maximum space
                Text(entry.habit.habitName)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Spacer()
                // Emoji circle
                ZStack {
                    Circle()
                        .fill(habitColor.opacity(0.12))
                        .overlay(
                            Circle()
                                .stroke(habitColor.opacity(0.25), lineWidth: 1)
                        )
                        .frame(width: 20, height: 20)

                    Text(entry.habit.emoji ?? "🎯")
                        .font(.system(size: 10))
                }

            }

            Spacer()

            // 60-day grid (6 rows x 10 columns) - maximize horizontal space
            VStack(spacing: 2) {
                ForEach(0..<6, id: \.self) { row in
                    HStack(spacing: 2) {
                        ForEach(0..<10, id: \.self) { col in
                            let index = row * 10 + col
                            if index < gridData.count {
                                let date = gridData[index]
                                let isCompleted =
                                    entry.habit.completions[
                                        DateFormatter.habitDateKey.string(from: date)]?.isCompleted
                                    ?? false
                                let isToday = Calendar.current.isDate(date, inSameDayAs: Date())

                                Button(intent: CompleteHabitIntent(habitId: entry.habit.id)) {
                                    Rectangle()
                                        .fill(
                                            isCompleted
                                                ? habitColor.opacity(0.8) : habitColor.opacity(0.2)
                                        )
                                        .frame(width: 11, height: 11)
                                        .cornerRadius(2)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 2)
                                                .stroke(
                                                    isToday
                                                        ? (Color.primary.opacity(0.8))
                                                        : Color.clear,
                                                    lineWidth: 0.5)
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                            } else {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(width: 11, height: 11)
                            }
                        }
                    }
                }
            }
            Spacer()
        }

    }
}

#Preview(as: .systemSmall) {
    SmallGridHabitWidget()
} timeline: {
    SmallGridHabitEntry(
        date: .now,
        habit: Habit(
            id: "test",
            habitName: "Drink Water",
            habitDescription: "Stay hydrated",
            emoji: "💧",
            dailyTarget: 1,
            colorCode: 0x4A90E2,
            completions: [:],
            archiveDate: nil,
            status: .active,
            categoryIds: [],
            difficulty: .easy
        )
    )
}
