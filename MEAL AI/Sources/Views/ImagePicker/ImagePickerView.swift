import SwiftUI
import PhotosUI

struct ImagePickerView: View {
    var onImagesPicked: ([Data]) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var images: [UIImage] = []

    var body: some View {
        NavigationStack {
            VStack {
                if images.isEmpty {
                    Text("Select up to three images.")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    List {
                        ForEach(images.indices, id: \.self) { index in
                            Image(uiImage: images[index])
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 120)
                                .clipped()
                        }
                        .onDelete(perform: delete)
                        .onMove(perform: move)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Images")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton().disabled(images.count < 2)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { done() }
                        .disabled(images.isEmpty)
                }
                ToolbarItem(placement: .bottomBar) {
                    PhotosPicker(selection: $selectedItems, maxSelectionCount: 3, matching: .images) {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
            .onChange(of: selectedItems) { newItems in
                Task { await loadImages(from: newItems) }
            }
        }
    }

    private func loadImages(from items: [PhotosPickerItem]) async {
        var newImages: [UIImage] = []
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                newImages.append(image)
            }
        }
        await MainActor.run { images = newImages }
    }

    private func delete(at offsets: IndexSet) {
        images.remove(atOffsets: offsets)
        selectedItems.remove(atOffsets: offsets)
    }

    private func move(from offsets: IndexSet, to destination: Int) {
        images.move(fromOffsets: offsets, toOffset: destination)
        selectedItems.move(fromOffsets: offsets, toOffset: destination)
    }

    private func done() {
        let datas = images.compactMap { $0.jpegData(compressionQuality: 0.8) }
        onImagesPicked(datas)
        dismiss()
    }
}
