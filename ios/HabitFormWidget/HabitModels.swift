//
//  HabitModels.swift
//  HabitFormWidget
//
//  Created by Armagan Gok on 4.10.2025.
//

import Foundation
import SwiftUI
import WidgetKit

// MARK: - Widget Localization Helper
struct WidgetLocalization {
    static func getLocalizedString(for key: String) -> String {
        // Get the current language from the system
        let language = Locale.current.language.languageCode?.identifier ?? "en"

        // Default English strings
        let defaultStrings: [String: String] = [
            "widget.small.title": "Habit Tracker",
            "widget.small.description": "Track your daily habits with streak counter",
            "widget.medium.title": "7-Day Habit View",
            "widget.medium.description": "View your habit progress over the last 7 days",
            "widget.large.title": "Habit Heatmap",
            "widget.large.description":
                "GitHub-style heatmap showing your habit completion over time",
            "widget.grid.title": "60-Day Habit Grid",
            "widget.grid.description":
                "View your habit progress over the last 60 days in a compact grid",
            "widget.empty.no_habits": "No Habits",
            "widget.empty.create_hint": "Create a habit in the app to see it here",
            "widget.stats.current_streak": "Current Streak",
            "widget.stats.longest_streak": "Longest Streak",
            "widget.stats.completed": "Completed",
            "widget.stats.total_days": "Total Days",
            "widget.stats.days": "days",
            "widget.pro.upgrade": "Upgrade PRO",
        ]

        // Language-specific strings
        let localizedStrings: [String: [String: String]] = [
            "tr": [
                "widget.small.title": "Alışkanlık Takipçisi",
                "widget.small.description": "Seri sayacı ile günlük alışkanlıklarınızı takip edin",
                "widget.medium.title": "7 Günlük Alışkanlık Görünümü",
                "widget.medium.description": "Son 7 günlük alışkanlık ilerlemenizi görüntüleyin",
                "widget.large.title": "Alışkanlık Isı Haritası",
                "widget.large.description":
                    "Zaman içindeki alışkanlık tamamlama durumunuzu GitHub tarzı ısı haritası ile görün",
                "widget.grid.title": "60 Günlük Alışkanlık Izgarası",
                "widget.grid.description":
                    "Son 60 günlük alışkanlık ilerlemenizi kompakt bir ızgarada görüntüleyin",
                "widget.empty.no_habits": "Alışkanlık Yok",
                "widget.empty.create_hint":
                    "Burada görmek için uygulamada bir alışkanlık oluşturun",
                "widget.stats.current_streak": "Mevcut Seri",
                "widget.stats.longest_streak": "En Uzun Seri",
                "widget.stats.completed": "Tamamlanan",
                "widget.stats.total_days": "Toplam Gün",
                "widget.stats.days": "gün",
                "widget.pro.upgrade": "PRO'ya Yükselt",
            ],
            "es": [
                "widget.small.title": "Rastreador de Hábitos",
                "widget.small.description": "Rastrea tus hábitos diarios con contador de rachas",
                "widget.medium.title": "Vista de Hábitos de 7 Días",
                "widget.medium.description": "Ve tu progreso de hábitos durante los últimos 7 días",
                "widget.large.title": "Mapa de Calor de Hábitos",
                "widget.large.description":
                    "Mapa de calor estilo GitHub que muestra tu finalización de hábitos a lo largo del tiempo",
                "widget.grid.title": "Cuadrícula de Hábitos de 60 Días",
                "widget.grid.description":
                    "Ve tu progreso de hábitos durante los últimos 60 días en una cuadrícula compacta",
                "widget.empty.no_habits": "Sin Hábitos",
                "widget.empty.create_hint": "Crea un hábito en la aplicación para verlo aquí",
                "widget.stats.current_streak": "Racha Actual",
                "widget.stats.longest_streak": "Racha Más Larga",
                "widget.stats.completed": "Completados",
                "widget.stats.total_days": "Días Totales",
                "widget.stats.days": "días",
                "widget.pro.upgrade": "Actualizar a PRO",
            ],
            "fr": [
                "widget.small.title": "Suivi d'Habitudes",
                "widget.small.description":
                    "Suivez vos habitudes quotidiennes avec compteur de séries",
                "widget.medium.title": "Vue d'Habitudes 7 Jours",
                "widget.medium.description":
                    "Voir vos progrès d'habitudes au cours des 7 derniers jours",
                "widget.large.title": "Carte de Chaleur d'Habitudes",
                "widget.large.description":
                    "Carte de chaleur style GitHub montrant votre accomplissement d'habitudes dans le temps",
                "widget.grid.title": "Grille d'Habitudes 60 Jours",
                "widget.grid.description":
                    "Voir vos progrès d'habitudes au cours des 60 derniers jours dans une grille compacte",
                "widget.empty.no_habits": "Aucune Habitude",
                "widget.empty.create_hint":
                    "Créez une habitude dans l'application pour la voir ici",
                "widget.stats.current_streak": "Série Actuelle",
                "widget.stats.longest_streak": "Série la Plus Longue",
                "widget.stats.completed": "Terminés",
                "widget.stats.total_days": "Jours Totaux",
                "widget.stats.days": "jours",
                "widget.pro.upgrade": "Passer à PRO",
            ],
            "it": [
                "widget.small.title": "Tracciatore Abitudini",
                "widget.small.description":
                    "Traccia le tue abitudini quotidiane con contatore di serie",
                "widget.medium.title": "Vista Abitudini 7 Giorni",
                "widget.medium.description":
                    "Visualizza i tuoi progressi delle abitudini negli ultimi 7 giorni",
                "widget.large.title": "Mappa Termica Abitudini",
                "widget.large.description":
                    "Mappa termica stile GitHub che mostra il completamento delle tue abitudini nel tempo",
                "widget.grid.title": "Griglia Abitudini 60 Giorni",
                "widget.grid.description":
                    "Visualizza i tuoi progressi delle abitudini negli ultimi 60 giorni in una griglia compatta",
                "widget.empty.no_habits": "Nessuna Abitudine",
                "widget.empty.create_hint": "Crea un'abitudine nell'app per vederla qui",
                "widget.stats.current_streak": "Serie Attuale",
                "widget.stats.longest_streak": "Serie Più Lunga",
                "widget.stats.completed": "Completati",
                "widget.stats.total_days": "Giorni Totali",
                "widget.stats.days": "giorni",
                "widget.pro.upgrade": "Passa a PRO",
            ],
            "ja": [
                "widget.small.title": "習慣トラッカー",
                "widget.small.description": "連続カウンターで日々の習慣を追跡",
                "widget.medium.title": "7日間習慣ビュー",
                "widget.medium.description": "過去7日間の習慣進捗を表示",
                "widget.large.title": "習慣ヒートマップ",
                "widget.large.description": "GitHubスタイルのヒートマップで時間経過に伴う習慣完了を表示",
                "widget.grid.title": "60日間習慣グリッド",
                "widget.grid.description": "過去60日間の習慣進捗をコンパクトなグリッドで表示",
                "widget.empty.no_habits": "習慣なし",
                "widget.empty.create_hint": "ここに表示するにはアプリで習慣を作成してください",
                "widget.stats.current_streak": "現在の連続",
                "widget.stats.longest_streak": "最長連続",
                "widget.stats.completed": "完了",
                "widget.stats.total_days": "総日数",
                "widget.stats.days": "日",
                "widget.pro.upgrade": "PROにアップグレード",
            ],
            "zh": [
                "widget.small.title": "习惯追踪器",
                "widget.small.description": "使用连续计数追踪你的日常习惯",
                "widget.medium.title": "7天习惯视图",
                "widget.medium.description": "查看过去7天的习惯进度",
                "widget.large.title": "习惯热力图",
                "widget.large.description": "GitHub风格的热力图显示你随时间的习惯完成情况",
                "widget.grid.title": "60天习惯网格",
                "widget.grid.description": "在紧凑网格中查看过去60天的习惯进度",
                "widget.empty.no_habits": "无习惯",
                "widget.empty.create_hint": "在应用中创建习惯以在此处查看",
                "widget.stats.current_streak": "当前连续",
                "widget.stats.longest_streak": "最长连续",
                "widget.stats.completed": "已完成",
                "widget.stats.total_days": "总天数",
                "widget.stats.days": "天",
                "widget.pro.upgrade": "升级到PRO",
            ],
            "ar": [
                "widget.small.title": "متتبع العادات",
                "widget.small.description": "تتبع عاداتك اليومية مع عداد السلسلة",
                "widget.medium.title": "عرض العادات لـ 7 أيام",
                "widget.medium.description": "عرض تقدم عاداتك خلال آخر 7 أيام",
                "widget.large.title": "خريطة حرارية للعادات",
                "widget.large.description":
                    "خريطة حرارية بأسلوب GitHub تُظهر إكمال عاداتك عبر الوقت",
                "widget.grid.title": "شبكة العادات لـ 60 يوماً",
                "widget.grid.description": "عرض تقدم عاداتك خلال آخر 60 يوماً في شبكة مدمجة",
                "widget.empty.no_habits": "لا توجد عادات",
                "widget.empty.create_hint": "أنشئ عادة في التطبيق لرؤيتها هنا",
                "widget.stats.current_streak": "السلسلة الحالية",
                "widget.stats.longest_streak": "أطول سلسلة",
                "widget.stats.completed": "مكتمل",
                "widget.stats.total_days": "إجمالي الأيام",
                "widget.stats.days": "أيام",
                "widget.pro.upgrade": "ترقية إلى PRO",
            ],
            "fi": [
                "widget.small.title": "Tapaseuranta",
                "widget.small.description": "Seuraa päivittäisiä tapojasi putken laskurilla",
                "widget.medium.title": "7 Päivän Tapojenäkymä",
                "widget.medium.description": "Katso tapojesi edistystä viimeisten 7 päivän ajalta",
                "widget.large.title": "Tapojen Lämpökartta",
                "widget.large.description":
                    "GitHub-tyylinen lämpökartta, joka näyttää tapojesi suorittamisen ajan myötä",
                "widget.grid.title": "60 Päivän Tapojen Ruudukko",
                "widget.grid.description":
                    "Katso tapojesi edistystä viimeisten 60 päivän ajalta kompaktissa ruudukossa",
                "widget.empty.no_habits": "Ei tapoja",
                "widget.empty.create_hint": "Luo tapa sovelluksessa nähdäksesi sen täällä",
                "widget.stats.current_streak": "Nykyinen putki",
                "widget.stats.longest_streak": "Pisin putki",
                "widget.stats.completed": "Valmiit",
                "widget.stats.total_days": "Yhteensä päiviä",
                "widget.stats.days": "päivää",
                "widget.pro.upgrade": "Päivitä PRO:ksi",
            ],
        ]

        // Return localized string or default
        if let languageStrings = localizedStrings[language],
            let localizedString = languageStrings[key]
        {
            return localizedString
        }

        return defaultStrings[key] ?? key
    }
}

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

    // Pro membership status
    let isProMember: Bool?

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
                    flutterTotalDays: habit.flutterTotalDays,
                    isProMember: habit.isProMember
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
                    flutterTotalDays: habit.flutterTotalDays,
                    isProMember: habit.isProMember
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
