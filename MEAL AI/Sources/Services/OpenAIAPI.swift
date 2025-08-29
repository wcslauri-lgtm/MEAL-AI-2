
import Foundation

enum OpenAIModel: String { case gpt4oMini = "gpt-4o-mini" }

final class OpenAIAPI {
    var apiKey: String
    private let session: URLSession
    private let endpoint = URL(string: "https://api.openai.com/v1/chat/completions")!

    init(apiKey: String) {
        self.apiKey = apiKey
        let cfg = URLSessionConfiguration.default
        cfg.timeoutIntervalForRequest = 120
        cfg.timeoutIntervalForResource = 240
        self.session = URLSession(configuration: cfg)
    }

    func sendChat(
        model: OpenAIModel,
        systemPrompt: String,
        userPrompt: String,
        imageData: Data? = nil,
        temperature: Double = 0.0,
        maxCompletionTokens: Int = 600,
        forceJSON: Bool = true
    ) async throws -> String {
        var req = URLRequest(url: endpoint)
        req.httpMethod = "POST"
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var messages: [[String: Any]] = [["role": "system", "content": systemPrompt]]
        if let imageData = imageData {
            let base64 = imageData.base64EncodedString()
            let textPart: [String: Any]  = ["type": "text", "text": userPrompt]
            let imagePart: [String: Any] = ["type": "image_url",
                                            "image_url": ["url": "data:image/jpeg;base64,\(base64)"]]
            messages.append(["role": "user", "content": [textPart, imagePart]])
        } else {
            messages.append(["role": "user", "content": userPrompt])
        }

        var body: [String: Any] = ["model": model.rawValue,
                                   "messages": messages,
                                   "max_completion_tokens": maxCompletionTokens,
                                   "temperature": temperature]
        if forceJSON { body["response_format"] = ["type": "json_object"] }
        req.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])

        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            let raw = String(data: data, encoding: .utf8) ?? ""
            throw NSError(domain: "OpenAIAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: raw])
        }
        let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let choices = (obj?["choices"] as? [[String: Any]]) ?? []
        let message = choices.first?["message"] as? [String: Any]
        if let text = message?["content"] as? String { return text }
        return String(data: data, encoding: .utf8) ?? ""
    }
}
