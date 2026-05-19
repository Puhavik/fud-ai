import Foundation

enum OptionalNutrient: String, CaseIterable, Identifiable, Codable {
    case fiber
    case sugar
    case addedSugar
    case saturatedFat
    case cholesterol
    case sodium
    case potassium
    case transFat
    case calcium
    case iron
    case magnesium
    case zinc
    case vitaminA
    case vitaminC
    case vitaminD
    case vitaminB12
    case vitaminE
    case vitaminK
    case folate
    case omega3

    var id: String { rawValue }

    var jsonKey: String {
        switch self {
        case .fiber: "fiber"
        case .sugar: "sugar"
        case .addedSugar: "added_sugar"
        case .saturatedFat: "saturated_fat"
        case .cholesterol: "cholesterol"
        case .sodium: "sodium"
        case .potassium: "potassium"
        case .transFat: "trans_fat"
        case .calcium: "calcium"
        case .iron: "iron"
        case .magnesium: "magnesium"
        case .zinc: "zinc"
        case .vitaminA: "vitamin_a"
        case .vitaminC: "vitamin_c"
        case .vitaminD: "vitamin_d"
        case .vitaminB12: "vitamin_b12"
        case .vitaminE: "vitamin_e"
        case .vitaminK: "vitamin_k"
        case .folate: "folate"
        case .omega3: "omega_3"
        }
    }

    init?(jsonKey: String) {
        switch jsonKey {
        case "fiber": self = .fiber
        case "sugar": self = .sugar
        case "added_sugar": self = .addedSugar
        case "saturated_fat": self = .saturatedFat
        case "cholesterol": self = .cholesterol
        case "sodium": self = .sodium
        case "potassium": self = .potassium
        case "trans_fat": self = .transFat
        case "calcium": self = .calcium
        case "iron": self = .iron
        case "magnesium": self = .magnesium
        case "zinc": self = .zinc
        case "vitamin_a": self = .vitaminA
        case "vitamin_c": self = .vitaminC
        case "vitamin_d": self = .vitaminD
        case "vitamin_b12": self = .vitaminB12
        case "vitamin_e": self = .vitaminE
        case "vitamin_k": self = .vitaminK
        case "folate": self = .folate
        case "omega_3": self = .omega3
        default: return nil
        }
    }

    var displayName: String {
        switch self {
        case .fiber: "Fiber"
        case .sugar: "Sugar"
        case .addedSugar: "Added Sugar"
        case .saturatedFat: "Saturated Fat"
        case .cholesterol: "Cholesterol"
        case .sodium: "Sodium"
        case .potassium: "Potassium"
        case .transFat: "Trans Fat"
        case .calcium: "Calcium"
        case .iron: "Iron"
        case .magnesium: "Magnesium"
        case .zinc: "Zinc"
        case .vitaminA: "Vitamin A"
        case .vitaminC: "Vitamin C"
        case .vitaminD: "Vitamin D"
        case .vitaminB12: "Vitamin B12"
        case .vitaminE: "Vitamin E"
        case .vitaminK: "Vitamin K"
        case .folate: "Folate"
        case .omega3: "Omega-3"
        }
    }

    var shortDisplayName: String {
        switch self {
        case .saturatedFat: "Sat Fat"
        case .addedSugar: "Added"
        case .transFat: "Trans"
        case .vitaminA: "Vit A"
        case .vitaminC: "Vit C"
        case .vitaminD: "Vit D"
        case .vitaminB12: "B12"
        case .vitaminE: "Vit E"
        case .vitaminK: "Vit K"
        case .omega3: "Omega"
        default: displayName
        }
    }

    var iconName: String {
        switch self {
        case .fiber: "leaf.fill"
        case .sugar: "cube.fill"
        case .addedSugar: "plus.circle.fill"
        case .saturatedFat: "circle.lefthalf.filled"
        case .cholesterol: "heart.fill"
        case .sodium: "circle.grid.2x2.fill"
        case .potassium: "bolt.fill"
        case .transFat: "drop.fill"
        case .calcium: "figure.strengthtraining.traditional"
        case .iron: "bolt.fill"
        case .magnesium: "sparkles"
        case .zinc: "shield.lefthalf.filled"
        case .vitaminA: "a.circle.fill"
        case .vitaminC: "c.circle.fill"
        case .vitaminD: "d.circle.fill"
        case .vitaminB12: "b.circle.fill"
        case .vitaminE: "e.circle.fill"
        case .vitaminK: "k.circle.fill"
        case .folate: "leaf.fill"
        case .omega3: "drop.fill"
        }
    }

    var unit: String {
        switch self {
        case .cholesterol, .sodium, .potassium, .calcium, .iron, .magnesium, .zinc, .vitaminC, .vitaminE: "mg"
        case .vitaminA, .vitaminD, .vitaminB12, .vitaminK, .folate: "mcg"
        default: "g"
        }
    }

    var defaultGoal: Int {
        switch self {
        case .fiber: 30
        case .sugar: 50
        case .addedSugar: 25
        case .saturatedFat: 20
        case .cholesterol: 300
        case .sodium: 2_300
        case .potassium: 3_500
        case .transFat: 0
        case .calcium: 1_000
        case .iron: 18
        case .magnesium: 400
        case .zinc: 11
        case .vitaminA: 900
        case .vitaminC: 90
        case .vitaminD: 20
        case .vitaminB12: 3
        case .vitaminE: 15
        case .vitaminK: 120
        case .folate: 400
        case .omega3: 2
        }
    }

    var range: ClosedRange<Int> {
        switch self {
        case .fiber: 5...100
        case .sugar: 0...200
        case .addedSugar: 0...100
        case .saturatedFat: 0...80
        case .cholesterol: 0...1_000
        case .sodium: 500...6_000
        case .potassium: 1_000...6_000
        case .transFat: 0...10
        case .calcium: 300...2_000
        case .iron: 5...45
        case .magnesium: 100...800
        case .zinc: 3...40
        case .vitaminA: 300...3_000
        case .vitaminC: 20...500
        case .vitaminD: 5...100
        case .vitaminB12: 1...20
        case .vitaminE: 5...100
        case .vitaminK: 30...300
        case .folate: 100...1_000
        case .omega3: 0...10
        }
    }

    var step: Int {
        switch self {
        case .sodium, .potassium, .calcium, .vitaminA, .folate: 50
        case .magnesium: 25
        case .vitaminC, .vitaminK: 10
        case .cholesterol: 50
        case .iron, .zinc, .vitaminD, .vitaminB12, .vitaminE, .transFat, .omega3: 1
        default: 5
        }
    }

    var goalStyle: String {
        switch self {
        case .fiber, .potassium, .calcium, .iron, .magnesium, .zinc, .vitaminA, .vitaminC, .vitaminD, .vitaminB12, .vitaminE, .vitaminK, .folate, .omega3:
            "target"
        case .sugar, .addedSugar, .saturatedFat, .cholesterol, .sodium, .transFat:
            "limit"
        }
    }
}

struct OptionalNutrientGoals: Codable, Equatable {
    static let storageKey = "optionalNutrientGoals"

    private var values: [String: Int]

    init(values: [String: Int] = [:]) {
        self.values = values
    }

    static let defaults = OptionalNutrientGoals(
        values: Dictionary(uniqueKeysWithValues: OptionalNutrient.allCases.map { ($0.rawValue, $0.defaultGoal) })
    )

    static var current: OptionalNutrientGoals {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return .defaults
        }
        return decoded(from: data)
    }

    static func decoded(from data: Data) -> OptionalNutrientGoals {
        guard !data.isEmpty,
              let goals = try? JSONDecoder().decode(OptionalNutrientGoals.self, from: data)
        else {
            return .defaults
        }
        return goals.mergedWithDefaults()
    }

    var encodedData: Data {
        (try? JSONEncoder().encode(mergedWithDefaults())) ?? Data()
    }

    func goal(for nutrient: OptionalNutrient) -> Int {
        values[nutrient.rawValue] ?? nutrient.defaultGoal
    }

    mutating func setGoal(_ value: Int, for nutrient: OptionalNutrient) {
        values[nutrient.rawValue] = Self.sanitized(value, for: nutrient)
    }

    func settingGoal(_ value: Int, for nutrient: OptionalNutrient) -> OptionalNutrientGoals {
        var copy = self
        copy.setGoal(value, for: nutrient)
        return copy
    }

    func mergedWithDefaults() -> OptionalNutrientGoals {
        var merged = OptionalNutrientGoals.defaults.values
        for nutrient in OptionalNutrient.allCases {
            if let value = values[nutrient.rawValue] {
                merged[nutrient.rawValue] = Self.sanitized(value, for: nutrient)
            }
        }
        return OptionalNutrientGoals(values: merged)
    }

    static func save(_ goals: OptionalNutrientGoals) {
        UserDefaults.standard.set(goals.encodedData, forKey: storageKey)
    }

    static func sanitized(_ value: Int, for nutrient: OptionalNutrient) -> Int {
        let clamped = min(max(value, nutrient.range.lowerBound), nutrient.range.upperBound)
        guard nutrient.step > 1 else { return clamped }
        let offset = clamped - nutrient.range.lowerBound
        let snappedOffset = Int((Double(offset) / Double(nutrient.step)).rounded()) * nutrient.step
        return min(max(nutrient.range.lowerBound + snappedOffset, nutrient.range.lowerBound), nutrient.range.upperBound)
    }
}
