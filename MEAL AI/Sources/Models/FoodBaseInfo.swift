
import Foundation

protocol FoodBaseInfo {
    var name: String { get }
    var carbs: Double? { get }
    var protein: Double? { get }
    var fat: Double? { get }
}

struct OFFBaseInfo: FoodBaseInfo { let name: String; let carbs: Double?; let protein: Double?; let fat: Double? }
struct USDABaseInfo: FoodBaseInfo { let name: String; let carbs: Double?; let protein: Double?; let fat: Double? }
