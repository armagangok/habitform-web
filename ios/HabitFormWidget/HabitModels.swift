//
//  HabitModels.swift
//  HabitFormWidget
//
//  Created by Armagan Gok on 4.10.2025.
//

import Foundation
import SwiftUI
import WidgetKit

// MARK: - Habit Models
struct Habit: Codable, Identifiable {
    let id: String
    let habitName: String
    let habitDescription: String?
    let emoji: String?
    let dailyTarget: Int
    let colorCode: Int
    let completions: [String: CompletionEntry]
    let archiveDate: String?  // ISO 8601 string, not Date
    let status: HabitStatus
    let categoryIds: [String]
    let difficulty: HabitDifficulty

    // Flutter-provided calculated values
    let flutterProbabilityScore: Double?
    let flutterLongestStreak: Int?
    let flutterCurrentStreak: Int?
    let flutterCompletedDays: Int?
    let flutterTotalDays: Int?

    var isCompletedToday: Bool {
        // Use normalized date for consistency
        let today = Calendar.current.startOfDay(for: Date())
        let dateKey = DateFormatter.habitDateKey.string(from: today)
        return completions[dateKey]?.isCompleted ?? false
    }

    var currentStreak: Int {
        var streak = 0
        let calendar = Calendar.current
        var currentDate = Calendar.current.startOfDay(for: Date())

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
        // Use normalized date for consistency
        let today = Calendar.current.startOfDay(for: Date())
        let dateKey = DateFormatter.habitDateKey.string(from: today)
        return completions[dateKey]?.count ?? 0
    }

    var longestStreak: Int {
        // Use Flutter-provided value if available, otherwise fallback to local calculation
        if let flutterValue = flutterLongestStreak {
            return flutterValue
        }

        // Fallback to local calculation
        var maxStreak = 0
        var currentStreak = 0
        let sortedDates = completions.keys.sorted()

        for dateKey in sortedDates {
            if let completion = completions[dateKey], completion.isCompleted {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 0
            }
        }

        return maxStreak
    }

    var probabilityScore: Double {
        // Use Flutter-provided value if available, otherwise return 0
        return flutterProbabilityScore ?? 0.0
    }

    // Computed properties for Flutter-provided data
    var currentStreakFromFlutter: Int {
        return flutterCurrentStreak ?? currentStreak
    }

    var completedDaysFromFlutter: Int {
        return flutterCompletedDays ?? completions.values.filter { $0.isCompleted }.count
    }

    var totalDaysFromFlutter: Int {
        return flutterTotalDays ?? completions.count
    }
}

struct CompletionEntry: Codable {
    let id: String
    let date: String  // ISO 8601 string, not Date
    let isCompleted: Bool
    let count: Int

    // Computed property to get Date from string when needed
    var dateValue: Date {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: date) ?? Date()
    }
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

    // Debug method to test App Group access
    func testAppGroupAccess() {
        print("🧪 Testing App Group access...")
        guard
            let containerURL = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: appGroupIdentifier
            )
        else {
            print("❌ Failed to get App Group container URL")
            return
        }

        print("📁 App Group container URL: \(containerURL.path)")

        let habitsURL = containerURL.appendingPathComponent("habits.json")
        print("📄 Looking for habits.json at: \(habitsURL.path)")

        let fileExists = FileManager.default.fileExists(atPath: habitsURL.path)
        print("📄 File exists: \(fileExists)")

        if fileExists {
            do {
                let data = try Data(contentsOf: habitsURL)
                print("📊 File size: \(data.count) bytes")

                let habits = try JSONDecoder().decode([Habit].self, from: data)
                print("📋 Decoded \(habits.count) habits")

                for habit in habits {
                    print("  - \(habit.habitName) (\(habit.id)) - Status: \(habit.status)")
                }
            } catch {
                print("❌ Error reading file: \(error)")
            }
        }
    }

    func loadHabits() -> [Habit] {
        print("🔍 HabitDataManager: Starting to load habits at \(Date())")

        guard
            let containerURL = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: appGroupIdentifier)
        else {
            print(
                "❌ HabitDataManager: Failed to get app group container URL for identifier: \(appGroupIdentifier)"
            )
            return []
        }

        print("📁 HabitDataManager: Container URL: \(containerURL.path)")
        let habitsURL = containerURL.appendingPathComponent("habits.json")
        print("📄 HabitDataManager: Looking for habits.json at: \(habitsURL.path)")

        do {
            // Check if file exists
            guard FileManager.default.fileExists(atPath: habitsURL.path) else {
                print("❌ HabitDataManager: No habits.json file found in App Group container")

                // List all files in the container to debug
                let fileManager = FileManager.default
                do {
                    let contents = try fileManager.contentsOfDirectory(atPath: containerURL.path)
                    print("📁 HabitDataManager: Container contents: \(contents)")

                    // Check for other habit files
                    for file in contents {
                        if file.contains("habit") {
                            let fileURL = containerURL.appendingPathComponent(file)
                            print(
                                "📄 HabitDataManager: Found habit-related file: \(file) at \(fileURL.path)"
                            )
                        }
                    }
                } catch {
                    print("❌ HabitDataManager: Error listing container contents: \(error)")
                }

                return []
            }

            // Get file attributes
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: habitsURL.path)
            if let modificationDate = fileAttributes[.modificationDate] as? Date {
                print("📅 HabitDataManager: habits.json last modified: \(modificationDate)")
            }
            if let fileSize = fileAttributes[.size] as? Int {
                print("📊 HabitDataManager: habits.json file size: \(fileSize) bytes")
            }

            print("✅ HabitDataManager: habits.json file exists, reading data...")
            let data = try Data(contentsOf: habitsURL)
            print("📊 HabitDataManager: Read \(data.count) bytes from habits.json")

            // Print raw JSON for debugging (truncated if too long)
            if let jsonString = String(data: data, encoding: .utf8) {
                if jsonString.count > 1000 {
                    let truncated = String(jsonString.prefix(1000)) + "..."
                    print("📄 HabitDataManager: Raw JSON (truncated): \(truncated)")
                } else {
                    print("📄 HabitDataManager: Raw JSON: \(jsonString)")
                }
            }

            // Check if data is empty
            if data.isEmpty {
                print("❌ HabitDataManager: habits.json file is empty")
                return []
            }

            let habits = try JSONDecoder().decode([Habit].self, from: data)
            print("📋 HabitDataManager: Decoded \(habits.count) total habits")

            // Debug each habit's ID and name
            for (index, habit) in habits.enumerated() {
                print(
                    "🔍 HabitDataManager: Habit \(index + 1) - ID: '\(habit.id)', Name: '\(habit.habitName)', Status: \(habit.status), Completions: \(habit.completions.count)"
                )
            }

            let activeHabits = habits.filter { $0.status == .active }
            print(
                "✅ HabitDataManager: Loaded \(activeHabits.count) active habits from App Group container"
            )

            for (index, habit) in activeHabits.enumerated() {
                print(
                    "  \(index + 1). \(habit.habitName) (\(habit.id)) - \(habit.completions.count) completions"
                )
            }

            if activeHabits.isEmpty {
                print(
                    "⚠️ HabitDataManager: No active habits found! This will cause widgets to show 'No Habits'"
                )
            }

            return activeHabits
        } catch {
            print("❌ HabitDataManager: Error loading habits: \(error)")
            print("❌ HabitDataManager: Error details: \(error.localizedDescription)")

            // Try to read the file as string to see what's wrong
            do {
                let data = try Data(contentsOf: habitsURL)
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📄 HabitDataManager: Failed to parse JSON: \(jsonString)")
                }
            } catch {
                print("❌ HabitDataManager: Could not even read file as string: \(error)")
            }

            return []
        }
    }

    func completeHabit(_ habitId: String) {
        print("🔄 HabitDataManager: Starting habit completion for ID: '\(habitId)'")

        guard
            let containerURL = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: appGroupIdentifier)
        else {
            print("❌ HabitDataManager: Failed to get app group container URL")
            return
        }

        let habitsURL = containerURL.appendingPathComponent("habits.json")

        do {
            // Check if file exists
            guard FileManager.default.fileExists(atPath: habitsURL.path) else {
                print("❌ HabitDataManager: No habits.json file found - cannot complete habit")
                return
            }

            let data = try Data(contentsOf: habitsURL)
            guard !data.isEmpty else {
                print("❌ HabitDataManager: habits.json file is empty")
                return
            }

            var habits = try JSONDecoder().decode([Habit].self, from: data)
            print("📋 HabitDataManager: Loaded \(habits.count) habits for completion")

            if let index = habits.firstIndex(where: { $0.id == habitId }) {
                let habit = habits[index]
                // Use normalized date for consistency
                let today = Calendar.current.startOfDay(for: Date())
                let dateKey = DateFormatter.habitDateKey.string(from: today)

                print("✅ HabitDataManager: Found habit '\(habit.habitName)' for completion")

                var updatedCompletions = habit.completions
                if let existingCompletion = updatedCompletions[dateKey] {
                    let newCount = min(existingCompletion.count + 1, habit.dailyTarget)
                    updatedCompletions[dateKey] = CompletionEntry(
                        id: existingCompletion.id,
                        date: existingCompletion.date,
                        isCompleted: newCount >= habit.dailyTarget,
                        count: newCount
                    )
                    print(
                        "📊 HabitDataManager: Updated existing completion - count: \(newCount), completed: \(newCount >= habit.dailyTarget)"
                    )
                } else {
                    updatedCompletions[dateKey] = CompletionEntry(
                        id: UUID().uuidString,
                        date: ISO8601DateFormatter().string(from: today),
                        isCompleted: habit.dailyTarget == 1,
                        count: 1
                    )
                    print(
                        "📊 HabitDataManager: Created new completion - count: 1, completed: \(habit.dailyTarget == 1)"
                    )
                }

                let updatedHabit = Habit(
                    id: habit.id,
                    habitName: habit.habitName,
                    habitDescription: habit.habitDescription,
                    emoji: habit.emoji,
                    dailyTarget: habit.dailyTarget,
                    colorCode: habit.colorCode,
                    completions: updatedCompletions,
                    archiveDate: habit.archiveDate,
                    status: habit.status,
                    categoryIds: habit.categoryIds,
                    difficulty: habit.difficulty,
                    flutterProbabilityScore: habit.flutterProbabilityScore,
                    flutterLongestStreak: habit.flutterLongestStreak,
                    flutterCurrentStreak: habit.flutterCurrentStreak,
                    flutterCompletedDays: habit.flutterCompletedDays,
                    flutterTotalDays: habit.flutterTotalDays
                )

                habits[index] = updatedHabit

                let data = try JSONEncoder().encode(habits)
                try data.write(to: habitsURL)
                print("✅ HabitDataManager: Successfully completed habit: \(habitId)")

                // Reload widget timelines after completing habit
                if #available(iOS 14.0, *) {
                    WidgetCenter.shared.reloadAllTimelines()
                    print(
                        "🔄 HabitDataManager: Reloaded all widget timelines after habit completion")
                }
            } else {
                print("❌ HabitDataManager: Habit not found: \(habitId)")
                print("📋 HabitDataManager: Available habit IDs: \(habits.map { $0.id })")
            }
        } catch {
            print("❌ HabitDataManager: Error completing habit: \(error)")
        }
    }

    func getHabitCompletionData(for habitId: String, days: Int = 7) -> [Date: Bool] {
        let habits = loadHabits()

        guard let habit = habits.first(where: { $0.id == habitId }) else {
            return [:]
        }

        var completionData: [Date: Bool] = [:]
        let calendar = Calendar.current

        for i in 0..<days {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                // Normalize the date to start of day for consistent dictionary keys
                let normalizedDate = calendar.startOfDay(for: date)
                let dateKey = DateFormatter.habitDateKey.string(from: normalizedDate)
                let isCompleted = habit.completions[dateKey]?.isCompleted ?? false
                completionData[normalizedDate] = isCompleted
            }
        }

        return completionData
    }

    func updateHabitCompletion(habitId: String, date: Date, isCompleted: Bool, count: Int) {
        guard
            let containerURL = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: appGroupIdentifier)
        else {
            print("Failed to get app group container URL")
            return
        }

        let habitsURL = containerURL.appendingPathComponent("habits.json")

        do {
            // Check if file exists
            guard FileManager.default.fileExists(atPath: habitsURL.path) else {
                print("No habits.json file found - cannot update habit completion")
                return
            }

            var habits = try JSONDecoder().decode([Habit].self, from: Data(contentsOf: habitsURL))

            if let index = habits.firstIndex(where: { $0.id == habitId }) {
                let habit = habits[index]
                // Normalize the date to start of day for consistent storage
                let normalizedDate = Calendar.current.startOfDay(for: date)
                let dateKey = DateFormatter.habitDateKey.string(from: normalizedDate)

                var updatedCompletions = habit.completions
                updatedCompletions[dateKey] = CompletionEntry(
                    id: "\(habitId)_\(dateKey)",
                    date: ISO8601DateFormatter().string(from: date),
                    isCompleted: isCompleted,
                    count: count
                )

                let updatedHabit = Habit(
                    id: habit.id,
                    habitName: habit.habitName,
                    habitDescription: habit.habitDescription,
                    emoji: habit.emoji,
                    dailyTarget: habit.dailyTarget,
                    colorCode: habit.colorCode,
                    completions: updatedCompletions,
                    archiveDate: habit.archiveDate,
                    status: habit.status,
                    categoryIds: habit.categoryIds,
                    difficulty: habit.difficulty,
                    flutterProbabilityScore: habit.flutterProbabilityScore,
                    flutterLongestStreak: habit.flutterLongestStreak,
                    flutterCurrentStreak: habit.flutterCurrentStreak,
                    flutterCompletedDays: habit.flutterCompletedDays,
                    flutterTotalDays: habit.flutterTotalDays
                )

                habits[index] = updatedHabit

                let data = try JSONEncoder().encode(habits)
                try data.write(to: habitsURL)
                print("Successfully updated habit completion: \(habitId)")

                // Reload widget timelines after updating completion
                if #available(iOS 14.0, *) {
                    WidgetCenter.shared.reloadAllTimelines()
                    print(
                        "🔄 HabitDataManager: Reloaded all widget timelines after completion update")
                }
            } else {
                print("Habit not found: \(habitId)")
            }
        } catch {
            print("Error updating habit completion: \(error)")
        }
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
