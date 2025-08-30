import SwiftUI

enum DS {
  enum Color {
    static let honeyBeige      = SwiftUI.Color(hex: "#E6D5B8")
    static let warmSand        = SwiftUI.Color(hex: "#D4B483")
    static let softCream       = SwiftUI.Color(hex: "#F5E9DA")

    static let skyBlue         = SwiftUI.Color(hex: "#A8D5E2")
    static let crispBlue       = SwiftUI.Color(hex: "#4A90E2")
    static let deepSlateBlue   = SwiftUI.Color(hex: "#2C3E50")

    static let sageGreen       = SwiftUI.Color(hex: "#B8C6A1")
    static let mintGreen       = SwiftUI.Color(hex: "#98C9A3")
    static let deepForestGreen = SwiftUI.Color(hex: "#2E5E4E")

    static let rubyRed         = SwiftUI.Color(hex: "#A6002F")
    static let carmine         = SwiftUI.Color(hex: "#D72638")
    static let berryAccent     = SwiftUI.Color(hex: "#8B1E3F")
  }

  enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
  }

  enum Radius {
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let pill: CGFloat = 28
  }

  enum Shadow {
    struct Style {
      let color: SwiftUI.Color
      let radius: CGFloat
      let x: CGFloat
      let y: CGFloat
    }
    static let card = Style(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
  }
}

extension View {
  func shadow(_ style: DS.Shadow.Style) -> some View {
    shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
  }
}

// HEX color convenience
extension SwiftUI.Color {
  init(hex: String) {
    let s = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var num: UInt64 = 0
    Scanner(string: s).scanHexInt64(&num)
    let r = Double((num >> 16) & 0xFF) / 255.0
    let g = Double((num >> 8) & 0xFF) / 255.0
    let b = Double(num & 0xFF) / 255.0
    self.init(red: r, green: g, blue: b)
  }
}

