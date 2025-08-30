import SwiftUI
import PhotosUI

struct CameraView: View {
    var onImagesPicked: ([Data]) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var previews: [UIImage] = []
    @State private var showCamera = false

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    PhotosPicker(
                        selection: $pickerItems,
                        maxSelectionCount: 3 - previews.count,
                        matching: .images
                    ) {
                        VStack {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 44))
                            Text("Library")
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .disabled(previews.count >= 3)
                    .onChange(of: pickerItems) { newItems in
                        Task {
                            for item in newItems {
                                if let data = try? await item.loadTransferable(type: Data.self),
                                   let img = UIImage(data: data) {
                                    previews.append(img)
                                }
                            }
                            pickerItems = []
                        }
                    }

                    Button {
                        showCamera = true
                    } label: {
                        VStack {
                            Image(systemName: "camera")
                                .font(.system(size: 44))
                            Text("Camera")
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .disabled(previews.count >= 3)
                    .sheet(isPresented: $showCamera) {
                        ImagePicker(sourceType: .camera) { image in
                            if let image = image {
                                previews.append(image)
                            }
                        }
                    }
                }
                .frame(height: 120)

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
                    let datas = previews.compactMap { $0.jpegData(compressionQuality: 0.8) }
                    onImagesPicked(datas)
                    dismiss()
                }
                .disabled(previews.isEmpty)
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


