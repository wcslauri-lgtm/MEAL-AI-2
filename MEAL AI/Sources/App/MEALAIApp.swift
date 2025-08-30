
import SwiftUI

@main
struct MEALAIApp: App {
    @State private var showShortcutAlert = false
    @State private var shortcutMessage = ""

    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationStack { SearchView() }
                    .tabItem { Label("Haku", systemImage: "magnifyingglass") }
                NavigationStack { FavoritesView() }
                    .tabItem { Label("Suosikit", systemImage: "star") }
                NavigationStack { SettingsView() }
                    .tabItem { Label("Asetukset", systemImage: "gearshape") }
            }
            .onOpenURL { url in
                guard url.scheme == "mealai" else { return }
                switch url.host {
                case "done":
                    shortcutMessage = "Ravintoarvojen siirto onnistui"
                    showShortcutAlert = true
                case "error":
                    shortcutMessage = "Shortcuttin suoritus epäonnistui"
                    showShortcutAlert = true
                default:
                    break
                }
            }
            .alert(shortcutMessage, isPresented: $showShortcutAlert) {
                Button("OK", role: .cancel) { }
            }
        }
    }
}
