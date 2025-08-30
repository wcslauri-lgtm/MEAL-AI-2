
import Foundation

protocol AIProviderService {
    func analyze(prompt: String, imageData: [Data]?) async throws -> AIFoodAnalysisResult
}

final class OpenAIProviderService: AIProviderService {
    static let shared = OpenAIProviderService()
    private init() {}

    func analyze(prompt: String, imageData: [Data]?) async throws -> AIFoodAnalysisResult {
        guard let key = KeychainHelper.shared.get("openai_api_key"), !key.isEmpty else {
            throw NSError(domain: "OpenAI", code: -10, userInfo: [NSLocalizedDescriptionKey: "OpenAI key missing"])
        }
        let api = OpenAIAPI(apiKey: key)
        let sys = "You are a nutrition assistant. Reply strictly as JSON with keys: mealName, mealDescription, calories, carbohydrates, protein, fat, fiber, portionDescription, diabetesNotes."
        let raw = try await api.sendChat(model: .gpt4oMini, systemPrompt: sys, userPrompt: prompt,
                                         imageDatas: imageData, temperature: 0.0, maxCompletionTokens: 600, forceJSON: true)
        let cleaned = JSONTools.sanitizeJSON(raw)
        if let parsed: AIFoodAnalysisResult = JSONTools.decode(AIFoodAnalysisResult.self, from: cleaned) {
            return parsed
        }
        throw NSError(domain: "OpenAI", code: -11, userInfo: [NSLocalizedDescriptionKey: "Cannot parse JSON"])
    }
}

final class AIFoodAnalysis {
    static let shared = AIFoodAnalysis()
    private init() {}

    private var provider: AIProviderService {
        switch UserDefaults.standard.selectedAIProvider {
        case .openAI: return OpenAIProviderService.shared
        case .claude: return OpenAIProviderService.shared // placeholder
        case .gemini: return OpenAIProviderService.shared // placeholder
        }
    }

    func analyze(baseInfo: FoodBaseInfo?, query: String) async throws -> AIFoodAnalysisResult {
        var prompt = """
        Food query: \(query)
        Return nutrition (grams) for the consumed portion and additional context.
        JSON keys: mealName, mealDescription, calories, carbohydrates, protein, fat, fiber, portionDescription, diabetesNotes.
        """
        if let b = baseInfo {
            prompt += "\nBase: name=\(b.name), carbs=\(b.carbs ?? -1), protein=\(b.protein ?? -1), fat=\(b.fat ?? -1)."
        }
        return try await provider.analyze(prompt: prompt, imageData: nil)
    }

    func analyze(imageDatas: [Data]) async throws -> AIFoodAnalysisResult {
        let prompt = """
        Inspect the photos and estimate macronutrients (g) and other context for the pictured portion.
        Output strict JSON: mealName, mealDescription, calories, carbohydrates, protein, fat, fiber, portionDescription, diabetesNotes.
        """
        return try await provider.analyze(prompt: prompt, imageData: imageDatas)
    }
}
