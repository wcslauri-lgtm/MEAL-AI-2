
import Foundation

struct AIFoodAnalysisResult: Codable {
    let mealName: String?
    /// Free-form description of the meal components
    let mealDescription: String?
    /// Estimated energy in kilocalories
    let calories: Double?
    let carbohydrates: Double?
    let protein: Double?
    let fat: Double?
    let fiber: Double?
    /// Explanation of portion size / serving reasoning
    let portionDescription: String?
    /// Notes related to diabetes management for this meal
    let diabetesNotes: String?
}
