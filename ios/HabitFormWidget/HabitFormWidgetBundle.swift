//
//  HabitFormWidgetBundle.swift
//  HabitFormWidget
//
//  Created by Armagan Gok on 4.10.2025.
//

import AppIntents
import SwiftUI
import WidgetKit

@main
struct HabitFormWidgetBundle: WidgetBundle {
    var body: some Widget {
        SmallHabitWidget()
        SmallGridHabitWidget()
        MediumHabitWidget()
        LargeHabitWidget()
        ExtraLargeHabitWidget()
    }
}
