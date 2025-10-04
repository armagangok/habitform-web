//
//  SmallHabitWidget.swift
//  HabitFormWidget
//
//  Created by Armagan Gok on 4.10.2025.
//

import AppIntents
import SwiftUI
import WidgetKit

struct SmallHabitWidget: Widget {
    let kind: String = "SmallHabitWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind, intent: HabitConfigurationIntent.self, provider: SmallHabitProvider()
        ) { entry in
            SmallHabitWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Habit Tracker")
        .description("Track your daily habits with streak counter")
        .supportedFamilies([.systemSmall])
    }
}

struct SmallHabitProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SmallHabitEntry {
        SmallHabitEntry(
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
        -> SmallHabitEntry
    {
        let habits = HabitDataManager.shared.loadHabits()
        let habit =
            habits.first(where: { $0.id == configuration.habit?.id })
            ?? placeholder(in: context).habit

        return SmallHabitEntry(date: Date(), habit: habit)
    }

    func timeline(for configuration: HabitConfigurationIntent, in context: Context) async
        -> Timeline<SmallHabitEntry>
    {
        let habits = HabitDataManager.shared.loadHabits()
        let habit =
            habits.first(where: { $0.id == configuration.habit?.id })
            ?? placeholder(in: context).habit

        let currentDate = Date()
        let entry = SmallHabitEntry(date: currentDate, habit: habit)

        // Update every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }
}

struct SmallHabitEntry: TimelineEntry {
    let date: Date
    let habit: Habit
}

struct SmallHabitWidgetEntryView: View {
    var entry: SmallHabitProvider.Entry

    private var habitColor: Color {
        Color(hex: entry.habit.colorCode)
    }

    private var completionRatio: Double {
        let count = entry.habit.completionCountToday
        let target = entry.habit.dailyTarget
        return target > 0 ? min(Double(count) / Double(target), 1.0) : 0.0
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top section with emoji and streak
            HStack {
                // Emoji circle
                ZStack {
                    Circle()
                        .fill(habitColor.opacity(0.12))
                        .overlay(
                            Circle()
                                .stroke(habitColor.opacity(0.25), lineWidth: 1)
                        )
                        .frame(width: 32, height: 32)

                    Text(entry.habit.emoji ?? "🎯")
                        .font(.system(size: 18))
                }

                Spacer()

                // Streak pill
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 10))
                        .foregroundColor(habitColor)

                    Text("\(entry.habit.currentStreak)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(habitColor)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
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

            // Habit name and completion button side by side
            HStack {
                // Habit name
                Text(entry.habit.habitName)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Spacer()

                // Completion button
                Button(intent: CompleteHabitIntent(habitId: entry.habit.id)) {
                    ZStack {
                        if completionRatio >= 1.0 {
                            // Completed state
                            Circle()
                                .fill(habitColor)
                                .frame(width: 28, height: 28)
                                .shadow(color: habitColor.opacity(0.3), radius: 4, x: 0, y: 2)

                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        } else {
                            // Incomplete state
                            Circle()
                                .fill(habitColor.opacity(0.12 + 0.88 * completionRatio))
                                .overlay(
                                    Circle()
                                        .stroke(habitColor.opacity(0.6), lineWidth: 2)
                                )
                                .frame(width: 28, height: 28)

                            Image(systemName: "circle")
                                .font(.system(size: 14))
                                .foregroundColor(.clear)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(8)
    }
}

#Preview(as: .systemSmall) {
    SmallHabitWidget()
} timeline: {
    SmallHabitEntry(
        date: .now,
        habit: Habit(
            id: "preview",
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
