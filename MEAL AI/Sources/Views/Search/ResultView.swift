
import SwiftUI
import Foundation
import UIKit

struct ResultView: View {
    let result: StageMealResult
    let image: UIImage?
    @State private var favName: String
    @State private var showFavSheet: Bool
    @State private var carbs: Int
    @State private var protein: Int
    @State private var fat: Int
    @State private var showingHistoryAlert = false
    @EnvironmentObject var historyStore: HistoryStore

    init(result: StageMealResult, image: UIImage?) {
        self.result = result
        self.image = image
        _favName = State(initialValue: "")
        _showFavSheet = State(initialValue: false)
        _carbs = State(initialValue: Int(result.analysis.carbs_g.rounded()))
        _protein = State(initialValue: Int(result.analysis.protein_g.rounded()))
        _fat = State(initialValue: Int(result.analysis.fat_g.rounded()))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(result.mealName ?? "Tulos").font(.title2.bold())
            if let desc = result.mealDescription { Text(desc).font(.subheadline) }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    macroPill(title: "Carbs", value: Int(result.analysis.carbs_g.rounded()), unit: "g")
                    if let cal = result.analysis.calories_kcal {
                        macroPill(title: "Calories", value: Int(cal.rounded()), unit: "cal")
                    }
                    macroPill(title: "Fat", value: Int(result.analysis.fat_g.rounded()), unit: "g")
                    if let fiber = result.analysis.fiber_g {
                        macroPill(title: "Fiber", value: Int(fiber.rounded()), unit: "g")
                    }
                    macroPill(title: "Protein", value: Int(result.analysis.protein_g.rounded()), unit: "g")
                }
            }

            HStack(spacing: 16) {
                macroEditor("Carbs", $carbs)
                macroEditor("Protein", $protein)
                macroEditor("Fat", $fat)
            }

            if let portion = result.portionDescription {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Portions & Servings").font(.headline)
                    Text(portion)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            if let notes = result.diabetesNotes {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Diabetes Notes").font(.headline)
                    Text(notes)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            HStack {
                Button("Tallenna ateria") {
                    let resized = image?.resized(to: CGSize(width: 100, height: 100))
                    let entry = HistoryEntry(
                        name: result.mealName ?? "Ateria",
                        calories: editedResult.analysis.calories_kcal ?? 0,
                        protein: editedResult.analysis.protein_g,
                        carbs: editedResult.analysis.carbs_g,
                        fat: editedResult.analysis.fat_g,
                        date: Date(),
                        thumbnailData: resized?.pngData() ?? Data()
                    )
                    historyStore.add(entry: entry)
                    showingHistoryAlert = true
                }
                .buttonStyle(.bordered)

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
        .alert("Ateria tallennettu", isPresented: $showingHistoryAlert) {
            Button("OK", role: .cancel) {}
        }
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
                                    fat_g: Double(fat),
                                    calories_kcal: result.analysis.calories_kcal,
                                    fiber_g: result.analysis.fiber_g)
        return StageMealResult(mealName: result.mealName,
                               mealDescription: result.mealDescription,
                               portionDescription: result.portionDescription,
                               diabetesNotes: result.diabetesNotes,
                               analysis: totals)
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

    private func macroPill(title: String, value: Int, unit: String) -> some View {
        VStack {
            Text("\(value) \(unit)").font(.headline)
            Text(title).font(.caption2)
        }
        .padding(8)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
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
