import SwiftUI

// MARK: - Design System "Nourrir"
// Palette: beige crème, vert sauge, terracotta — naturel & organique
// Typography: Fraunces (serif) + Inter (sans)

enum DS {
    // MARK: Light mode
    enum Light {
        static let bg           = Color(hex: "#F5F1EA")   // beige crème chaud
        static let bgElevated   = Color(hex: "#FBF8F2")
        static let surface      = Color(hex: "#FFFFFF")
        static let card         = Color(hex: "#FFFFFF")
        static let cardAlt      = Color(hex: "#EFE9DE")
        static let ink          = Color(hex: "#2A2823")
        static let inkSoft      = Color(hex: "#5B5750")
        static let inkMuted     = Color(hex: "#8C8578")
        static let line         = Color(hex: "#2A2823").opacity(0.08)
        static let lineStrong   = Color(hex: "#2A2823").opacity(0.14)
        static let sage         = Color(hex: "#6B7F5E")
        static let sageDeep     = Color(hex: "#4C5E42")
        static let sageLight    = Color(hex: "#D4DBC9")
        static let sageWash     = Color(hex: "#E8EAE0")
        static let terracotta   = Color(hex: "#C67B5C")
        static let terracottaDeep = Color(hex: "#A45E41")
        static let terracottaLight = Color(hex: "#F0D7C9")
        static let terre        = Color(hex: "#8B6F4E")
        static let beige        = Color(hex: "#E5DCC8")
        static let cream        = Color(hex: "#F0E9D9")
        static let warn         = Color(hex: "#D4A53A")
        static let danger       = Color(hex: "#B85450")
        static let good         = Color(hex: "#7A9163")
    }

    // MARK: Dark mode
    enum Dark {
        static let bg           = Color(hex: "#1A1714")
        static let bgElevated   = Color(hex: "#231F1A")
        static let surface      = Color(hex: "#2A2620")
        static let card         = Color(hex: "#2A2620")
        static let cardAlt      = Color(hex: "#352F28")
        static let ink          = Color(hex: "#F2EDE2")
        static let inkSoft      = Color(hex: "#BFB8A7")
        static let inkMuted     = Color(hex: "#8C8578")
        static let line         = Color(hex: "#F2EDE2").opacity(0.08)
        static let lineStrong   = Color(hex: "#F2EDE2").opacity(0.14)
        static let sage         = Color(hex: "#9BB089")
        static let sageDeep     = Color(hex: "#7A9070")
        static let sageLight    = Color(hex: "#3F4A37")
        static let sageWash     = Color(hex: "#2D332A")
        static let terracotta   = Color(hex: "#D89578")
        static let terracottaDeep = Color(hex: "#C67B5C")
        static let terracottaLight = Color(hex: "#4A342A")
        static let terre        = Color(hex: "#A48B6B")
        static let beige        = Color(hex: "#3A332A")
        static let cream        = Color(hex: "#2F2A22")
        static let warn         = Color(hex: "#E0B957")
        static let danger       = Color(hex: "#D07571")
        static let good         = Color(hex: "#9BB089")
    }
}

// MARK: - Adaptive palette (auto light/dark)
struct Palette {
    let bg:              Color
    let bgElevated:      Color
    let surface:         Color
    let card:            Color
    let cardAlt:         Color
    let ink:             Color
    let inkSoft:         Color
    let inkMuted:        Color
    let line:            Color
    let lineStrong:      Color
    let sage:            Color
    let sageDeep:        Color
    let sageLight:       Color
    let sageWash:        Color
    let terracotta:      Color
    let terracottaDeep:  Color
    let terracottaLight: Color
    let terre:           Color
    let beige:           Color
    let cream:           Color
    let warn:            Color
    let danger:          Color
    let good:            Color

    static let light = Palette(
        bg: DS.Light.bg, bgElevated: DS.Light.bgElevated,
        surface: DS.Light.surface, card: DS.Light.card, cardAlt: DS.Light.cardAlt,
        ink: DS.Light.ink, inkSoft: DS.Light.inkSoft, inkMuted: DS.Light.inkMuted,
        line: DS.Light.line, lineStrong: DS.Light.lineStrong,
        sage: DS.Light.sage, sageDeep: DS.Light.sageDeep,
        sageLight: DS.Light.sageLight, sageWash: DS.Light.sageWash,
        terracotta: DS.Light.terracotta, terracottaDeep: DS.Light.terracottaDeep,
        terracottaLight: DS.Light.terracottaLight,
        terre: DS.Light.terre, beige: DS.Light.beige, cream: DS.Light.cream,
        warn: DS.Light.warn, danger: DS.Light.danger, good: DS.Light.good
    )
    static let dark = Palette(
        bg: DS.Dark.bg, bgElevated: DS.Dark.bgElevated,
        surface: DS.Dark.surface, card: DS.Dark.card, cardAlt: DS.Dark.cardAlt,
        ink: DS.Dark.ink, inkSoft: DS.Dark.inkSoft, inkMuted: DS.Dark.inkMuted,
        line: DS.Dark.line, lineStrong: DS.Dark.lineStrong,
        sage: DS.Dark.sage, sageDeep: DS.Dark.sageDeep,
        sageLight: DS.Dark.sageLight, sageWash: DS.Dark.sageWash,
        terracotta: DS.Dark.terracotta, terracottaDeep: DS.Dark.terracottaDeep,
        terracottaLight: DS.Dark.terracottaLight,
        terre: DS.Dark.terre, beige: DS.Dark.beige, cream: DS.Dark.cream,
        warn: DS.Dark.warn, danger: DS.Dark.danger, good: DS.Dark.good
    )
}

// MARK: - Color hex init
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Phase cycle
enum CyclePhase: String, CaseIterable {
    case menstruelle  = "Menstruelle"
    case folliculaire = "Folliculaire"
    case ovulatoire   = "Ovulatoire"
    case lutéale      = "Lutéale"

    var emoji: String {
        switch self {
        case .menstruelle: return "○"
        case .folliculaire: return "◐"
        case .ovulatoire: return "●"
        case .lutéale: return "◑"
        }
    }
    func color(_ p: Palette) -> Color {
        switch self {
        case .menstruelle: return Color(hex: "#B85450")
        case .folliculaire: return p.sage
        case .ovulatoire: return p.warn
        case .lutéale: return p.terracotta
        }
    }
}
