import SwiftUI
import PhotosUI
import UIKit

struct CameraPickerView: View {
    var onImagesPicked: ([Data]) -> Void
    var onCancel: () -> Void
    @State private var galleryItem: PhotosPickerItem?

    var body: some View {
        ZStack {
            CameraControllerWrapper(onImageCaptured: { image in
                if let data = image.jpegData(compressionQuality: 0.8) {
                    onImagesPicked([data])
                }
            }, onCancel: onCancel)
            .ignoresSafeArea()

            VStack {
                Spacer()
                HStack {
                    PhotosPicker(selection: $galleryItem, matching: .images) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .onChange(of: galleryItem) { item in
                        Task { await loadFromPicker(item) }
                    }
                    Spacer()
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        }
    }

    private func loadFromPicker(_ item: PhotosPickerItem?) async {
        guard let item,
              let data = try? await item.loadTransferable(type: Data.self) else { return }
        await MainActor.run {
            onImagesPicked([data])
        }
    }
}

private struct CameraControllerWrapper: UIViewControllerRepresentable {
    var onImageCaptured: (UIImage) -> Void
    var onCancel: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onImageCaptured: onImageCaptured, onCancel: onCancel)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) { }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var onImageCaptured: (UIImage) -> Void
        var onCancel: () -> Void

        init(onImageCaptured: @escaping (UIImage) -> Void, onCancel: @escaping () -> Void) {
            self.onImageCaptured = onImageCaptured
            self.onCancel = onCancel
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                onImageCaptured(image)
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            onCancel()
        }
    }
}

