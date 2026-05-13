import SwiftUI

// MARK: - Accent palette

struct CoveAccentPalette {
    let accent: Color
    let soft: Color
    let tint: Color
}

let coveAccents: [String: CoveAccentPalette] = [
    "sage":     CoveAccentPalette(accent: Color(hex: "6B9B7E"), soft: Color(hex: "E8F3EB"), tint: Color(hex: "F3FAF5")),
    "indigo":   CoveAccentPalette(accent: Color(hex: "6C5CE7"), soft: Color(hex: "EBE8FC"), tint: Color(hex: "F5F3FE")),
    "rose":     CoveAccentPalette(accent: Color(hex: "E05A47"), soft: Color(hex: "FAEAE6"), tint: Color(hex: "FCF4F2")),
    "graphite": CoveAccentPalette(accent: Color(hex: "5A5A6E"), soft: Color(hex: "EBEBF0"), tint: Color(hex: "F5F5F8")),
]

// MARK: - Theme

struct CoveTheme {
    let dark: Bool
    let accentName: String

    var palette: CoveAccentPalette { coveAccents[accentName] ?? coveAccents["sage"]! }
    var accent: Color { palette.accent }
    var accentSoft: Color { palette.soft }
    var accentTint: Color { palette.tint }

    // Semantic colors — same names as the JS prototype
    var bg: Color            { dark ? Color(UIColor.systemBackground)                : Color(UIColor.systemGroupedBackground) }
    var surface: Color       { dark ? Color(UIColor.secondarySystemBackground)       : Color(UIColor.systemBackground) }
    var surface2: Color      { dark ? Color(UIColor.tertiarySystemBackground)        : Color(UIColor.secondarySystemGroupedBackground) }
    var text: Color          { dark ? .white : .black }
    var text2: Color         { Color(.label).opacity(0.5) }
    var text3: Color         { Color(.label).opacity(0.25) }
    var sep: Color           { Color(.separator) }
    var red: Color           { Color(.systemRed) }
    var orange: Color        { Color(.systemOrange) }
    var yellow: Color        { Color(.systemYellow) }
    var green: Color         { Color(.systemGreen) }
    var blue: Color          { Color(.systemBlue) }
    var purple: Color        { Color(.systemPurple) }
    var systemFill: Color    { Color(UIColor.systemFill) }
    var hairline: Color      { Color(.separator).opacity(0.5) }
}

// MARK: - Environment values

private struct ThemeKey: EnvironmentKey {
    static let defaultValue = CoveTheme(dark: false, accentName: "sage")
}
extension EnvironmentValues {
    var coveTheme: CoveTheme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

// MARK: - Convenience Color alias

extension Color {
    // Dynamic accent pulled from environment — use in views that have @Environment(\.coveTheme)
    static var coveAccent: Color { Color(hex: "6B9B7E") } // sage fallback
}

// MARK: - Font shorthands

extension Font {
    static func sfPro(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }
    static func sfRounded(size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
    static func sfMono(size: CGFloat) -> Font {
        .system(size: size, weight: .regular, design: .monospaced)
    }
}
