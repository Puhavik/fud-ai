import Foundation
import Testing
@testable import calorietracker

/// Tests `GeminiService.parseFoodAnalysis` — the JSON the model returns when logging
/// food. Covers the new not_food guard, confidence parsing, and null-vs-zero handling
/// for optional nutrients. Pure parsing, no network.
struct GeminiParsingTests {

    // MARK: - not_food guard

    @Test func notFoodErrorThrowsTypedError() {
        #expect(throws: GeminiService.AnalysisError.self) {
            try GeminiService.parseFoodAnalysis(from: #"{"error":"not_food"}"#)
        }
    }

    @Test func notFoodEvenWrappedInProseStillThrows() {
        // extractJSON pulls the object out of any surrounding text.
        let text = "Sure! Here is the result:\n{\"error\":\"not_food\"}\nLet me know."
        #expect(throws: GeminiService.AnalysisError.self) {
            try GeminiService.parseFoodAnalysis(from: text)
        }
    }

    // MARK: - confidence

    @Test func parsesConfidenceWhenPresent() throws {
        let json = #"{"name":"Apple","calories":95,"protein":0.5,"carbs":25,"fat":0.3,"serving_size_grams":180,"confidence":"medium"}"#
        let result = try GeminiService.parseFoodAnalysis(from: json)
        #expect(result.confidence == "medium")
        #expect(result.name == "Apple")
        #expect(result.calories == 95)
    }

    @Test func confidenceIsNilWhenAbsent() throws {
        let json = #"{"name":"Apple","calories":95,"protein":0.5,"carbs":25,"fat":0.3,"serving_size_grams":180}"#
        let result = try GeminiService.parseFoodAnalysis(from: json)
        #expect(result.confidence == nil)
    }

    // MARK: - null vs zero for optional nutrients

    @Test func nullOptionalNutrientsParseAsNil() throws {
        let json = #"{"name":"Chicken","calories":165,"protein":31,"carbs":0,"fat":3.6,"serving_size_grams":100,"fiber":null,"sodium":null}"#
        let result = try GeminiService.parseFoodAnalysis(from: json)
        #expect(result.fiber == nil)
        #expect(result.sodium == nil)
        // Required macros still parse normally.
        #expect(result.protein == 31)
    }

    @Test func presentOptionalNutrientsParseThrough() throws {
        let json = #"{"name":"Oats","calories":150,"protein":5,"carbs":27,"fat":3,"serving_size_grams":40,"fiber":4.0,"sodium":2.0}"#
        let result = try GeminiService.parseFoodAnalysis(from: json)
        #expect(result.fiber == 4.0)
        #expect(result.sodium == 2.0)
    }

    // MARK: - missing required fields

    @Test func missingRequiredFieldThrows() {
        // No calories → invalid, must throw rather than silently default.
        #expect(throws: GeminiService.AnalysisError.self) {
            try GeminiService.parseFoodAnalysis(from: #"{"name":"Mystery","protein":1,"carbs":1,"fat":1}"#)
        }
    }
}
