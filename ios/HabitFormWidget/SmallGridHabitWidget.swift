//
//  SmallGridHabitWidget.swift
//  HabitFormWidget
//
//  Created by Armagan Gok on 4.10.2025.
//

import AppIntents
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
        .configurationDisplayName("30-Day Habit Grid")
        .description("View your habit progress over the last 30 days in a compact grid")
        .supportedFamilies([.systemSmall])
    }
}

struct SmallGridHabitProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SmallGridHabitEntry {
        SmallGridHabitEntry(
            date: Date(),
            habit: Habit(
                id: "placeholder",
                habitName: "Drink Water",
                habitDescription: "Stay hydrated",
                emoji: "💧",
                dailyTarget: 1,
                colorCode: 0x4A90E2,
                status: .active,
                categoryIds: [],
                difficulty: .easy,
                completions: [:]
            )
        )
    }

    func snapshot(for configuration: HabitConfigurationIntent, in context: Context) async
        -> SmallGridHabitEntry
    {
        let habits = HabitDataManager.shared.loadHabits()
        let habit =
            habits.first(where: { $0.id == configuration.habit?.id })
            ?? placeholder(in: context).habit

        return SmallGridHabitEntry(date: Date(), habit: habit)
    }

    func timeline(for configuration: HabitConfigurationIntent, in context: Context) async
        -> Timeline<SmallGridHabitEntry>
    {
        let habits = HabitDataManager.shared.loadHabits()
        let habit =
            habits.first(where: { $0.id == configuration.habit?.id })
            ?? placeholder(in: context).habit

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

        // Last 30 days
        for i in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                dates.append(date)
            }
        }

        return dates.reversed()  // Oldest to newest
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header with emoji, name and streak
            HStack {
                // Emoji circle
                ZStack {
                    Circle()
                        .fill(habitColor.opacity(0.12))
                        .overlay(
                            Circle()
                                .stroke(habitColor.opacity(0.25), lineWidth: 1)
                        )
                        .frame(width: 24, height: 24)

                    Text(entry.habit.emoji ?? "🎯")
                        .font(.system(size: 12))
                }

                // Habit name
                Text(entry.habit.habitName)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Spacer()

                // Streak pill
                HStack(spacing: 2) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 8))
                        .foregroundColor(habitColor)

                    Text("\(entry.habit.currentStreak)")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(habitColor)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    Capsule()
                        .fill(habitColor.opacity(0.18))
                        .overlay(
                            Capsule()
                                .stroke(habitColor.opacity(0.25), lineWidth: 1)
                        )
                )
            }

            Spacer()

            // 30-day grid (6 rows x 5 columns)
            VStack(spacing: 2) {
                ForEach(0..<6, id: \.self) { row in
                    HStack(spacing: 2) {
                        ForEach(0..<5, id: \.self) { col in
                            let index = row * 5 + col
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
                                        .frame(width: 8, height: 8)
                                        .cornerRadius(1)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 1)
                                                .stroke(
                                                    isToday ? habitColor : Color.clear,
                                                    lineWidth: 0.5)
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                            } else {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(width: 8, height: 8)
                            }
                        }
                    }
                }
            }
        }
        .padding(8)
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
            status: .active,
            categoryIds: [],
            difficulty: .easy,
            completions: [:]
        )
    )
}
