//
//  CompleteHabitIntent.swift
//  HabitFormWidget
//
//  Created by Armagan Gok on 4.10.2025.
//

import AppIntents
import SwiftUI
import WidgetKit

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
        // Complete the habit
        HabitDataManager.shared.completeHabit(habitId)

        // Reload all widget timelines
        WidgetCenter.shared.reloadAllTimelines()

        return .result()
    }
}
