
import Foundation

enum AIProvider: String, CaseIterable, Identifiable, Codable {
    case openAI, claude, gemini
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .openAI: return "OpenAI"
        case .claude: return "Claude"
        case .gemini: return "Gemini"
        }
    }
}

extension UserDefaults {
    var foodSearchEnabled: Bool {
        get { bool(forKey: "foodSearchEnabled") }
        set { set(newValue, forKey: "foodSearchEnabled") }
    }

    var selectedAIProvider: AIProvider {
        get {
            if let raw = string(forKey: "selectedAIProvider"),
               let p = AIProvider(rawValue: raw) { return p }
            return .openAI
        }
        set { set(newValue.rawValue, forKey: "selectedAIProvider") }
    }

    var useVisionCamera: Bool {
        get { bool(forKey: "useVisionCamera") }
        set { set(newValue, forKey: "useVisionCamera") }
    }

    var voiceSearchEnabled: Bool {
        get { bool(forKey: "voiceSearchEnabled") }
        set { set(newValue, forKey: "voiceSearchEnabled") }
    }

    var usdaApiKey: String? {
        get { string(forKey: "usdaApiKey") }
        set { set(newValue, forKey: "usdaApiKey") }
    }

    var shortcutName: String {
        get { string(forKey: "shortcutName") ?? "" }
        set { set(newValue, forKey: "shortcutName") }
    }

    /// Controls whether the app should send data to a Shortcut.
    var shortcutEnabled: Bool {
        get { bool(forKey: "shortcutEnabled") }
        set { set(newValue, forKey: "shortcutEnabled") }
    }

    var appLanguage: String {
        get { string(forKey: "appLanguage") ?? "FI" }
        set { set(newValue, forKey: "appLanguage") }
    }
}
