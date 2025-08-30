
import Foundation

final class FoodSearchRouter {
    static let shared = FoodSearchRouter()
    private init() {}

    enum Input { case text(String); case voice(String); case barcode(String); case images([Data]) }

    func run(_ input: Input) async throws -> StageMealResult {
        switch input {
        case .text(let q), .voice(let q):
            let base = try await USDAService.shared.fetchFood(query: q)
            let ai   = try await AIFoodAnalysis.shared.analyze(baseInfo: base, query: q)
            return map(base: base, ai: ai)
        case .barcode(let code):
            let off  = try await OpenFoodFactsService.shared.fetchProduct(barcode: code)
            let ai   = try await AIFoodAnalysis.shared.analyze(baseInfo: off, query: off.name)
            return map(base: off, ai: ai)
        case .images(let data):
            let ai = try await AIFoodAnalysis.shared.analyze(imageDatas: data)
            return map(base: nil, ai: ai)
        }
    }

    private func map(base: FoodBaseInfo?, ai: AIFoodAnalysisResult) -> StageMealResult {
        let totals = NutritionTotals(
            carbs_g: ai.carbohydrates ?? base?.carbs ?? 0,
            protein_g: ai.protein ?? base?.protein ?? 0,
            fat_g: ai.fat ?? base?.fat ?? 0,
            calories_kcal: ai.calories,
            fiber_g: ai.fiber
        )
        let name = ai.mealName ?? base?.name
        return StageMealResult(
            mealName: name,
            mealDescription: ai.mealDescription,
            portionDescription: ai.portionDescription,
            diabetesNotes: ai.diabetesNotes,
            analysis: totals
        )
    }
}
