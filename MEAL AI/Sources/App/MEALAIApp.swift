
import SwiftUI

@main
struct MEALAIApp: App {
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
        }
    }
}
