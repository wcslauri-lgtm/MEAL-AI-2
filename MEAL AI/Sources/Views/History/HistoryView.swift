import SwiftUI
import UIKit

struct HistoryView: View {
    @EnvironmentObject var store: HistoryStore

    var body: some View {
        List {
            ForEach(store.items) { entry in
                HStack(spacing: DS.Spacing.md.rawValue) {
                    if let image = UIImage(data: entry.thumbnailData) {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm.rawValue))
                    }
                    VStack(alignment: .leading, spacing: DS.Spacing.xs.rawValue) {
                        Text(entry.name)
                            .font(DSTypography.body.weight(.semibold))
                            .foregroundStyle(DSColor.textPrimary)
                        Text("\(Int(entry.calories)) kcal • P \(Int(entry.protein))g • C \(Int(entry.carbs))g • F \(Int(entry.fat))g")
                            .font(DSTypography.caption)
                            .foregroundStyle(DSColor.textSecondary)
                    }
                    Spacer()
                    Text(entry.date, style: .date)
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
        .navigationTitle("Historia")
        .toolbar { EditButton() }
    }
}
