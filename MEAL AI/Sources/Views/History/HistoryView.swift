import SwiftUI
import UIKit

struct HistoryView: View {
    @EnvironmentObject var store: HistoryStore

    var body: some View {
        List {
            ForEach(store.items) { entry in
                HStack {
                    if let image = UIImage(data: entry.thumbnailData) {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    VStack(alignment: .leading) {
                        Text(entry.name)
                        Text("\(Int(entry.calories)) kcal • P \(Int(entry.protein))g • C \(Int(entry.carbs))g • F \(Int(entry.fat))g")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text(entry.date, style: .date)
                        .font(.caption2)
                }
            }
            .onDelete { idx in
                idx.map { store.items[$0].id }.forEach { store.remove($0) }
            }
        }
        .navigationTitle("Historia")
        .toolbar { EditButton() }
    }
}
