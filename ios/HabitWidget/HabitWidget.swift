//
//  HabitWidgetComplete.swift
//  HabitWidget
//
//  Created by Armagan Gok on 2.10.2025.
//

import AppIntents
import Foundation
import SwiftUI
import WidgetKit

// MARK: - Habit Data Models
struct HabitData: Codable {
    let id: String
    let name: String
    let emoji: String?
    let colorCode: Int
    let dailyTarget: Int
    let completions: [String: CompletionData]
    let difficulty: String
    let status: String

    var isCompletedToday: Bool {
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayString = formatter.string(from: today)

        return completions[todayString]?.isCompleted ?? false
    }

    var currentStreak: Int {
        calculateCurrentStreak()
    }

    var completionCountToday: Int {
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayString = formatter.string(from: today)

        return completions[todayString]?.count ?? 0
    }

    private func calculateCurrentStreak() -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        // Get all completed dates sorted in descending order
        let completedDates = completions.compactMap { (key, value) -> Date? in
            guard value.isCompleted else { return nil }
            return formatter.date(from: key)
        }.sorted { $0 > $1 }

        guard !completedDates.isEmpty else { return 0 }

        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        // Check if streak is still active (last completion was today or yesterday)
        let lastCompletion = completedDates.first!
        if !calendar.isDate(lastCompletion, inSameDayAs: today)
            && !calendar.isDate(lastCompletion, inSameDayAs: yesterday)
        {
            return 0
        }

        var streak = 1
        var currentDate = lastCompletion

        // Count consecutive days backwards
        for i in 1..<completedDates.count {
            let previousDate = completedDates[i]
            let expectedDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!

            if calendar.isDate(previousDate, inSameDayAs: expectedDate) {
                streak += 1
                currentDate = previousDate
            } else {
                break
            }
        }

        return streak
    }
}

struct CompletionData: Codable {
    let id: String
    let date: String
    let isCompleted: Bool
    let count: Int
}

// MARK: - Widget Data Manager
class WidgetDataManager {
    static let shared = WidgetDataManager()

    private let appGroupIdentifier = "group.com.AppSweat.HabitFormWidget"
    private let habitsFileName = "widget_habits.json"

    private init() {}

    func getHabits() -> [HabitData] {
        guard
            let containerURL = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: appGroupIdentifier)
        else {
            print("Failed to get container URL")
            return []
        }

        let fileURL = containerURL.appendingPathComponent(habitsFileName)

        do {
            let data = try Data(contentsOf: fileURL)
            let habits = try JSONDecoder().decode([HabitData].self, from: data)
            return habits.filter { $0.status == "active" }
        } catch {
            print("Error reading habits: \(error)")
            return []
        }
    }

    func updateHabitCompletion(habitId: String, isCompleted: Bool) {
        guard
            let containerURL = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: appGroupIdentifier)
        else {
            print("Failed to get container URL")
            return
        }

        let fileURL = containerURL.appendingPathComponent(habitsFileName)

        do {
            let data = try Data(contentsOf: fileURL)
            var habits = try JSONDecoder().decode([HabitData].self, from: data)

            // Find and update the habit
            if let index = habits.firstIndex(where: { $0.id == habitId }) {
                let habit = habits[index]
                let today = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                let todayString = formatter.string(from: today)

                var completions = habit.completions
                let currentCount = completions[todayString]?.count ?? 0
                let target = habit.dailyTarget

                let newCount: Int
                if isCompleted {
                    newCount = min(currentCount + 1, target)
                } else {
                    newCount = max(currentCount - 1, 0)
                }

                let newCompletion = CompletionData(
                    id: todayString,
                    date: todayString,
                    isCompleted: newCount >= target,
                    count: newCount
                )

                completions[todayString] = newCompletion

                // Create updated habit
                let updatedHabit = HabitData(
                    id: habit.id,
                    name: habit.name,
                    emoji: habit.emoji,
                    colorCode: habit.colorCode,
                    dailyTarget: habit.dailyTarget,
                    completions: completions,
                    difficulty: habit.difficulty,
                    status: habit.status
                )

                habits[index] = updatedHabit

                // Save back to file
                let updatedData = try JSONEncoder().encode(habits)
                try updatedData.write(to: fileURL)

                print("Updated habit completion for \(habitId)")
            }
        } catch {
            print("Error updating habit completion: \(error)")
        }
    }
}

// MARK: - App Intents
struct CompleteHabitIntent: AppIntent {
    static var title: LocalizedStringResource = "Complete Habit"
    static var description = IntentDescription("Mark a habit as completed")

    @Parameter(title: "Habit ID")
    var habitId: String

    init(habitId: String) {
        self.habitId = habitId
    }

    init() {
        self.habitId = ""
    }

    func perform() async throws -> some IntentResult {
        WidgetDataManager.shared.updateHabitCompletion(habitId: habitId, isCompleted: true)

        // Reload widget timeline
        WidgetCenter.shared.reloadAllTimelines()

        return .result()
    }
}

struct UncompleteHabitIntent: AppIntent {
    static var title: LocalizedStringResource = "Uncomplete Habit"
    static var description = IntentDescription("Mark a habit as not completed")

    @Parameter(title: "Habit ID")
    var habitId: String

    init(habitId: String) {
        self.habitId = habitId
    }

    init() {
        self.habitId = ""
    }

    func perform() async throws -> some IntentResult {
        WidgetDataManager.shared.updateHabitCompletion(habitId: habitId, isCompleted: false)

        // Reload widget timeline
        WidgetCenter.shared.reloadAllTimelines()

        return .result()
    }
}

// MARK: - Timeline Provider
struct HabitWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> HabitWidgetEntry {
        HabitWidgetEntry(date: Date(), habits: getSampleHabits())
    }

    func getSnapshot(in context: Context, completion: @escaping (HabitWidgetEntry) -> Void) {
        let entry = HabitWidgetEntry(date: Date(), habits: getSampleHabits())
        completion(entry)
    }

    func getTimeline(
        in context: Context, completion: @escaping (Timeline<HabitWidgetEntry>) -> Void
    ) {
        let currentDate = Date()
        let habits = WidgetDataManager.shared.getHabits()

        let entry = HabitWidgetEntry(date: currentDate, habits: habits)

        // Update every 30 minutes
        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))

        completion(timeline)
    }

    private func getSampleHabits() -> [HabitData] {
        return [
            HabitData(
                id: "sample-1",
                name: "Morning Exercise",
                emoji: "🏃‍♂️",
                colorCode: 0xFF4C_AF50,
                dailyTarget: 1,
                completions: [:],
                difficulty: "moderate",
                status: "active"
            )
        ]
    }
}

// MARK: - Timeline Entry
struct HabitWidgetEntry: TimelineEntry {
    let date: Date
    let habits: [HabitData]
}

// MARK: - Small Widget View
struct SmallHabitWidgetView: View {
    var entry: HabitWidgetEntry

    var body: some View {
        VStack(spacing: 8) {
            if let firstHabit = entry.habits.first {
                // Habit emoji and name
                HStack {
                    Text(firstHabit.emoji ?? "📝")
                        .font(.title2)
                    Text(firstHabit.name)
                        .font(.caption)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    Spacer()
                }

                // Streak display
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                    Text("\(firstHabit.currentStreak)")
                        .font(.caption)
                        .fontWeight(.bold)
                    Spacer()
                }

                // Completion button
                if firstHabit.isCompletedToday {
                    Button(intent: UncompleteHabitIntent(habitId: firstHabit.id)) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Done")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    Button(intent: CompleteHabitIntent(habitId: firstHabit.id)) {
                        HStack {
                            Image(systemName: "circle")
                                .foregroundColor(.gray)
                            Text("Complete")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            } else {
                // No habits available
                VStack(spacing: 8) {
                    Image(systemName: "plus.circle")
                        .font(.title2)
                        .foregroundColor(.gray)

                    Text("No habits")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Text("Add habits in the app")
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding(12)
    }
}

// MARK: - Main Widget
struct HabitWidget: Widget {
    let kind: String = "HabitWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HabitWidgetProvider()) { entry in
            if #available(iOS 17.0, *) {
                SmallHabitWidgetView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                SmallHabitWidgetView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Habit Tracker")
        .description("Track your daily habits and streaks.")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Widget Bundle
struct HabitWidgetBundle: WidgetBundle {
    var body: some Widget {
        HabitWidget()
    }
}

// MARK: - Preview
#Preview(as: .systemSmall) {
    HabitWidget()
} timeline: {
    HabitWidgetEntry(
        date: Date(),
        habits: [
            HabitData(
                id: "sample-1",
                name: "Morning Exercise",
                emoji: "🏃‍♂️",
                colorCode: 0xFF4C_AF50,
                dailyTarget: 1,
                completions: [:],
                difficulty: "moderate",
                status: "active"
            )
        ])

    HabitWidgetEntry(date: Date(), habits: [])
}
