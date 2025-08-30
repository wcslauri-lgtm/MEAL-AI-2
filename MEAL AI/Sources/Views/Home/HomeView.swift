import SwiftUI
import UIKit

struct HomeView: View {
    @State private var path: [Destination] = []
    @State private var query = ""
    @State private var showCamera = false
    @State private var showBarcode = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var result: StageMealResult?
    @State private var currentImage: UIImage?
    @State private var currentImages: [UIImage] = []

    private enum Destination: Hashable, Codable {
        case favorites
        case history
        case settings
    }

    var body: some View {
        NavigationStack(path: $path) {
            ZStack(alignment: .bottom) {
                DS.Color.softCream.ignoresSafeArea()

                VStack(alignment: .leading, spacing: DS.Spacing.xl) {
                    Text("MEAL-AI")
                        .font(.largeTitle.bold())
                        .foregroundStyle(DS.Color.deepSlateBlue)

                    SearchBar(text: $query) {
                        runTextSearch()
                    }

                    if let e = errorMessage {
                        Text(e)
                            .foregroundColor(.red)
                    }

                    HStack(spacing: DS.Spacing.lg) {
                        QuickActionCard(title: "Identify", systemImage: "camera.viewfinder") {
                            showCamera = true
                        }
                        QuickActionCard(title: "History", systemImage: "list.bullet.rectangle") {
                            path.append(.history)
                        }
                        QuickActionCard(title: "Favorites", systemImage: "star.fill") {
                            path.append(.favorites)
                        }
                    }

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, DS.Spacing.xl)
                .padding(.top, DS.Spacing.xl)

                TabBarWithFab(
                    onBarcode: { showBarcode = true },
                    onFavorites: { path.append(.favorites) },
                    onCamera: { showCamera = true },
                    onHistory: { path.append(.history) },
                    onSettings: { path.append(.settings) }
                )
            }
            .sheet(isPresented: $showCamera) {
                CameraView { datas in
                    showCamera = false
                    currentImages = datas.compactMap { UIImage(data: $0) }
                    currentImage = currentImages.first
                    Task { await run(.images(datas)) }
                }
            }
            .sheet(isPresented: $showBarcode) {
                BarcodeScanView { code in
                    showBarcode = false
                    currentImage = nil
                    Task { await run(.barcode(code)) }
                }
            }
            .sheet(item: $result) { r in
                ResultView(result: r, image: currentImage)
            }
            .navigationDestination(for: Destination.self) { dest in
                switch dest {
                case .favorites:
                    FavoritesView()
                case .history:
                    HistoryView()
                case .settings:
                    SettingsView()
                }
            }
            .overlay {
                if isLoading {
                    AnalysisOverlayView(onCancel: { isLoading = false })
                }
            }
        }
    }

    private func runTextSearch() {
        currentImage = nil
        Task { await run(.text(query)) }
    }

    private func run(_ input: FoodSearchRouter.Input) async {
        guard UserDefaults.standard.foodSearchEnabled else {
            self.errorMessage = "Food Search ei ole päällä (Asetukset → Food Search)."
            return
        }
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        do {
            let stage = try await FoodSearchRouter.shared.run(input)
            self.result = stage
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    var onSubmit: () -> Void

    var body: some View {
        HStack(spacing: DS.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(DS.Color.deepSlateBlue)
            TextField("Search food", text: $text, onCommit: onSubmit)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .foregroundStyle(DS.Color.deepSlateBlue)
        }
        .padding(.vertical, DS.Spacing.sm)
        .padding(.horizontal, DS.Spacing.lg)
        .background(DS.Color.honeyBeige)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.pill, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.pill).stroke(.black.opacity(0.05))
        )
        .accessibilityLabel("Search food")
    }
}

struct QuickActionCard: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: DS.Spacing.sm) {
                Image(systemName: systemImage)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(DS.Color.deepForestGreen)
                Text(title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(DS.Color.deepSlateBlue)
            }
            .frame(maxWidth: .infinity, minHeight: 96)
            .background(DS.Color.honeyBeige)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(title))
    }
}

struct FabButton: View {
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: "camera.fill")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
                .padding(20)
                .background(DS.Color.rubyRed)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.15), radius: 8, y: 6)
        }
        .accessibilityLabel("Capture with camera")
    }
}

struct TabBarWithFab: View {
    var onBarcode: () -> Void
    var onFavorites: () -> Void
    var onCamera: () -> Void
    var onHistory: () -> Void
    var onSettings: () -> Void

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(DS.Color.honeyBeige)
                .frame(height: 74)
                .shadow(color: .black.opacity(0.08), radius: 10, y: -2)
                .overlay(
                    HStack {
                        IconButton("barcode.viewfinder", action: onBarcode)
                        IconButton("star", action: onFavorites)
                        Spacer().frame(width: 72)
                        IconButton("list.bullet.rectangle", action: onHistory)
                        IconButton("gearshape", action: onSettings)
                    }
                    .padding(.horizontal, DS.Spacing.xl)
                )
            FabButton(action: onCamera)
                .offset(y: -28)
        }
        .padding(.horizontal, DS.Spacing.lg)
        .padding(.bottom, DS.Spacing.md)
    }

    @ViewBuilder
    private func IconButton(_ name: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: name)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(DS.Color.deepSlateBlue)
                .frame(width: 36, height: 36)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView()
}

