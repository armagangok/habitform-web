//
//  CompleteHabitIntent.swift
//  HabitFormWidget
//
//  Created by Armagan Gok on 4.10.2025.
//

import AppIntents
import Foundation
import SwiftUI
import WidgetKit

enum IntentError: Error {
    case invalidHabitId
    case habitNotFound
}

struct CompleteHabitIntent: AppIntent {
    static var title: LocalizedStringResource = "Complete Habit"
    static var description = IntentDescription("Mark a habit as completed for today")

    @Parameter(title: "Habit ID")
    var habitId: String

    init() {}

    init(habitId: String) {
        self.habitId = habitId
    }

    func perform() async throws -> some IntentResult {
        print("🔄 CompleteHabitIntent: Starting completion for habit ID: '\(habitId)'")

        // Validate habit ID
        guard !habitId.isEmpty && habitId != "empty" else {
            print("❌ CompleteHabitIntent: Invalid habit ID: '\(habitId)'")
            throw IntentError.invalidHabitId
        }

        // Complete the habit locally and write to shared file
        await completeHabitAndNotify()

        // Reload all widget timelines
        WidgetCenter.shared.reloadAllTimelines()

        print("✅ CompleteHabitIntent: Successfully completed habit: '\(habitId)'")
        return .result()
    }

    private func completeHabitAndNotify() async {
        print("🔄 CompleteHabitIntent: Completing habit locally...")

        // Complete the habit locally
        HabitDataManager.shared.completeHabit(habitId)

        // Write completion update to shared file for Flutter to pick up
        let today = Date()
        writeCompletionUpdate(habitId: habitId, date: today, isCompleted: true, count: 1)

        print("✅ CompleteHabitIntent: Habit completion and notification completed")
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

        } catch {
            print("Error writing completion update: \(error)")
        }
    }
}
