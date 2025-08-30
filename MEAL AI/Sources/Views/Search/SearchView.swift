
import SwiftUI
import UIKit

struct SearchView: View {
    @State private var query: String = ""
    @State private var showingScanner = false
    @State private var showingCamera = false
    @State private var isListening = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var result: StageMealResult?
    @State private var currentImage: UIImage?

    @ObservedObject private var favs = FavoritesStore.shared

    var body: some View {
        ZStack {
        VStack(spacing: 12) {
            HStack {
                TextField("Hae ruokaa nimellä…", text: $query, onCommit: runTextSearch)
                    .textFieldStyle(.roundedBorder)
                Button { toggleVoice() } label: {
                    Image(systemName: isListening ? "mic.circle.fill" : "mic.circle")
                        .font(.title2)
                }
                .help("Äänihaku")
            }.padding(.horizontal)

            HStack {
                Button { showingScanner = true } label: {
                    Label("Viivakoodi", systemImage: "barcode.viewfinder")
                }.buttonStyle(.bordered)
                Button {
                    showingCamera = true
                    currentImage = nil
                } label: {
                    Label("Kamera", systemImage: "camera")
                }.buttonStyle(.bordered)
                Spacer()
            }
            .padding(.horizontal)

            if let e = errorMessage { Text(e).foregroundColor(.red).padding(.horizontal) }

            if !favs.items.isEmpty {
                List {
                    Section("Suosikit") {
                        ForEach(favs.items) { f in
                            Button { result = f.result } label: {
                                HStack {
                                    Text(f.name)
                                    Spacer()
                                    let t = f.result.analysis
                                    Text("\(Int(t.carbs_g))g C").foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            } else {
                Spacer()
            }
        }
        .navigationTitle("Ruokahaku")
        .sheet(isPresented: $showingScanner) {
            BarcodeScanView { code in
                showingScanner = false
                currentImage = nil
                Task { await run(.barcode(code)) }
            }
        }
        .sheet(isPresented: $showingCamera) {
            CameraView { data in
                showingCamera = false
                currentImage = UIImage(data: data)
                Task { await run(.image(data)) }
            }
        }
        .sheet(item: $result) { r in ResultView(result: r, image: currentImage) }
        .onDisappear { stopVoice() }

        if isLoading {
            AnalysisOverlayView(onCancel: { isLoading = false })
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

    private func toggleVoice() { if isListening { stopVoice() } else { startVoice() } }
    private func startVoice() {
        isListening = true
        Task {
            try? await VoiceSearchService.shared.authorize()
            try? VoiceSearchService.shared.start { text in self.query = text }
        }
    }
    private func stopVoice() { isListening = false; VoiceSearchService.shared.stop() }
}
