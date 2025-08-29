
import Foundation

public struct NutritionTotals: Codable, Equatable {
    public var carbs_g: Double
    public var protein_g: Double
    public var fat_g: Double
}

public struct StageMealResult: Codable, Equatable, Identifiable {
    public var id: String { (mealName ?? "meal") + "-\(Int(analysis.carbs_g))"
                            + "-\(Int(analysis.protein_g))"
                            + "-\(Int(analysis.fat_g))" }
    public var mealName: String?
    public var analysis: NutritionTotals

    public init(mealName: String?, analysis: NutritionTotals) {
        self.mealName = mealName
        self.analysis = analysis
    }
}
