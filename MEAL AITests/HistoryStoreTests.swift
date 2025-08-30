import Testing
@testable import MEAL_AI

struct HistoryStoreTests {
    @Test func addAndRemoveEntry() async throws {
        let store = HistoryStore.shared
        let initial = store.items.count
        let entry = HistoryEntry(name: "Test", calories: 1, protein: 1, carbs: 1, fat: 1, date: Date(), thumbnailData: Data())
        store.add(entry: entry)
        #expect(store.items.count == initial + 1)
        store.remove(entry.id)
        #expect(store.items.count == initial)
    }
}
