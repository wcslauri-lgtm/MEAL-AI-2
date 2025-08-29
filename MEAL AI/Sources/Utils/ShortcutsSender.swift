import UIKit

enum ShortcutsSender {
    static func sendToShortcuts(stage: StageMealResult) {
        let c = Int(stage.analysis.carbs_g.rounded())
        let f = Int(stage.analysis.fat_g.rounded())
        let p = Int(stage.analysis.protein_g.rounded())

        let defaults = UserDefaults.standard
        let name = defaults.shortcutName.trimmingCharacters(in: .whitespacesAndNewlines)
        let sendJSON = defaults.shortcutSendJSON
        guard !name.isEmpty else { return }

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
        if sendJSON {
            let payload: [String: Any] = ["carbs": c, "fat": f, "protein": p]
            if let data = try? JSONSerialization.data(withJSONObject: payload),
               let json = String(data: data, encoding: .utf8) {
                items.append(.init(name: "input", value: "text"))
                items.append(.init(name: "text", value: json))
            }
        } else {
            // Plain text fallback
            let txt = "carbs=\(c);fat=\(f);protein=\(p)"
            items.append(.init(name: "input", value: "text"))
            items.append(.init(name: "text", value: txt))
        }

        comps.queryItems = items
        if let url = comps.url {
            UIApplication.shared.open(url)
        }
    }
}
