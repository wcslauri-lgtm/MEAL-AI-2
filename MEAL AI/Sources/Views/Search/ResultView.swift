
import SwiftUI
import Foundation

struct ResultView: View {
    let result: StageMealResult
    @State private var favName: String
    @State private var showFavSheet: Bool
    @State private var carbs: Int
    @State private var protein: Int
    @State private var fat: Int

    init(result: StageMealResult) {
        self.result = result
        _favName = State(initialValue: "")
        _showFavSheet = State(initialValue: false)
        _carbs = State(initialValue: Int(result.analysis.carbs_g.rounded()))
        _protein = State(initialValue: Int(result.analysis.protein_g.rounded()))
        _fat = State(initialValue: Int(result.analysis.fat_g.rounded()))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(result.mealName ?? "Tulos").font(.title2.bold())

            HStack(spacing: 16) {
                macroEditor("Carbs", $carbs)
                macroEditor("Protein", $protein)
                macroEditor("Fat", $fat)
            }

            HStack {
                Button {
                    favName = result.mealName ?? "Suosikki"; showFavSheet = true
                } label: { Label("Lisää suosikkeihin", systemImage: "star") }
                .buttonStyle(.bordered)

                Button {
                    ShortcutsSender.sendToShortcuts(stage: editedResult)
                } label: { Label("Lähetä iAPS (Shortcut)", systemImage: "bolt") }
                .buttonStyle(.borderedProminent)
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Tulos")
        .sheet(isPresented: $showFavSheet) {
            NavigationStack {
                Form { TextField("Suosikin nimi", text: $favName) }
                    .navigationTitle("Suosikki")
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Tallenna") {
                                FavoritesStore.shared.add(name: favName, result: editedResult); showFavSheet = false
                            }
                        }
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Peruuta") { showFavSheet = false }
                        }
                    }
            }
        }
    }

    private var editedResult: StageMealResult {
        let totals = NutritionTotals(carbs_g: Double(carbs),
                                    protein_g: Double(protein),
                                    fat_g: Double(fat))
        return StageMealResult(mealName: result.mealName, analysis: totals)
    }

    private func macroEditor(_ title: String, _ value: Binding<Int>) -> some View {
        VStack {
            Text(title).font(.headline)
            HStack {
                AdjustButton(delta: -1, value: value)
                Text("\(value.wrappedValue) g").font(.title3.monospacedDigit())
                AdjustButton(delta: 1, value: value)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct AdjustButton: View {
    let delta: Int
    @Binding var value: Int
    @State private var timer: Timer?
    @State private var isRepeating = false

    var body: some View {
        Button(delta > 0 ? "+1" : "-1") {
            if !isRepeating { value += delta }
        }
        .onLongPressGesture(minimumDuration: 0.8, pressing: { pressing in
            if pressing {
                timer?.invalidate()
                timer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false) { _ in
                    isRepeating = true
                    timer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
                        value += delta * 5
                    }
                }
            } else {
                timer?.invalidate()
                timer = nil
                isRepeating = false
            }
        }, perform: {})
    }
}
