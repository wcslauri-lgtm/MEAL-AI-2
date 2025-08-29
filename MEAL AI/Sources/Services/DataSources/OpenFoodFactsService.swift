
import Foundation

struct OFFResponse: Decodable { let product: OFFProduct?; let status: Int? }
struct OFFProduct: Decodable {
    let product_name: String?
    let brands: String?
    let nutriments: OFFNutriments?
    let serving_size: String?
    let image_url: String?
}
struct OFFNutriments: Decodable {
    let carbohydrates_100g: Double?
    let proteins_100g: Double?
    let fat_100g: Double?
    let carbohydrates_serving: Double?
    let proteins_serving: Double?
    let fat_serving: Double?
}

final class OpenFoodFactsService {
    static let shared = OpenFoodFactsService()
    private init() {}

    func fetchProduct(barcode: String) async throws -> OFFBaseInfo {
        let url = URL(string: "https://world.openfoodfacts.org/api/v2/product/\(barcode).json")!
        let (data, resp) = try await URLSession.shared.data(from: url)
        guard let http = resp as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw NSError(domain: "OFF", code: -1, userInfo: [NSLocalizedDescriptionKey: "OFF request failed"])
        }
        let decoded = try JSONDecoder().decode(OFFResponse.self, from: data)
        guard let p = decoded.product else { throw NSError(domain: "OFF", code: -2, userInfo: [NSLocalizedDescriptionKey: "Product not found"]) }
        let carbs  = p.nutriments?.carbohydrates_serving ?? p.nutriments?.carbohydrates_100g
        let prot   = p.nutriments?.proteins_serving ?? p.nutriments?.proteins_100g
        let fat    = p.nutriments?.fat_serving ?? p.nutriments?.fat_100g
        let name   = [p.product_name, p.brands].compactMap{$0}.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
        return OFFBaseInfo(name: name.isEmpty ? "Product" : name, carbs: carbs, protein: prot, fat: fat)
    }
}
