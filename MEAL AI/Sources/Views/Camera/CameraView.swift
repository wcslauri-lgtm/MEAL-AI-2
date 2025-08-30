import SwiftUI
import PhotosUI

struct CameraView: View {
    var onImagesPicked: ([Data]) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var items: [PhotosPickerItem] = []
    @State private var previews: [UIImage] = []

    var body: some View {
        NavigationView {
            VStack {
                PhotosPicker(
                    selection: $items,
                    maxSelectionCount: 3,
                    matching: .images
                ) {
                    VStack {
                        Image(systemName: "camera")
                            .font(.system(size: 60))
                        Text("Take or select up to three photos")
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .photosPickerStyle(.automatic)
                .onChange(of: items) { newItems in
                    Task {
                        previews = []
                        for item in newItems.prefix(3) {
                            if let data = try? await item.loadTransferable(type: Data.self),
                               let img = UIImage(data: data) {
                                previews.append(img)
                            }
                        }
                    }
                }

                HStack {
                    ForEach(0..<3, id: \.self) { idx in
                        if idx < previews.count {
                            Image(uiImage: previews[idx])
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipped()
                        } else {
                            Rectangle()
                                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4]))
                                .frame(width: 60, height: 60)
                        }
                    }
                }
                .padding(.vertical, 8)

                Button("Done") {
                    Task {
                        var datas: [Data] = []
                        for item in items {
                            if let data = try? await item.loadTransferable(type: Data.self) {
                                datas.append(data)
                            }
                        }
                        onImagesPicked(datas)
                        dismiss()
                    }
                }
                .disabled(items.isEmpty)
                .padding(.bottom)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

