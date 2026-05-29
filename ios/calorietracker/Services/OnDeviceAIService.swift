// FoundationModels ships with the iOS 26 SDK. The #if canImport guard ensures
// this file compiles cleanly with older SDKs — the call site in GeminiService
// is also guarded with #if canImport so the dead code is stripped at build time.
#if canImport(FoundationModels)
import Foundation
import FoundationModels

/// On-device food analysis using Apple's Foundation Models (iOS 26+, Apple Intelligence).
/// No internet, no API key, no quota — runs entirely on chip.
/// Falls back silently (returns nil) on unsupported devices or when model is unavailable.
@available(iOS 26, *)
enum OnDeviceAIService {

    // MARK: - Generable output type

    @Generable
    struct FoodResult {
        @Guide(description: "Common name of the food or meal")
        var name: String

        @Guide(description: "Total calories in kcal, as an integer")
        var calories: Int

        @Guide(description: "Protein in grams")
        var protein: Double

        @Guide(description: "Total carbohydrates in grams")
        var carbs: Double

        @Guide(description: "Total fat in grams")
        var fat: Double

        @Guide(description: "Estimated weight of this portion in grams")
        var servingSizeGrams: Double

        @Guide(description: "A single food emoji that best represents this item, e.g. 🍗")
        var emoji: String

        @Guide(description: "Estimation confidence: 'high' if exactly known, 'medium' if portion was estimated, 'low' if uncertain")
        var confidence: String

        @Guide(description: "Dietary fiber in grams, or null if unknown")
        var fiber: Double?

        @Guide(description: "Sodium in milligrams, or null if unknown")
        var sodium: Double?

        @Guide(description: "Saturated fat in grams, or null if unknown")
        var saturatedFat: Double?

        @Guide(description: "Sugar in grams, or null if unknown")
        var sugar: Double?
    }

    // MARK: - Public API

    /// Analyze a text food description on-device.
    /// Returns nil if Apple Intelligence is unavailable on this device.
    static func analyzeText(_ description: String) async -> GeminiService.FoodAnalysis? {
        guard SystemLanguageModel.default.isAvailable else { return nil }
        do {
            let session = LanguageModelSession(instructions: """
                You are a nutrition database assistant for a food tracking app. \
                Estimate nutrition from standard data (USDA/NCCDB). Be precise and conservative — do not over-estimate. \
                Return the food name in the same language the user used. \
                If a quantity is given, use it; if not, assume a typical home serving for an adult (not a diet portion), \
                and for whole fruits or vegetables assume a medium-large piece. \
                Use a generic food unless an exact brand is clearly named; never invent branded nutrition values. \
                Set confidence to 'medium' when you had to estimate the portion. \
                If the input is not a recognizable food, set name to "unknown" and all numeric fields to 0.
                """)
            let response = try await session.respond(
                to: description,
                generating: FoodResult.self
            )
            let result = response.content
            // On-device guided generation always fills the struct, so it can't emit a
            // not_food error object. The "unknown" sentinel means it didn't recognize a
            // food — return nil so the caller falls back to the (stronger) network model.
            // Note: don't gate on calories > 0 — water, black coffee and diet drinks are
            // legitimate zero-calorie foods and must not be treated as "unrecognized".
            let trimmedName = result.name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedName.isEmpty, trimmedName.lowercased() != "unknown" else { return nil }
            return GeminiService.FoodAnalysis(
                name: result.name,
                calories: result.calories,
                protein: result.protein,
                carbs: result.carbs,
                fat: result.fat,
                servingSizeGrams: result.servingSizeGrams,
                emoji: result.emoji,
                confidence: result.confidence,
                sugar: result.sugar,
                fiber: result.fiber,
                saturatedFat: result.saturatedFat,
                sodium: result.sodium
            )
        } catch {
            return nil
        }
    }
}
#endif
