import SwiftUI
import PhotosUI

struct CameraView: View {
    var onImagePicked: (Data) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var pickerItem: PhotosPickerItem? = nil
    @State private var preview: UIImage? = nil
    @State private var showCamera = false

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    PhotosPicker(
                        selection: $pickerItem,
                        matching: .images
                    ) {
                        VStack {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 44))
                            Text("Library")
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .onChange(of: pickerItem) { newItem in
                        Task {
                            if let item = newItem,
                               let data = try? await item.loadTransferable(type: Data.self),
                               let img = UIImage(data: data) {
                                preview = img
                            }
                            pickerItem = nil
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
                    .sheet(isPresented: $showCamera) {
                        ImagePicker(sourceType: .camera) { image in
                            if let image = image {
                                preview = image
                            }
                        }
                    }
                }
                .frame(height: 120)

                if let preview = preview {
                    Image(uiImage: preview)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                } else {
                    Rectangle()
                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4]))
                        .frame(width: 200, height: 200)
                }

                Button("Done") {
                    if let data = preview?.jpegData(compressionQuality: 0.8) {
                        onImagePicked(data)
                    }
                    dismiss()
                }
                .disabled(preview == nil)
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


