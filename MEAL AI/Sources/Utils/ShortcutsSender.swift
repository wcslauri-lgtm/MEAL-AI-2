import UIKit

enum ShortcutsSender {
    static func sendToShortcuts(stage: StageMealResult) {
        let c = Int(stage.analysis.carbs_g.rounded())
        let f = Int(stage.analysis.fat_g.rounded())
        let p = Int(stage.analysis.protein_g.rounded())

        let defaults = UserDefaults.standard
        let name = defaults.shortcutName.trimmingCharacters(in: .whitespacesAndNewlines)
        let enabled = defaults.shortcutEnabled
        guard !name.isEmpty, enabled else { return }

        var comps = URLComponents()
        comps.scheme = "shortcuts"
        comps.host = "x-callback-url"
        comps.path = "/run-shortcut"

        var items: [URLQueryItem] = [
            .init(name: "name", value: name),
            .init(name: "x-success", value: "mealai://done"),
            .init(name: "x-error", value: "mealai://error")
        ]

        // IMPORTANT: For Shortcuts URL scheme, you must provide BOTH:
        // input=text  and  text=<payload>
        let payload: [String: Any] = ["carbs": c, "fat": f, "protein": p]
        if let data = try? JSONSerialization.data(withJSONObject: payload),
           let json = String(data: data, encoding: .utf8) {
            items.append(.init(name: "input", value: "text"))
            items.append(.init(name: "text", value: json))
        }

        comps.queryItems = items
        if let url = comps.url {
            UIApplication.shared.open(url)
        }
    }
}
