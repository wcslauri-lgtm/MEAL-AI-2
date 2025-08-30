
import SwiftUI

struct SettingsView: View {
    @AppStorage("appLanguage") private var appLanguage: String = "FI"
    @AppStorage("foodSearchEnabled") private var foodSearchEnabled: Bool = true
    @AppStorage("useVisionCamera") private var useVisionCamera: Bool = true
    @State private var provider: AIProvider = UserDefaults.standard.selectedAIProvider

    @State private var openAIKey: String = KeychainHelper.shared.get("openai_api_key") ?? ""
    @State private var claudeKey: String = KeychainHelper.shared.get("claude_api_key") ?? ""
    @State private var geminiKey: String = KeychainHelper.shared.get("gemini_api_key") ?? ""
    @State private var usda: String = UserDefaults.standard.usdaApiKey ?? ""

    @AppStorage("shortcutName") private var shortcutName: String = ""
    @AppStorage("shortcutEnabled") private var shortcutEnabled: Bool = true

    @State private var testing = false
    @State private var testResult: String?

    var body: some View {
        Form {
            Section {
                Toggle("Food Search käytössä", isOn: $foodSearchEnabled)
                Toggle("Kamera-analyysi (AI Vision)", isOn: $useVisionCamera).disabled(!foodSearchEnabled)

                Picker("AI-palvelu", selection: $provider) {
                    ForEach(AIProvider.allCases) { p in Text(p.displayName).tag(p) }
                }.pickerStyle(.segmented)
                 .disabled(!foodSearchEnabled)
            } header: { Text("Food Search") }

            if foodSearchEnabled {
                Section("API-avaimet") {
                    SecureField("OpenAI key (sk-…)", text: $openAIKey)
                        .textInputAutocapitalization(.never)
                        .onChange(of: openAIKey) { _, v in KeychainHelper.shared.set(v, for: "openai_api_key") }
                    SecureField("Claude key (sk-ant-…)", text: $claudeKey)
                        .textInputAutocapitalization(.never)
                        .onChange(of: claudeKey) { _, v in KeychainHelper.shared.set(v, for: "claude_api_key") }
                    SecureField("Gemini key", text: $geminiKey)
                        .textInputAutocapitalization(.never)
                        .onChange(of: geminiKey) { _, v in KeychainHelper.shared.set(v, for: "gemini_api_key") }
                    TextField("USDA API key (valinn.)", text: $usda)
                        .textInputAutocapitalization(.never)
                        .onChange(of: usda) { _, v in UserDefaults.standard.usdaApiKey = v }
                }

                Section {
                    Button {
                        Task { await testOpenAI() }
                    } label: {
                        if testing { ProgressView() } else { Text("Testaa OpenAI-yhteys") }
                    }
                    if let r = testResult { Text(r).font(.footnote).foregroundColor(.secondary) }
                }
            }

            Section {
                TextField("Shortcuttin nimi", text: $shortcutName)
                Toggle("Lähetä tiedot Shortcutille", isOn: $shortcutEnabled)
                Text("Sovellus välittää Shortcutille JSON-objektin: { \"carbs\": 00, \"fat\": 00, \"protein\": 00 }.")
                    .font(.footnote).foregroundColor(.secondary)
            } header: { Text("Shortcuts") }

            Section {
                Picker("Kieli", selection: $appLanguage) {
                    Text("Suomi").tag("FI")
                    Text("English").tag("EN")
                }.pickerStyle(.segmented)
            } header: { Text("Kieli") }
        }
        .navigationTitle("Asetukset")
        .onChange(of: provider) { _, v in UserDefaults.standard.selectedAIProvider = v }
    }

    private func testOpenAI() async {
        testing = true
        defer { testing = false }
        testResult = nil
        let key = KeychainHelper.shared.get("openai_api_key") ?? ""
        guard key.starts(with: "sk-") else { testResult = "Virheellinen OpenAI-avain"; return }
        let api = OpenAIAPI(apiKey: key)
        do {
            _ = try await api.sendChat(model: .gpt4oMini, systemPrompt: "healthcheck", userPrompt: "ping",
                                       imageDatas: nil, temperature: 0.0, maxCompletionTokens: 5, forceJSON: false)
            testResult = "OK ✅"
        } catch {
            testResult = "Virhe: \(error.localizedDescription)"
        }
    }
}
