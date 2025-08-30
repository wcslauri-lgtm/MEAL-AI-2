//
//  DesignSystem.swift
//  MEAL-AI
//
//  Yhtenäiset design-tokenit (värit, typografia, mitat, animaatiot, komponenttityylit)
//

import SwiftUI
import UIKit

// MARK: - PALETTE (kiinteät heksat)
enum Palette {
  // Honeyed Neutrals
  static let honeyBeige      = Color(hex: "#E6D5B8")
  static let warmSand        = Color(hex: "#D4B483")
  static let softCream       = Color(hex: "#F5E9DA")
  // Blues
  static let skyBlue         = Color(hex: "#A8D5E2")
  static let crispBlue       = Color(hex: "#4A90E2")
  static let deepSlateBlue   = Color(hex: "#2C3E50")
  // Greens
  static let sageGreen       = Color(hex: "#B8C6A1")
  static let mintGreen       = Color(hex: "#98C9A3")
  static let deepForestGreen = Color(hex: "#2E5E4E")
  // Reds
  static let rubyRed         = Color(hex: "#A6002F")
  static let carmine         = Color(hex: "#D72638")
  static let berryAccent     = Color(hex: "#8B1E3F")
}

// MARK: - SEMANTTISET VÄRIT (light/dark mapping)
enum DSColor {
  // Taustat
  static var background: Color {
    Color.dynamic(light: Palette.softCream, dark: Color(.systemBackground))
  }
  static var surface: Color {
    Color.dynamic(light: Palette.honeyBeige, dark: Color(.secondarySystemBackground))
  }
  static var surfaceAlt: Color {
    Color.dynamic(light: Palette.warmSand.opacity(0.65), dark: Color(.tertiarySystemBackground))
  }

  // Tekstit & ikonit
  static var textPrimary: Color {
    Color.dynamic(light: Palette.deepSlateBlue, dark: .white)
  }
  static var textSecondary: Color {
    Color.dynamic(light: Palette.deepForestGreen, dark: Color.white.opacity(0.85))
  }
  static var disabled: Color { Color(.systemGray2) }

  // Korostukset
  static var primary: Color { Palette.rubyRed }          // CTA
  static var secondary: Color { Palette.carmine }        // toissijainen CTA
  static var selected: Color { Palette.crispBlue }       // valinta/hover
  static var success: Color { Palette.mintGreen }
  static var info: Color { Palette.skyBlue }
  static var warning: Color { Palette.warmSand }
  static var error: Color { Palette.rubyRed }

  // Viivat/rajat
  static var stroke: Color {
    Color.dynamic(light: Palette.warmSand.opacity(0.6), dark: Color.white.opacity(0.12))
  }
}

// MARK: - TYYLIT: mitat, kulmat, varjot, animaatiot
enum DS {
  enum Spacing: CGFloat {
    case xs = 4, sm = 8, md = 12, lg = 16, xl = 24, xxl = 32
  }

  enum Radius: CGFloat {
    case sm = 12, md = 16, lg = 20, pill = 28
  }

  enum Elevation {
    static let card = Shadow(color: .black.opacity(0.08), radius: 8, y: 4)
    static let fab  = Shadow(color: .black.opacity(0.15), radius: 10, y: 6)
  }

  enum Timing {
    static let fast: Double = 0.15
    static let normal: Double = 0.25
    static let slow: Double = 0.35
  }
}

// MARK: - TYPOGRAFIA
enum DSTypography {
  static var title: Font { .system(.title, design: .rounded).weight(.bold) }
  static var largeTitle: Font { .system(.largeTitle, design: .rounded).weight(.bold) }
  static var body: Font { .system(.body, design: .rounded) }
  static var caption: Font { .system(.caption, design: .rounded) }
}

// MARK: - YHTEISET KOMPONENTTITYYLIT

struct PrimaryButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(DSTypography.body.weight(.semibold))
      .foregroundStyle(Color.white)
      .padding(.vertical, DS.Spacing.md.rawValue)
      .frame(maxWidth: .infinity)
      .background(DSColor.primary.opacity(configuration.isPressed ? 0.9 : 1))
      .clipShape(RoundedRectangle(cornerRadius: DS.Radius.pill.rawValue, style: .continuous))
      .shadow(color: DS.Elevation.card.color, radius: DS.Elevation.card.radius, y: DS.Elevation.card.y)
      .animation(.easeOut(duration: DS.Timing.fast), value: configuration.isPressed)
  }
}

struct SecondaryButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(DSTypography.body.weight(.semibold))
      .foregroundStyle(.white)
      .padding(.vertical, DS.Spacing.md.rawValue)
      .frame(maxWidth: .infinity)
      .background(DSColor.secondary.opacity(configuration.isPressed ? 0.9 : 1))
      .clipShape(RoundedRectangle(cornerRadius: DS.Radius.pill.rawValue, style: .continuous))
  }
}

struct SurfaceCard<Content: View>: View {
  let content: Content
  init(@ViewBuilder content: () -> Content) { self.content = content() }
  var body: some View {
    VStack(spacing: 0) { content }
      .background(DSColor.surface)
      .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg.rawValue, style: .continuous))
      .shadow(color: DS.Elevation.card.color, radius: DS.Elevation.card.radius, y: DS.Elevation.card.y)
  }
}

struct BannerNotice: View {
  enum State { case info(String), success(String), error(String) }
  let state: State
  var body: some View {
    switch state {
    case .info(let t): banner(text: t, bg: DSColor.info)
    case .success(let t): banner(text: t, bg: DSColor.success)
    case .error(let t): banner(text: t, bg: DSColor.error)
    }
  }
  private func banner(text: String, bg: Color) -> some View {
    Text(text)
      .font(DSTypography.body.weight(.semibold))
      .foregroundStyle(.white)
      .padding(.vertical, 10)
      .frame(maxWidth: .infinity)
      .background(bg)
      .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md.rawValue, style: .continuous))
  }
}

// MARK: - Helper: varjo & dynaaminen väri
struct Shadow {
  let color: Color; let radius: CGFloat; let x: CGFloat = 0; let y: CGFloat
}

extension View {
  func shadow(_ shadow: Shadow) -> some View {
    self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
  }
}

extension Color {
  init(hex: String) {
    let s = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var n: UInt64 = 0; Scanner(string: s).scanHexInt64(&n)
    let r = Double((n >> 16) & 0xFF) / 255
    let g = Double((n >> 8) & 0xFF) / 255
    let b = Double(n & 0xFF) / 255
    self = Color(red: r, green: g, blue: b)
  }

  /// Luo light/dark -dynaamisen värin.
  static func dynamic(light: Color, dark: Color) -> Color {
    Color(UIColor { trait in
      trait.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
    })
  }
}
