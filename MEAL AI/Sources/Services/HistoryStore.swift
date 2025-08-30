import Foundation

struct HistoryEntry: Identifiable, Codable {
    var id = UUID()
    var name: String
    var calories: Double
    var protein: Double
    var carbs: Double
    var fat: Double
    var date: Date
    var thumbnailData: Data
}

final class HistoryStore: ObservableObject {
    static let shared = HistoryStore()
    @Published private(set) var items: [HistoryEntry] = []

    private init() { load() }

    func add(entry: HistoryEntry) {
        items.insert(entry, at: 0)
        save()
    }

    func remove(_ id: UUID) {
        items.removeAll { $0.id == id }
        save()
    }

    private let fileURL: URL = {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return dir.appendingPathComponent("history.json")
    }()

    private func load() {
        if let data = try? Data(contentsOf: fileURL),
           let arr = try? JSONDecoder().decode([HistoryEntry].self, from: data) {
            items = arr
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(items) {
            try? data.write(to: fileURL)
        }
    }
}

