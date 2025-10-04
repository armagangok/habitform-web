//
//  HabitModels.swift
//  HabitFormWidget
//
//  Created by Armagan Gok on 4.10.2025.
//

import Foundation
import SwiftUI

// MARK: - Habit Models
struct Habit: Codable, Identifiable {
    let id: String
    let habitName: String
    let habitDescription: String?
    let emoji: String?
    let dailyTarget: Int
    let colorCode: Int
    let status: HabitStatus
    let categoryIds: [String]
    let difficulty: HabitDifficulty
    let completions: [String: CompletionEntry]

    var isCompletedToday: Bool {
        let today = Date()
        let dateKey = DateFormatter.habitDateKey.string(from: today)
        return completions[dateKey]?.isCompleted ?? false
    }

    var currentStreak: Int {
        var streak = 0
        let calendar = Calendar.current
        var currentDate = Date()

        while true {
            let dateKey = DateFormatter.habitDateKey.string(from: currentDate)
            if let completion = completions[dateKey], completion.isCompleted {
                streak += 1
                currentDate =
                    calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }

        return streak
    }

    var completionCountToday: Int {
        let today = Date()
        let dateKey = DateFormatter.habitDateKey.string(from: today)
        return completions[dateKey]?.count ?? 0
    }
}

struct CompletionEntry: Codable {
    let id: String
    let date: Date
    let isCompleted: Bool
    let count: Int
}

enum HabitStatus: String, Codable, CaseIterable {
    case active = "active"
    case archived = "archived"
}

enum HabitDifficulty: String, Codable, CaseIterable {
    case veryEasy = "veryEasy"
    case easy = "easy"
    case moderate = "moderate"
    case difficult = "difficult"
    case veryDifficult = "veryDifficult"
}

// MARK: - Data Manager
class HabitDataManager {
    static let shared = HabitDataManager()
    private let appGroupIdentifier = "group.com.AppSweat.HabitFormWidget"

    private init() {}

    func loadHabits() -> [Habit] {
        guard
            let containerURL = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: appGroupIdentifier)
        else {
            print("Failed to get app group container URL")
            return createPlaceholderHabits()
        }

        let habitsURL = containerURL.appendingPathComponent("habits.json")

        do {
            // Check if file exists
            guard FileManager.default.fileExists(atPath: habitsURL.path) else {
                return createPlaceholderHabits()
            }

            let data = try Data(contentsOf: habitsURL)
            let habits = try JSONDecoder().decode([Habit].self, from: data)
            return habits.filter { $0.status == .active }
        } catch {
            return createPlaceholderHabits()
        }
    }

    private func createPlaceholderHabits() -> [Habit] {
        let calendar = Calendar.current
        let today = Date()

        // Create realistic completion data for the last 30 days
        var waterCompletions: [String: CompletionEntry] = [:]
        var exerciseCompletions: [String: CompletionEntry] = [:]
        var meditationCompletions: [String: CompletionEntry] = [:]

        // Water - completed most days (25/30)
        for i in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let dateKey = DateFormatter.habitDateKey.string(from: date)
                let isCompleted = i < 25  // 25 days completed
                waterCompletions[dateKey] = CompletionEntry(
                    id: "water-\(i)",
                    date: date,
                    isCompleted: isCompleted,
                    count: isCompleted ? 1 : 0
                )
            }
        }

        // Exercise - good streak (20/30)
        for i in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let dateKey = DateFormatter.habitDateKey.string(from: date)
                let isCompleted = i < 20  // 20 days completed
                exerciseCompletions[dateKey] = CompletionEntry(
                    id: "exercise-\(i)",
                    date: date,
                    isCompleted: isCompleted,
                    count: isCompleted ? 1 : 0
                )
            }
        }

        // Meditation - inconsistent (12/30)
        for i in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let dateKey = DateFormatter.habitDateKey.string(from: date)
                let isCompleted = i % 3 == 0 && i < 15  // Every 3rd day, up to 15 days
                meditationCompletions[dateKey] = CompletionEntry(
                    id: "meditation-\(i)",
                    date: date,
                    isCompleted: isCompleted,
                    count: isCompleted ? 1 : 0
                )
            }
        }

        return [
            Habit(
                id: "water-habit",
                habitName: "Drink Water",
                habitDescription: "Drink at least 8 glasses of water throughout the day",
                emoji: "💧",
                dailyTarget: 1,
                colorCode: 0x4A90E2,
                status: .active,
                categoryIds: [],
                difficulty: .easy,
                completions: waterCompletions
            ),
            Habit(
                id: "exercise-habit",
                habitName: "Calisthenics",
                habitDescription: "Daily workout for 30 minutes",
                emoji: "🏃‍♂️",
                dailyTarget: 1,
                colorCode: 0x50C878,
                status: .active,
                categoryIds: [],
                difficulty: .moderate,
                completions: exerciseCompletions
            ),
            Habit(
                id: "meditation-habit",
                habitName: "Meditasyon",
                habitDescription: "Daily meditation for 10 minutes",
                emoji: "🧘‍♀️",
                dailyTarget: 1,
                colorCode: 0x9B59B6,
                status: .active,
                categoryIds: [],
                difficulty: .moderate,
                completions: meditationCompletions
            ),
            Habit(
                id: "reading-habit",
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
            Habit(
                id: "sleep-habit",
                habitName: "Go to Bed Early",
                habitDescription: "Go to bed before 11:00 PM",
                emoji: "😴",
                dailyTarget: 1,
                colorCode: 0x4ECDC4,
                status: .active,
                categoryIds: [],
                difficulty: .difficult,
                completions: [:]
            ),
        ]
    }

    func completeHabit(_ habitId: String) {
        guard
            let containerURL = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: appGroupIdentifier)
        else {
            return
        }

        let habitsURL = containerURL.appendingPathComponent("habits.json")

        do {
            var habits = try JSONDecoder().decode([Habit].self, from: Data(contentsOf: habitsURL))

            if let index = habits.firstIndex(where: { $0.id == habitId }) {
                let habit = habits[index]
                let today = Date()
                let dateKey = DateFormatter.habitDateKey.string(from: today)

                var updatedCompletions = habit.completions
                if let existingCompletion = updatedCompletions[dateKey] {
                    let newCount = min(existingCompletion.count + 1, habit.dailyTarget)
                    updatedCompletions[dateKey] = CompletionEntry(
                        id: existingCompletion.id,
                        date: existingCompletion.date,
                        isCompleted: newCount >= habit.dailyTarget,
                        count: newCount
                    )
                } else {
                    updatedCompletions[dateKey] = CompletionEntry(
                        id: UUID().uuidString,
                        date: today,
                        isCompleted: habit.dailyTarget == 1,
                        count: 1
                    )
                }

                let updatedHabit = Habit(
                    id: habit.id,
                    habitName: habit.habitName,
                    habitDescription: habit.habitDescription,
                    emoji: habit.emoji,
                    dailyTarget: habit.dailyTarget,
                    colorCode: habit.colorCode,
                    status: habit.status,
                    categoryIds: habit.categoryIds,
                    difficulty: habit.difficulty,
                    completions: updatedCompletions
                )

                habits[index] = updatedHabit

                let data = try JSONEncoder().encode(habits)
                try data.write(to: habitsURL)
            }
        } catch {
            print("Error completing habit: \(error)")
        }
    }

    func getHabitCompletionData(for habitId: String, days: Int = 7) -> [Date: Bool] {
        // Use placeholder data for now
        let habits = createPlaceholderHabits()

        guard let habit = habits.first(where: { $0.id == habitId }) else {
            return [:]
        }

        var completionData: [Date: Bool] = [:]
        let calendar = Calendar.current

        for i in 0..<days {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                let dateKey = DateFormatter.habitDateKey.string(from: date)
                let isCompleted = habit.completions[dateKey]?.isCompleted ?? false
                completionData[date] = isCompleted
            }
        }

        return completionData
    }
}

// MARK: - Extensions
extension DateFormatter {
    static let habitDateKey: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

extension Color {
    init(hex: Int) {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue)
    }
}
