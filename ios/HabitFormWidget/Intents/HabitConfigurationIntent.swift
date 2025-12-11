//
//  HabitConfigurationIntent.swift
//  HabitFormWidget
//
//  Created by Armagan Gok on 4.10.2025.
//

import AppIntents
import Foundation
import SwiftUI
import WidgetKit

struct HabitConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Habit"
    static var description = IntentDescription("Choose which habit to display in the widget")

    @Parameter(title: "Habit")
    var habit: HabitEntity?

    init() {}

    init(habit: HabitEntity?) {
        self.habit = habit
    }
}

struct HabitEntity: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Habit"
    static var defaultQuery = HabitQuery()

    var id: String
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(emoji) \(name)")
    }

    let name: String
    let emoji: String

    init(id: String, name: String, emoji: String) {
        self.id = id
        self.name = name
        self.emoji = emoji
    }
}

struct HabitQuery: EntityQuery {
    func entities(for identifiers: [HabitEntity.ID]) async throws -> [HabitEntity] {
        print("🔍 HabitQuery: entities(for identifiers: \(identifiers))")
        let habits = HabitDataManager.shared.loadHabits()
        print("🔍 HabitQuery: Loaded \(habits.count) habits for identifiers")
        return habits.compactMap { habit in
            guard identifiers.contains(habit.id) else { return nil }
            print("🔍 HabitQuery: Creating entity for \(habit.habitName)")
            return HabitEntity(
                id: habit.id,
                name: habit.habitName,
                emoji: habit.emoji ?? "📝"
            )
        }
    }

    func suggestedEntities() async throws -> [HabitEntity] {
        print("🔍 HabitQuery: suggestedEntities() called at \(Date())")

        // Test App Group access first
        HabitDataManager.shared.testAppGroupAccess()

        let habits = HabitDataManager.shared.loadHabits()
        print("🔍 HabitQuery: Found \(habits.count) habits for widget selection")

        if habits.isEmpty {
            print(
                "⚠️ HabitQuery: No habits found! This will cause 'Habit Habit' placeholder in widget selection"
            )
        }

        let entities = habits.map { habit in
            let entity = HabitEntity(
                id: habit.id,
                name: habit.habitName,
                emoji: habit.emoji ?? "📝"
            )
            print("🔍 HabitQuery: Created entity for '\(habit.habitName)' (ID: \(habit.id))")
            return entity
        }
        print("🔍 HabitQuery: Returning \(entities.count) entities")

        for (index, entity) in entities.enumerated() {
            print("  \(index + 1). \(entity.name) (\(entity.id))")
        }

        return entities
    }

    func defaultResult() async -> HabitEntity? {
        print("🔍 HabitQuery: defaultResult() called")
        let habits = HabitDataManager.shared.loadHabits()
        guard let firstHabit = habits.first else {
            print("❌ HabitQuery: No habits found for default result")
            return nil
        }
        print("✅ HabitQuery: Default habit is \(firstHabit.habitName)")
        return HabitEntity(
            id: firstHabit.id,
            name: firstHabit.habitName,
            emoji: firstHabit.emoji ?? "📝"
        )
    }
}
