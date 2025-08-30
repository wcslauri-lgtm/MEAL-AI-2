
import SwiftUI

struct FavoritesView: View {
    @ObservedObject var store = FavoritesStore.shared

    var body: some View {
        List {
            ForEach(store.items) { f in
                VStack(alignment: .leading, spacing: DS.Spacing.xs.rawValue) {
                    Text(f.name)
                        .font(DSTypography.body.weight(.semibold))
                        .foregroundStyle(DSColor.textPrimary)
                    let t = f.result.analysis
                    Text("Carbs \(Int(t.carbs_g))g · Protein \(Int(t.protein_g))g · Fat \(Int(t.fat_g))g")
                        .font(DSTypography.caption)
                        .foregroundStyle(DSColor.textSecondary)
                }
                .listRowBackground(DSColor.surface)
            }
            .onDelete { idx in
                idx.map { store.items[$0].id }.forEach { store.remove($0) }
            }
        }
        .scrollContentBackground(.hidden)
        .background(DSColor.background.ignoresSafeArea())
        .navigationTitle("Suosikit")
        .toolbar { EditButton() }
    }
}
