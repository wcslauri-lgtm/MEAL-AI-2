
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
    @AppStorage("shortcutEnabled") private var shortcutEnabled: Bool = true

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
            Text(result.mealName ?? "Tulos")
                .font(.title2.bold())
                .foregroundStyle(DSColor.textPrimary)
            if let desc = result.mealDescription {
                Text(desc)
                    .font(.subheadline)
                    .foregroundStyle(DSColor.textSecondary)
            }

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
                    Text("Portions & Servings")
                        .font(.headline)
                        .foregroundStyle(DSColor.textPrimary)
                    Text(portion)
                        .foregroundStyle(DSColor.textSecondary)
                }
                .padding()
                .background(DSColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            if let notes = result.diabetesNotes {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Diabetes Notes")
                        .font(.headline)
                        .foregroundStyle(DSColor.textPrimary)
                    Text(notes)
                        .foregroundStyle(DSColor.textSecondary)
                }
                .padding()
                .background(DSColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            HStack {
                Button {
                    favName = result.mealName ?? "Suosikki"; showFavSheet = true
                } label: { Image(systemName: "star") }
                .buttonStyle(.bordered)

                Button {
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
                    if shortcutEnabled {
                        ShortcutsSender.sendToShortcuts(stage: editedResult)
                    }
                } label: {
                    Label(shortcutEnabled ? "Lähetä ja tallenna ateria" : "Tallenna ateria",
                          systemImage: shortcutEnabled ? "bolt" : "tray.and.arrow.down")
                }
                .buttonStyle(.borderedProminent)
            }
            Spacer()
        }
        .padding()
        .background(DSColor.background.ignoresSafeArea())
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
            Text(title)
                .font(.headline)
                .foregroundStyle(DSColor.textPrimary)
            HStack {
                AdjustButton(delta: -1, value: value)
                Text("\(value.wrappedValue) g")
                    .font(.title3.monospacedDigit())
                    .foregroundStyle(DSColor.textPrimary)
                AdjustButton(delta: 1, value: value)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(DSColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func macroPill(title: String, value: Int, unit: String) -> some View {
        VStack {
            Text("\(value) \(unit)")
                .font(.headline)
                .foregroundStyle(DSColor.textPrimary)
            Text(title)
                .font(.caption2)
                .foregroundStyle(DSColor.textSecondary)
        }
        .padding(8)
        .background(DSColor.surface)
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
