
import SwiftUI

@main
struct MEALAIApp: App {
    @AppStorage("appLanguage") private var appLanguage: String = "FI"
    @State private var showShortcutAlert = false
    @State private var shortcutMessageKey = ""

    var body: some Scene {
        WindowGroup {
            HomeView()
                .onOpenURL { url in
                    guard url.scheme == "mealai" else { return }
                    switch url.host {
                    case "done":
                        shortcutMessageKey = "app.shortcut.success"
                        showShortcutAlert = true
                    case "error":
                        shortcutMessageKey = "app.shortcut.error"
                        showShortcutAlert = true
                    default:
                        break
                    }
                }
                .alert(LocalizedStringKey(shortcutMessageKey), isPresented: $showShortcutAlert) {
                    Button(LocalizedStringKey("app.shortcut.ok"), role: .cancel) { }
                }
                .environmentObject(HistoryStore.shared)
                .environment(\.locale, Locale(identifier: appLanguage.lowercased()))
        }
    }
}
