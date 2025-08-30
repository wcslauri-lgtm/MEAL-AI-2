import SwiftUI

struct CameraPickerView: View {
    var onImagesPicked: ([Data]) -> Void
    var onCancel: () -> Void

    var body: some View {
        CustomCameraView(onImageCaptured: { image in
            if let data = image.jpegData(compressionQuality: 0.8) {
                onImagesPicked([data])
            }
        }, onCancel: onCancel)
        .ignoresSafeArea()
    }
}
