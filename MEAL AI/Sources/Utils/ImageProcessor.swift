import UIKit
import CoreImage

enum ImageProcessor {
    static func process(_ image: UIImage, angle: Double? = nil) -> ImagePayload? {
        let oriented = image.normalizedOrientation()
        let resized = oriented.resized(maxSide: 1024)
        guard let data = resized.jpegDataInRange(minKB: 300, maxKB: 600) else { return nil }
        let luma = resized.averageLuma()
        return ImagePayload(data: data, luma: luma, timestamp: Date(), angle: angle)
    }
}

private extension UIImage {
    func normalizedOrientation() -> UIImage {
        if imageOrientation == .up { return self }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalized ?? self
    }

    func resized(maxSide: CGFloat) -> UIImage {
        let aspect = size.width / size.height
        var newSize: CGSize
        if size.width > size.height {
            newSize = CGSize(width: maxSide, height: maxSide / aspect)
        } else {
            newSize = CGSize(width: maxSide * aspect, height: maxSide)
        }
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    func jpegDataInRange(minKB: Int, maxKB: Int) -> Data? {
        var lower: CGFloat = 0.0
        var upper: CGFloat = 1.0
        var data: Data?
        for _ in 0..<6 {
            let q = (lower + upper) / 2
            data = jpegData(compressionQuality: q)
            guard let d = data else { return nil }
            let kb = d.count / 1024
            if kb > maxKB {
                upper = q
            } else if kb < minKB {
                lower = q
            } else {
                break
            }
        }
        return data
    }

    func averageLuma() -> Double {
        guard let ciImage = CIImage(image: self) else { return 0 }
        let context = CIContext()
        let extent = ciImage.extent
        let filter = CIFilter.areaAverage()
        filter.inputImage = ciImage
        filter.extent = extent
        guard let output = filter.outputImage else { return 0 }
        var bitmap = [UInt8](repeating: 0, count: 4)
        context.render(output,
                       toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: nil)
        let r = Double(bitmap[0]) / 255.0
        let g = Double(bitmap[1]) / 255.0
        let b = Double(bitmap[2]) / 255.0
        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    }
}
