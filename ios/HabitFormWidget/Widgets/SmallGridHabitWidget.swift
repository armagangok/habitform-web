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
                SmallGridHabitWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            }
        }
        .configurationDisplayName(WidgetLocalization.getLocalizedString(for: "widget.grid.title"))
        .description(WidgetLocalization.getLocalizedString(for: "widget.grid.description"))
        .supportedFamilies([.systemSmall])
    }
}

struct SmallGridHabitProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SmallGridHabitEntry {
        SmallGridHabitEntry(
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

        return dates  // Most recent to oldest (today first)
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Header with emoji and name
                Spacer()
                HStack {
                    // Habit name - now has maximum space
                    Text(entry.habit.habitName)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.primary)
                        .lineLimit(3)
                        .minimumScaleFactor(0.7)

                    Spacer()
                    // Emoji circle (tappable) — shows completed state as filled color
                    Button(intent: CompleteHabitIntent(habitId: entry.habit.id)) {
                        let isCompletedToday = (completionRatio >= 1.0)
                        ZStack {
                            Circle()
                                .fill(isCompletedToday ? habitColor : habitColor.opacity(0.12))
                                .overlay(
                                    Circle()
                                        .stroke(
                                            habitColor.opacity(isCompletedToday ? 0.6 : 0.25),
                                            lineWidth: 1)
                                )
                                .frame(width: 32, height: 32)

                            Text(entry.habit.emoji ?? "🎯")
                                .font(.system(size: 16))
                                .foregroundColor(isCompletedToday ? .white : .primary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())

                }

                Spacer()

                // 60-day grid (6 rows x 10 columns) - column-major bottom-to-top order
                VStack(spacing: 2) {
                    ForEach(0..<6, id: \.self) { row in
                        HStack(spacing: 2) {
                            ForEach(0..<10, id: \.self) { col in
                                // Snake mapping per your spec:
                                // Start at bottom-right and go up; next column (moving left) goes down; and so on.
                                // We index dates from most recent (today) to oldest: gridData[0] is today.
                                let totalRows = 6
                                let totalCols = 10
                                let colFromRight = (totalCols - 1 - col)
                                let isUpwards = (colFromRight % 2 == 0)  // even columns from right go bottom→top
                                let offsetWithinColumn = isUpwards ? (totalRows - 1 - row) : row
                                let index = colFromRight * totalRows + offsetWithinColumn

                                if index < gridData.count {
                                    let date = gridData[index]
                                    let dateKey = DateFormatter.habitDateKey.string(from: date)
                                    let completion = entry.habit.completions[dateKey]
                                    let isToday = Calendar.current.isDate(date, inSameDayAs: Date())

                                    // Calculate completion ratio for multi-completion support
                                    let count = completion?.count ?? 0
                                    let target = entry.habit.dailyTarget
                                    let completionRatio =
                                        target > 0 ? min(Double(count) / Double(target), 1.0) : 0.0
                                    let isCompleted = completion?.isCompleted ?? false

                                    Rectangle()
                                        .fill(
                                            isCompleted
                                                ? habitColor.opacity(0.8)  // Fully completed - solid color
                                                : habitColor.opacity(0.2 + 0.6 * completionRatio)  // Progressive color intensity
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
}
