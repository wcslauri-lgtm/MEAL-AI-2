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
                DSColor.background.ignoresSafeArea()

                VStack(alignment: .leading, spacing: DS.Spacing.xl.rawValue) {
                    Text("MEAL-AI")
                        .font(DSTypography.largeTitle)
                        .foregroundStyle(DSColor.textPrimary)

                    SearchBar(text: $query) {
                        runTextSearch()
                    }

                    HStack(spacing: DS.Spacing.lg.rawValue) {
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

                    if let e = errorMessage {
                        Text(e)
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColor.error)
                    }

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, DS.Spacing.xl.rawValue)
                .padding(.top, DS.Spacing.xl.rawValue)

                TabBarWithFab(
                    onBarcode: { showBarcode = true },
                    onFavorites: { path.append(.favorites) },
                    onCamera: { showCamera = true },
                    onHistory: { path.append(.history) },
                    onSettings: { path.append(.settings) }
                )

                if isLoading {
                    AnalysisOverlayView(onCancel: { isLoading = false })
                }
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
        }
    }

    @MainActor
    private func runTextSearch() {
        currentImage = nil
        Task { await run(.text(query)) }
    }

    @MainActor
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
        HStack(spacing: DS.Spacing.sm.rawValue) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(DSColor.textPrimary)
            TextField("Search food", text: $text, onCommit: onSubmit)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .foregroundStyle(DSColor.textPrimary)
        }
        .padding(.vertical, DS.Spacing.sm.rawValue)
        .padding(.horizontal, DS.Spacing.lg.rawValue)
        .background(DSColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.pill.rawValue, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.pill.rawValue).stroke(DSColor.stroke)
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
            VStack(spacing: DS.Spacing.sm.rawValue) {
                Image(systemName: systemImage)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Palette.deepForestGreen)
                Text(title)
                    .font(DSTypography.body.weight(.semibold))
                    .foregroundStyle(DSColor.textPrimary)
            }
            .frame(maxWidth: .infinity, minHeight: 96)
            .background(DSColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg.rawValue, style: .continuous))
            .shadow(DS.Elevation.card)
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
                .background(DSColor.primary)
                .clipShape(Circle())
                .shadow(DS.Elevation.fab)
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
            RoundedRectangle(cornerRadius: DS.Radius.pill.rawValue, style: .continuous)
                .fill(DSColor.surface)
                .frame(height: 74)
                .shadow(color: DS.Elevation.card.color, radius: DS.Elevation.card.radius, y: -2)
                .overlay(
                    HStack {
                        IconButton("barcode.viewfinder", action: onBarcode)
                        Spacer()
                        IconButton("star", action: onFavorites)
                        Spacer().frame(width: 96)
                        IconButton("list.bullet.rectangle", action: onHistory)
                        Spacer()
                        IconButton("gearshape", action: onSettings)
                    }
                    .padding(.horizontal, DS.Spacing.lg.rawValue)
                )
            FabButton(action: onCamera)
                .offset(y: -28)
        }
        .padding(.horizontal, DS.Spacing.lg.rawValue)
        .padding(.bottom, DS.Spacing.md.rawValue)
    }

    @ViewBuilder
    private func IconButton(_ name: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: name)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(DSColor.textPrimary)
                .frame(width: 36, height: 36)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView()
}

