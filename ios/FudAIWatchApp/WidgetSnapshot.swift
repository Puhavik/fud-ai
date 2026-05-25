import Foundation

struct WidgetSnapshot: Codable, Equatable {
    let date: Date
    let dayStart: Date
    let calories: Int
    let calorieGoal: Int
    let protein: Double
    let proteinGoal: Int
    let carbs: Double
    let carbsGoal: Int
    let fat: Double
    let fatGoal: Int

    static var appGroupID: String {
        Bundle.main.object(forInfoDictionaryKey: "AppGroupIdentifier") as? String
            ?? "group.com.apoorvdarshan.calorietracker"
    }

    static let watchPayloadKey = "widget_snapshot_data_v1"
    private static let key = "widget_snapshot_v1"

    static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    static func read() -> WidgetSnapshot? {
        guard let data = sharedDefaults?.data(forKey: key),
              let snapshot = try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
        else { return nil }

        return snapshot.normalizedForToday()
    }

    func normalizedForToday(_ now: Date = Date()) -> WidgetSnapshot {
        let today = Calendar.current.startOfDay(for: now)
        guard Calendar.current.isDate(dayStart, inSameDayAs: today) else {
            return zeroedForToday(now)
        }
        return self
    }

    private func zeroedForToday(_ now: Date) -> WidgetSnapshot {
        let today = Calendar.current.startOfDay(for: now)
        // New day: reset progress to zero but keep the user's goals so
        // the Watch app doesn't fall back to hard-coded defaults.
        return WidgetSnapshot(
            date: now,
            dayStart: today,
            calories: 0, calorieGoal: calorieGoal,
            protein: 0, proteinGoal: proteinGoal,
            carbs: 0, carbsGoal: carbsGoal,
            fat: 0, fatGoal: fatGoal
        )
    }

    static func write(_ snapshot: WidgetSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        sharedDefaults?.set(data, forKey: key)
    }

    static func decodePayload(_ data: Data) -> WidgetSnapshot? {
        try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
    }

    static var placeholder: WidgetSnapshot {
        let now = Date()
        return WidgetSnapshot(
            date: now,
            dayStart: Calendar.current.startOfDay(for: now),
            calories: 1247, calorieGoal: 2000,
            protein: 84, proteinGoal: 150,
            carbs: 132, carbsGoal: 220,
            fat: 42, fatGoal: 70
        )
    }

    static var empty: WidgetSnapshot {
        let now = Date()
        return WidgetSnapshot(
            date: now,
            dayStart: Calendar.current.startOfDay(for: now),
            calories: 0, calorieGoal: 2000,
            protein: 0, proteinGoal: 150,
            carbs: 0, carbsGoal: 220,
            fat: 0, fatGoal: 70
        )
    }

    var caloriesRemaining: Int { max(0, calorieGoal - calories) }
    var proteinRemaining: Double { max(0, Double(proteinGoal) - protein) }
    var carbsRemaining: Double { max(0, Double(carbsGoal) - carbs) }
    var fatRemaining: Double { max(0, Double(fatGoal) - fat) }

    var calorieProgress: Double {
        progress(value: Double(calories), goal: calorieGoal)
    }

    var proteinProgress: Double {
        progress(value: protein, goal: proteinGoal)
    }

    var carbsProgress: Double {
        progress(value: carbs, goal: carbsGoal)
    }

    var fatProgress: Double {
        progress(value: fat, goal: fatGoal)
    }

    private func progress(value: Double, goal: Int) -> Double {
        guard goal > 0 else { return 0 }
        return min(1.0, value / Double(goal))
    }
}
