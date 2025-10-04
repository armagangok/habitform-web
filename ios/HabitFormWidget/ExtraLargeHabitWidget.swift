//
//  ExtraLargeHabitWidget.swift
//  HabitFormWidget
//
//  Created by Armagan Gok on 4.10.2025.
//

import AppIntents
import SwiftUI
import WidgetKit

struct ExtraLargeHabitWidget: Widget {
    let kind: String = "ExtraLargeHabitWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind, intent: HabitConfigurationIntent.self, provider: ExtraLargeHabitProvider()
        ) { entry in
            ExtraLargeHabitWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Habit Dashboard")
        .description("Comprehensive view of all your habits with progress tracking")
        .supportedFamilies([.systemExtraLarge])
    }
}

struct ExtraLargeHabitProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> ExtraLargeHabitEntry {
        ExtraLargeHabitEntry(
            date: Date(),
            habits: generatePlaceholderHabits(),
            weeklyStats: generatePlaceholderWeeklyStats()
        )
    }

    func snapshot(for configuration: HabitConfigurationIntent, in context: Context) async
        -> ExtraLargeHabitEntry
    {
        let habits = HabitDataManager.shared.loadHabits()
        let weeklyStats = calculateWeeklyStats(for: habits)

        return ExtraLargeHabitEntry(date: Date(), habits: habits, weeklyStats: weeklyStats)
    }

    func timeline(for configuration: HabitConfigurationIntent, in context: Context) async
        -> Timeline<ExtraLargeHabitEntry>
    {
        let habits = HabitDataManager.shared.loadHabits()
        let weeklyStats = calculateWeeklyStats(for: habits)

        let currentDate = Date()
        let entry = ExtraLargeHabitEntry(
            date: currentDate, habits: habits, weeklyStats: weeklyStats)

        // Update every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }

    private func generatePlaceholderHabits() -> [Habit] {
        return [
            Habit(
                id: "1",
                habitName: "Drink Water",
                habitDescription: "Stay hydrated",
                emoji: "💧",
                dailyTarget: 1,
                colorCode: 0x4A90E2,
                status: .active,
                categoryIds: [],
                difficulty: .easy,
                completions: [:]
            ),
            Habit(
                id: "2",
                habitName: "Exercise",
                habitDescription: "Daily workout",
                emoji: "🏃‍♂️",
                dailyTarget: 1,
                colorCode: 0x50C878,
                status: .active,
                categoryIds: [],
                difficulty: .moderate,
                completions: [:]
            ),
            Habit(
                id: "3",
                habitName: "Meditation",
                habitDescription: "Mindfulness practice",
                emoji: "🧘‍♀️",
                dailyTarget: 1,
                colorCode: 0x9B59B6,
                status: .active,
                categoryIds: [],
                difficulty: .moderate,
                completions: [:]
            ),
            Habit(
                id: "4",
                habitName: "Read a Book",
                habitDescription: "Read at least 20 pages of a book each day",
                emoji: "📚",
                dailyTarget: 1,
                colorCode: 0xFF6B6B,
                status: .active,
                categoryIds: [],
                difficulty: .easy,
                completions: [:]
            ),
        ]
    }

    private func generatePlaceholderWeeklyStats() -> WeeklyStats {
        return WeeklyStats(
            totalHabits: 3,
            completedToday: 2,
            weeklyCompletionRate: 0.75,
            longestStreak: 15,
            totalCompletions: 18
        )
    }

    private func calculateWeeklyStats(for habits: [Habit]) -> WeeklyStats {
        let totalHabits = habits.count
        let completedToday = habits.filter { $0.isCompletedToday }.count
        let weeklyCompletionRate =
            habits.isEmpty ? 0.0 : Double(completedToday) / Double(totalHabits)
        let longestStreak = habits.map { $0.currentStreak }.max() ?? 0
        let totalCompletions = habits.reduce(0) { $0 + $1.completions.count }

        return WeeklyStats(
            totalHabits: totalHabits,
            completedToday: completedToday,
            weeklyCompletionRate: weeklyCompletionRate,
            longestStreak: longestStreak,
            totalCompletions: totalCompletions
        )
    }
}

struct ExtraLargeHabitEntry: TimelineEntry {
    let date: Date
    let habits: [Habit]
    let weeklyStats: WeeklyStats
}

struct WeeklyStats {
    let totalHabits: Int
    let completedToday: Int
    let weeklyCompletionRate: Double
    let longestStreak: Int
    let totalCompletions: Int
}

struct ExtraLargeHabitWidgetEntryView: View {
    var entry: ExtraLargeHabitProvider.Entry

    private var primaryHabitColor: Color {
        guard let firstHabit = entry.habits.first else { return .blue }
        return Color(hex: firstHabit.colorCode)
    }

    var body: some View {
        VStack(spacing: 16) {
            // Header with stats
            VStack(spacing: 12) {
                HStack {
                    Text("Habit Dashboard")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)

                    Spacer()

                    Text("Today")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(primaryHabitColor.opacity(0.1))
                        )
                }

                // Stats grid
                HStack(spacing: 16) {
                    StatCard(
                        title: "Completed",
                        value:
                            "\(entry.weeklyStats.completedToday)/\(entry.weeklyStats.totalHabits)",
                        icon: "checkmark.circle.fill",
                        color: primaryHabitColor
                    )

                    StatCard(
                        title: "Streak",
                        value: "\(entry.weeklyStats.longestStreak)",
                        icon: "flame.fill",
                        color: primaryHabitColor
                    )

                    StatCard(
                        title: "Rate",
                        value: "\(Int(entry.weeklyStats.weeklyCompletionRate * 100))%",
                        icon: "chart.bar.fill",
                        color: primaryHabitColor
                    )
                }
            }

            // Habits list
            VStack(spacing: 8) {
                ForEach(entry.habits.prefix(4)) { habit in
                    HabitRowView(habit: habit)
                }

                if entry.habits.count > 4 {
                    HStack {
                        Text("+ \(entry.habits.count - 4) more habits")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.top, 4)
                }
            }
        }
        .padding(16)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)

            Text(title)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.1))
        )
    }
}

struct HabitRowView: View {
    let habit: Habit

    private var habitColor: Color {
        Color(hex: habit.colorCode)
    }

    private var completionRatio: Double {
        let count = habit.completionCountToday
        let target = habit.dailyTarget
        return target > 0 ? min(Double(count) / Double(target), 1.0) : 0.0
    }

    var body: some View {
        HStack(spacing: 12) {
            // Emoji circle
            ZStack {
                Circle()
                    .fill(habitColor.opacity(0.12))
                    .overlay(
                        Circle()
                            .stroke(habitColor.opacity(0.25), lineWidth: 1)
                    )
                    .frame(width: 24, height: 24)

                Text(habit.emoji ?? "🎯")
                    .font(.system(size: 12))
            }

            // Habit info
            VStack(alignment: .leading, spacing: 2) {
                Text(habit.habitName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                HStack(spacing: 8) {
                    // Streak
                    HStack(spacing: 2) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 8))
                            .foregroundColor(habitColor)
                        Text("\(habit.currentStreak)")
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(.primary)
                    }

                    // Progress
                    if habit.dailyTarget > 1 {
                        HStack(spacing: 2) {
                            Image(systemName: "target")
                                .font(.system(size: 8))
                                .foregroundColor(habitColor)
                            Text("\(habit.completionCountToday)/\(habit.dailyTarget)")
                                .font(.system(size: 8, weight: .medium))
                                .foregroundColor(.primary)
                        }
                    }
                }
            }

            Spacer()

            // Completion button
            Button(intent: CompleteHabitIntent(habitId: habit.id)) {
                ZStack {
                    if completionRatio >= 1.0 {
                        // Completed state
                        Circle()
                            .fill(habitColor)
                            .frame(width: 20, height: 20)
                            .shadow(color: habitColor.opacity(0.3), radius: 2, x: 0, y: 1)

                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        // Incomplete state
                        Circle()
                            .fill(habitColor.opacity(0.12 + 0.88 * completionRatio))
                            .overlay(
                                Circle()
                                    .stroke(habitColor.opacity(0.6), lineWidth: 1.5)
                            )
                            .frame(width: 20, height: 20)

                        Image(systemName: "circle")
                            .font(.system(size: 10))
                            .foregroundColor(.clear)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 4)
    }
}

#Preview(as: .systemExtraLarge) {
    ExtraLargeHabitWidget()
} timeline: {
    ExtraLargeHabitEntry(
        date: .now,
        habits: [],
        weeklyStats: WeeklyStats(
            totalHabits: 3,
            completedToday: 2,
            weeklyCompletionRate: 0.75,
            longestStreak: 15,
            totalCompletions: 18
        )
    )
}
