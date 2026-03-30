import SwiftUI

// MARK: - Dono Design System
// Identidade Visual: "Zelo Doméstico" — minimalismo acolhedor, japandi/escandinavo

struct DonoTheme {

    // MARK: - Colors
    struct Colors {
        // Backgrounds
        static let background = Color(hex: "FAFAF8")       // Branco Quente
        static let surface = Color(hex: "F5F0EB")           // Bege Quente / Creme
        static let surfaceSecondary = Color(hex: "EDE8E1")   // Bege mais escuro

        // Text
        static let textPrimary = Color(hex: "3D3229")       // Marrom Café
        static let textSecondary = Color(hex: "8C7E6F")     // Marrom Claro
        static let textTertiary = Color(hex: "B5A99A")      // Bege Escuro

        // Actions
        static let accent = Color(hex: "C4756E")            // Coral Suave / Rosa Velho
        static let accentLight = Color(hex: "D4948E")        // Coral Claro
        static let accentSubtle = Color(hex: "F5E6E4")       // Coral bem sutil (fundo de botão)

        // Semantic
        static let success = Color(hex: "7A9E7E")           // Verde Salvia
        static let successLight = Color(hex: "E8F0E9")       // Verde Salvia sutil
        static let warning = Color(hex: "D4A574")            // Âmbar Suave
        static let warningLight = Color(hex: "F5EDE4")       // Âmbar sutil
        static let error = Color(hex: "C4756E")              // Mesmo coral (erro = ação)

        // Dividers & Borders
        static let divider = Color(hex: "E8E2DB")
        static let border = Color(hex: "DDD6CD")

        // Overlay
        static let overlay = Color.black.opacity(0.3)
    }

    // MARK: - Typography
    struct Typography {
        // Playfair Display — títulos elegantes
        static func displayLarge(_ text: String) -> some View {
            Text(text)
                .font(.custom("PlayfairDisplay-Bold", size: 32))
                .foregroundColor(Colors.textPrimary)
                .tracking(-0.5)
        }

        static func displayMedium(_ text: String) -> some View {
            Text(text)
                .font(.custom("PlayfairDisplay-SemiBold", size: 24))
                .foregroundColor(Colors.textPrimary)
                .tracking(-0.3)
        }

        static func displaySmall(_ text: String) -> some View {
            Text(text)
                .font(.custom("PlayfairDisplay-Medium", size: 20))
                .foregroundColor(Colors.textPrimary)
        }

        // SF Pro / System — corpo e UI
        static let headline = Font.system(size: 17, weight: .semibold, design: .default)
        static let body = Font.system(size: 16, weight: .regular, design: .default)
        static let bodyMedium = Font.system(size: 16, weight: .medium, design: .default)
        static let subheadline = Font.system(size: 14, weight: .regular, design: .default)
        static let caption = Font.system(size: 12, weight: .regular, design: .default)
        static let captionMedium = Font.system(size: 12, weight: .medium, design: .default)

        // SF Mono — valores monetários
        static let moneyLarge = Font.system(size: 32, weight: .bold, design: .monospaced)
        static let moneyMedium = Font.system(size: 20, weight: .semibold, design: .monospaced)
        static let moneySmall = Font.system(size: 16, weight: .medium, design: .monospaced)
    }

    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        static let xxxl: CGFloat = 64
    }

    // MARK: - Radius
    struct Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let full: CGFloat = 999
    }

    // MARK: - Shadows
    struct Shadows {
        static let subtle = ShadowStyle(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        static let medium = ShadowStyle(color: .black.opacity(0.08), radius: 16, x: 0, y: 4)
        static let strong = ShadowStyle(color: .black.opacity(0.12), radius: 24, x: 0, y: 8)
    }

    // MARK: - Animation
    struct Animation {
        static let springGentle = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.8)
        static let springBouncy = SwiftUI.Animation.spring(response: 0.35, dampingFraction: 0.7)
        static let easeOut = SwiftUI.Animation.easeOut(duration: 0.25)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.5)
    }

    // MARK: - Haptics
    struct Haptics {
        static func light() {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }

        static func medium() {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }

        static func success() {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }

        static func error() {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }

        static func selection() {
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }
}

// MARK: - Shadow Style Helper
struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - View Modifier for Shadows
extension View {
    func donoShadow(_ style: ShadowStyle) -> some View {
        self.shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }
}

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Currency Formatting
extension Decimal {
    var brlFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.currencyCode = "BRL"
        return formatter.string(from: self as NSDecimalNumber) ?? "R$ 0,00"
    }
}

extension Double {
    var brlFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.currencyCode = "BRL"
        return formatter.string(from: NSNumber(value: self)) ?? "R$ 0,00"
    }
}
