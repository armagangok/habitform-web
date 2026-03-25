//
//  SmallHabitWidget.swift
//  HabitFormWidget
//
//  Created by Armagan Gok on 4.10.2025.
//

import AppIntents
import Foundation
import SwiftUI
import WidgetKit

struct SmallHabitWidget: Widget {
    let kind: String = "SmallHabitWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind, intent: HabitConfigurationIntent.self, provider: SmallHabitProvider()
        ) { entry in
            if let isProMember = entry.habit.isProMember, !isProMember {
                // Pro restriction view with full blur background
                ZStack {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .containerBackground(.fill.tertiary, for: .widget)

                    VStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)

                        Text(WidgetLocalization.getLocalizedString(for: "widget.pro.upgrade"))
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.primary)
                    }
                }
                .containerBackground(.fill.tertiary, for: .widget)
            } else {
                SmallHabitWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            }
        }
        .configurationDisplayName(WidgetLocalization.getLocalizedString(for: "widget.small.title"))
        .description(WidgetLocalization.getLocalizedString(for: "widget.small.description"))
        .supportedFamilies([.systemSmall])
    }
}

struct SmallHabitProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SmallHabitEntry {
        // Return empty habit for placeholder
        SmallHabitEntry(
            date: Date(),
            habit: Habit(
                id: "empty",
                habitName: WidgetLocalization.getLocalizedString(for: "widget.empty.no_habits"),
                habitDescription: WidgetLocalization.getLocalizedString(
                    for: "widget.empty.create_hint"),
                emoji: "📝",
                dailyTarget: 1,
                colorCode: 0x999999,
                completions: [:],
                archiveDate: nil,
                status: .active,
                categoryIds: [],
                difficulty: .easy,
                flutterProbabilityScore: 0.0,
                flutterLongestStreak: 0,
                flutterCurrentStreak: 0,
                flutterCompletedDays: 0,
                flutterTotalDays: 0,
                isProMember: nil  // nil = unknown, never lock the placeholder
            )
        )
    }

    func snapshot(for configuration: HabitConfigurationIntent, in context: Context) async
        -> SmallHabitEntry
    {
        print("🔍 SmallHabitWidget: snapshot() called at \(Date())")
        print("🔍 SmallHabitWidget: Configuration habit ID: '\(configuration.habit?.id ?? "nil")'")

        // Test App Group access first
        HabitDataManager.shared.testAppGroupAccess()

        let habits = HabitDataManager.shared.loadHabits()
        print("🔍 SmallHabitWidget: Loaded \(habits.count) habits from HabitDataManager in snapshot")

        // If no habits exist, return empty state
        guard !habits.isEmpty else {
            print("⚠️ SmallHabitWidget: No habits found in snapshot, returning placeholder")
            return placeholder(in: context)
        }

        let habit =
            habits.first(where: { $0.id == configuration.habit?.id })
            ?? habits.first!  // Use first habit if configured habit not found

        print("✅ SmallHabitWidget: Found habit in snapshot: \(habit.habitName) (\(habit.id))")
        return SmallHabitEntry(date: Date(), habit: habit)
    }

    func timeline(for configuration: HabitConfigurationIntent, in context: Context) async
        -> Timeline<SmallHabitEntry>
    {
        print("🔍 SmallHabitWidget: timeline() called at \(Date())")
        print("🔍 SmallHabitWidget: Configuration habit ID: '\(configuration.habit?.id ?? "nil")'")

        // Test App Group access first
        HabitDataManager.shared.testAppGroupAccess()

        let habits = HabitDataManager.shared.loadHabits()
        print("🔍 SmallHabitWidget: Loaded \(habits.count) habits from HabitDataManager")
        print("🔍 SmallHabitWidget: Available habits: \(habits.map { "\($0.id): \($0.habitName)" })")

        // If no habits exist, return empty state
        guard !habits.isEmpty else {
            print("⚠️ SmallHabitWidget: No habits found, showing empty state")
            let currentDate = Date()
            let entry = placeholder(in: context)
            let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
            print("📅 SmallHabitWidget: Returning empty timeline, next update at \(nextUpdate)")
            return Timeline(entries: [entry], policy: .after(nextUpdate))
        }

        let habit =
            habits.first(where: { $0.id == configuration.habit?.id })
            ?? habits.first!  // Use first habit if configured habit not found

        print("✅ SmallHabitWidget: Found habit: \(habit.habitName) (\(habit.id))")
        print("📊 SmallHabitWidget: Habit has \(habit.completions.count) completions")

        let currentDate = Date()
        let entry = SmallHabitEntry(date: currentDate, habit: habit)

        // Update every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        print(
            "📅 SmallHabitWidget: Returning timeline with habit '\(habit.habitName)', next update at \(nextUpdate)"
        )
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
        ZStack {
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
                            .frame(width: 36, height: 36)

                        Text(entry.habit.emoji ?? "🎯")
                            .font(.system(size: 24))
                    }

                    Spacer()

                    // Streak pill
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 18))
                            .foregroundColor(habitColor)

                        Text("\(entry.habit.currentStreak)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))

                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .frame(height: 36)
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
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .lineLimit(4)
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
        }
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
            completions: [:],
            archiveDate: nil,
            status: .active,
            categoryIds: [],
            difficulty: .easy,
            flutterProbabilityScore: 0.0,
            flutterLongestStreak: 0,
            flutterCurrentStreak: 0,
            flutterCompletedDays: 0,
            flutterTotalDays: 0,
            isProMember: true
        )
    )
}
