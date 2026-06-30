import SwiftUI

// MARK: - Hex Color
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6: (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default: (r, g, b) = (91, 91, 214)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255)
    }
}

// MARK: - Brand Colors
extension Color {
    static let formaPrimary   = Color(hex: "#5b5bd6")
    static let formaPrimary2  = Color(hex: "#7a5bdc")
    static let formaAccentMid = Color(hex: "#6a5bd6")

    static let formaBg        = Color(hex: "#f2f2f7")
    static let formaCard      = Color.white
    static let formaInputBg   = Color(hex: "#e3e3ea")
    static let formaGhostBg   = Color(hex: "#f7f7fb")
    static let formaFaintBg   = Color(hex: "#fafaff")

    static let formaText      = Color(hex: "#1c1c1e")
    static let formaDarkText  = Color(hex: "#3a3a44")
    static let formaSecondary = Color(hex: "#8e8e93")
    static let formaTertiary  = Color(hex: "#9a9aa8")
    static let formaDisabled  = Color(hex: "#c1c1c9")

    static let formaSuccess   = Color(hex: "#34c759")
    static let formaDanger    = Color(hex: "#ff3b30")
    static let formaWarning   = Color(hex: "#e8870b")
    static let formaLink      = Color(hex: "#5b5bd6")

    static let formaDivider   = Color(hex: "#ececf1")
    static let formaSubDiv    = Color(hex: "#f0f0f4")

    static let formaStar      = Color(hex: "#f5a623")
}

// MARK: - Gradients
extension LinearGradient {
    static let formaPrimary = LinearGradient(
        colors: [.formaPrimary, .formaPrimary2],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let formaPrimaryHero = LinearGradient(
        colors: [Color(hex: "#5b5bd6"), Color(hex: "#6a5bd6"), Color(hex: "#7a5bdc")],
        startPoint: .top, endPoint: .bottom
    )
    static let formaPrimaryDiag = LinearGradient(
        colors: [Color(hex: "#5b5bd6"), Color(hex: "#7a5bdc")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
}

// MARK: - Form color palette
let formaColorPalette: [(hex: String, name: String)] = [
    ("#5b5bd6", "Purple"),
    ("#2bb3a3", "Teal"),
    ("#f0a23b", "Gold"),
    ("#e8638a", "Pink"),
    ("#57b865", "Green"),
    ("#8a7de8", "Lavender"),
]

// MARK: - Typography helpers
extension Font {
    static func formaTitle() -> Font { .system(size: 32, weight: .black, design: .default) }
    static func formaHeading() -> Font { .system(size: 23, weight: .black, design: .default) }
    static func formaModalTitle() -> Font { .system(size: 19, weight: .black, design: .default) }
    static func formaBody() -> Font { .system(size: 16, weight: .semibold, design: .default) }
    static func formaCallout() -> Font { .system(size: 15, weight: .semibold, design: .default) }
    static func formaCaption() -> Font { .system(size: 13, weight: .regular, design: .default) }
    static func formaLabel() -> Font { .system(size: 12, weight: .bold, design: .default) }
    static func formaChip() -> Font { .system(size: 11, weight: .bold, design: .default) }
}

// MARK: - Shadow helpers
extension View {
    func cardShadow() -> some View {
        shadow(color: .black.opacity(0.05), radius: 1.5, x: 0, y: 1)
    }

    func elevatedShadow() -> some View {
        shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
    }

    func deepShadow() -> some View {
        shadow(color: Color.formaPrimary.opacity(0.5), radius: 12, x: 0, y: 8)
    }

    func floatingShadow() -> some View {
        self
            .shadow(color: .black.opacity(0.35), radius: 20, x: 0, y: 14)
            .shadow(color: .black.opacity(0.04), radius: 0.5, x: 0, y: 0)
    }

    func sheetShadow() -> some View {
        shadow(color: .black.opacity(0.2), radius: 24, x: 0, y: -10)
    }

    func fabShadow() -> some View {
        shadow(color: Color.formaPrimary.opacity(0.65), radius: 14, x: 0, y: 10)
    }
}

// MARK: - TapFade ButtonStyle
struct TapFadeStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.55 : 1.0)
            .animation(.easeOut(duration: 0.08), value: configuration.isPressed)
    }
}

// MARK: - Corner radius helpers
extension View {
    func cardShape() -> some View {
        clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    func buttonShape(_ radius: CGFloat = 13) -> some View {
        clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
}

// MARK: - Backdrop blur overlay
struct DimBackground: View {
    var opacity: Double = 0.32
    var body: some View {
        Color.black.opacity(opacity)
            .ignoresSafeArea()
    }
}

// MARK: - Sheet drag handle
struct SheetHandle: View {
    var body: some View {
        Capsule()
            .fill(Color(hex: "#e0e0e6"))
            .frame(width: 38, height: 5)
    }
}
