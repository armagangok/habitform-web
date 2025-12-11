//
//  CompleteHabitForDateIntent.swift
//  HabitFormWidget
//
//  Created by Armagan Gok on 4.10.2025.
//

import AppIntents
import Foundation
import SwiftUI
import WidgetKit

struct CompleteHabitForDateIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Habit for Date"
    static var description = IntentDescription("Toggle habit completion for a specific date")

    @Parameter(title: "Habit ID")
    var habitId: String

    @Parameter(title: "Date")
    var date: Date

    init() {}

    init(habitId: String, date: Date) {
        self.habitId = habitId
        self.date = date
    }

    func perform() async throws -> some IntentResult {
        print(
            "🔄 CompleteHabitForDateIntent: Starting toggle for habit ID: '\(habitId)' on date: \(date)"
        )

        // Validate habit ID
        guard !habitId.isEmpty && habitId != "empty" else {
            print("❌ CompleteHabitForDateIntent: Invalid habit ID: '\(habitId)'")
            throw IntentError.invalidHabitId
        }

        // Check if habit is already completed for this date
        let habits = HabitDataManager.shared.loadHabits()
        guard let habit = habits.first(where: { $0.id == habitId }) else {
            print("❌ CompleteHabitForDateIntent: Habit not found: '\(habitId)'")
            throw IntentError.habitNotFound
        }

        // Normalize the date to start of day for consistent storage
        let normalizedDate = Calendar.current.startOfDay(for: date)
        let dateKey = DateFormatter.habitDateKey.string(from: normalizedDate)
        let isCurrentlyCompleted = habit.completions[dateKey]?.isCompleted ?? false
        print(
            "📊 CompleteHabitForDateIntent: Habit '\(habitId)' is currently completed for \(dateKey): \(isCurrentlyCompleted)"
        )

        // Toggle the habit completion for this specific date
        await toggleHabitForDateAndNotify(isCurrentlyCompleted: isCurrentlyCompleted)

        // Reload all widget timelines
        WidgetCenter.shared.reloadAllTimelines()

        let action = isCurrentlyCompleted ? "uncompleted" : "completed"
        print(
            "✅ CompleteHabitForDateIntent: Successfully \(action) habit: '\(habitId)' for date: \(dateKey)"
        )
        return .result()
    }

    private func toggleHabitForDateAndNotify(isCurrentlyCompleted: Bool) async {
        print("🔄 CompleteHabitForDateIntent: Toggling habit for specific date...")

        // Use the normalized date for consistency
        let normalizedDate = Calendar.current.startOfDay(for: date)

        if isCurrentlyCompleted {
            // Uncomplete the habit for this date
            print("🔄 CompleteHabitForDateIntent: Uncompleting habit for date...")
            HabitDataManager.shared.updateHabitCompletion(
                habitId: habitId, date: normalizedDate, isCompleted: false, count: 0)
            writeCompletionUpdate(
                habitId: habitId, date: normalizedDate, isCompleted: false, count: 0)
        } else {
            // Complete the habit for this date
            print("🔄 CompleteHabitForDateIntent: Completing habit for date...")
            HabitDataManager.shared.updateHabitCompletion(
                habitId: habitId, date: normalizedDate, isCompleted: true, count: 1)
            writeCompletionUpdate(
                habitId: habitId, date: normalizedDate, isCompleted: true, count: 1)
        }

        print("✅ CompleteHabitForDateIntent: Habit toggle for date and notification completed")
    }

    private func writeCompletionUpdate(habitId: String, date: Date, isCompleted: Bool, count: Int) {
        guard
            let containerURL = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: "group.com.AppSweat.HabitFormWidget")
        else {
            print("Failed to get app group container URL")
            return
        }

        let updatesURL = containerURL.appendingPathComponent("completion_updates.json")

        do {
            // Read existing updates
            var updates: [[String: Any]] = []
            if FileManager.default.fileExists(atPath: updatesURL.path) {
                let data = try Data(contentsOf: updatesURL)
                updates = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] ?? []
            }

            // Add new update
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let update: [String: Any] = [
                "habitId": habitId,
                "completion": [
                    "id": "\(habitId)_\(formatter.string(from: date))",
                    "date": formatter.string(from: date),
                    "isCompleted": isCompleted,
                    "count": count,
                ],
                "timestamp": ISO8601DateFormatter().string(from: Date()),
            ]

            updates.append(update)

            // Keep only last 100 updates
            if updates.count > 100 {
                updates = Array(updates.suffix(100))
            }

            // Write back to file
            let data = try JSONSerialization.data(withJSONObject: updates)
            try data.write(to: updatesURL)

            print(
                "📝 CompleteHabitForDateIntent: Written completion update - habitId: \(habitId), date: \(formatter.string(from: date)), isCompleted: \(isCompleted), count: \(count)"
            )

        } catch {
            print("Error writing completion update: \(error)")
        }
    }
}
