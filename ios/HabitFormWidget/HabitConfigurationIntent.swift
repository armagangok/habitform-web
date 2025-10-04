//
//  HabitConfigurationIntent.swift
//  HabitFormWidget
//
//  Created by Armagan Gok on 4.10.2025.
//

import AppIntents
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
        let habits = HabitDataManager.shared.loadHabits()
        return habits.compactMap { habit in
            guard identifiers.contains(habit.id) else { return nil }
            return HabitEntity(
                id: habit.id,
                name: habit.habitName,
                emoji: habit.emoji ?? "📝"
            )
        }
    }

    func suggestedEntities() async throws -> [HabitEntity] {
        let habits = HabitDataManager.shared.loadHabits()
        print("HabitQuery: Found \(habits.count) habits for widget selection")
        return habits.map { habit in
            let entity = HabitEntity(
                id: habit.id,
                name: habit.habitName,
                emoji: habit.emoji ?? "📝"
            )
            print("HabitQuery: Created entity for \(habit.habitName)")
            return entity
        }
    }

    func defaultResult() async -> HabitEntity? {
        let habits = HabitDataManager.shared.loadHabits()
        guard let firstHabit = habits.first else {
            print("HabitQuery: No habits found for default result")
            return nil
        }
        print("HabitQuery: Default habit is \(firstHabit.habitName)")
        return HabitEntity(
            id: firstHabit.id,
            name: firstHabit.habitName,
            emoji: firstHabit.emoji ?? "📝"
        )
    }
}
