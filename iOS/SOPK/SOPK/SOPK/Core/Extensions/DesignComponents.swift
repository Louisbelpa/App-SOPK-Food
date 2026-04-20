import SwiftUI

// MARK: - Anti-Inflammatory Badge
// Série de 10 barres verticales colorées selon le score
struct AntiInflamBadge: View {
    let score: Int  // 1–10
    let palette: Palette
    var size: BadgeSize = .md

    enum BadgeSize { case sm, md }

    private var barColor: Color {
        score >= 9 ? palette.sageDeep : score >= 7 ? palette.sage : palette.terre
    }
    private var barHeight: CGFloat { size == .sm ? 11 : 14 }
    private var barWidth: CGFloat  { size == .sm ? 3  : 4  }

    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: size == .sm ? 2 : 2.5) {
                ForEach(0..<10, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(i < score ? barColor : palette.line)
                        .frame(width: barWidth, height: barHeight)
                }
            }
            Text(" \(score)/10")
                .font(.system(size: size == .sm ? 10 : 11, weight: .medium, design: .monospaced))
                .foregroundColor(palette.inkSoft)
        }
    }
}

// MARK: - Phase Chip
struct PhaseChip: View {
    let phase: String
    let palette: Palette
    var small: Bool = false

    private var phaseEnum: CyclePhase? { CyclePhase(rawValue: phase) }
    private var phaseColor: Color { phaseEnum?.color(palette) ?? palette.sage }
    private var phaseEmoji: String { phaseEnum?.emoji ?? "◐" }

    var body: some View {
        HStack(spacing: 5) {
            Text(phaseEmoji)
                .font(.system(size: small ? 9 : 10))
            Text(phase)
                .font(.system(size: small ? 10 : 11, weight: .medium))
        }
        .foregroundColor(phaseColor)
        .padding(.horizontal, small ? 8 : 10)
        .padding(.vertical, small ? 3 : 4)
        .background(palette.surface)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(phaseColor.opacity(0.2), lineWidth: 1))
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let label: String
    let isActive: Bool
    let palette: Palette
    var icon: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .medium))
                }
                Text(label)
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundColor(isActive ? .white : palette.ink)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isActive ? palette.sageDeep : palette.surface)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(isActive ? Color.clear : palette.line, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Tag Pill
struct TagPill: View {
    let text: String
    let foreground: Color
    let background: Color

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(foreground)
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background(background)
            .clipShape(Capsule())
    }
}

// MARK: - Recipe Plate Illustration
// Illustrations SVG stylisées reproduites en SwiftUI Canvas, variant selon seed
struct RecipePlateView: View {
    let seed: Int
    let palette: Palette

    private struct Pal {
        let base, accent, veg, dot: Color
    }
    private var p: Pal {
        let palettes: [Pal] = [
            Pal(base: Color(hex: "#E8D4B8"), accent: Color(hex: "#C67B5C"), veg: Color(hex: "#7A9163"), dot: Color(hex: "#8B6F4E")),
            Pal(base: Color(hex: "#D4DBC9"), accent: Color(hex: "#6B7F5E"), veg: Color(hex: "#C67B5C"), dot: Color(hex: "#4C5E42")),
            Pal(base: Color(hex: "#F0D7C9"), accent: Color(hex: "#A45E41"), veg: Color(hex: "#7A9163"), dot: Color(hex: "#8B6F4E")),
            Pal(base: Color(hex: "#EFE9DE"), accent: Color(hex: "#6B7F5E"), veg: Color(hex: "#C67B5C"), dot: Color(hex: "#A45E41")),
            Pal(base: Color(hex: "#E5DCC8"), accent: Color(hex: "#8B6F4E"), veg: Color(hex: "#9BB089"), dot: Color(hex: "#C67B5C")),
            Pal(base: Color(hex: "#F5E6D3"), accent: Color(hex: "#7A9163"), veg: Color(hex: "#C67B5C"), dot: Color(hex: "#4C5E42")),
        ]
        return palettes[seed % palettes.count]
    }

    var body: some View {
        Canvas { ctx, size in
            let s = size.width / 200
            ctx.fill(Path(CGRect(origin: .zero, size: size)), with: .color(palette.cardAlt.opacity(0.3)))
            switch seed % 6 {
            case 0: drawBowl(ctx, s, p)
            case 1: drawToast(ctx, s, p)
            case 2: drawSoup(ctx, s, p)
            case 3: drawSalad(ctx, s, p)
            case 4: drawPan(ctx, s, p)
            default: drawSmoothie(ctx, s, p)
            }
        }
    }

    private func drawBowl(_ ctx: GraphicsContext, _ s: CGFloat, _ p: Pal) {
        ctx.fill(circle(100, 100, 75, s), with: .color(p.base))
        var blob = Path(); blob.move(to: pt(50, 95, s))
        blob.addCurve(to: pt(100, 70, s), control1: pt(70, 60, s), control2: pt(100, 60, s))
        blob.addCurve(to: pt(150, 95, s), control1: pt(130, 60, s), control2: pt(150, 60, s))
        blob.addCurve(to: pt(100, 125, s), control1: pt(130, 130, s), control2: pt(130, 130, s))
        blob.addCurve(to: pt(50, 95, s), control1: pt(70, 130, s), control2: pt(50, 130, s))
        ctx.fill(blob, with: .color(p.veg.opacity(0.85)))
        ctx.fill(circle(78, 88, 4, s), with: .color(p.accent))
        ctx.fill(circle(118, 92, 5, s), with: .color(p.accent))
        ctx.fill(circle(95, 108, 3, s), with: .color(p.dot))
    }

    private func drawToast(_ ctx: GraphicsContext, _ s: CGFloat, _ p: Pal) {
        let rect = Path(roundedRect: CGRect(x: 35*s, y: 70*s, width: 130*s, height: 70*s), cornerRadius: 12*s)
        ctx.fill(rect, with: .color(p.base))
        let inner = Path(roundedRect: CGRect(x: 40*s, y: 75*s, width: 120*s, height: 60*s), cornerRadius: 8*s)
        ctx.fill(inner, with: .color(p.accent.opacity(0.3)))
        ctx.fill(ellipse(75, 100, 22, 18, s), with: .color(p.veg))
        ctx.fill(ellipse(75, 100, 10, 7, s), with: .color(p.dot.opacity(0.6)))
        ctx.fill(ellipse(125, 108, 20, 16, s), with: .color(p.veg.opacity(0.85)))
        ctx.fill(circle(100, 85, 3, s), with: .color(p.accent))
    }

    private func drawSoup(_ ctx: GraphicsContext, _ s: CGFloat, _ p: Pal) {
        ctx.fill(circle(100, 100, 80, s), with: .color(p.base.opacity(0.6)))
        ctx.fill(circle(100, 100, 68, s), with: .color(p.accent.opacity(0.7)))
        ctx.fill(circle(100, 100, 55, s), with: .color(p.accent))
        ctx.fill(circle(85, 110, 4, s), with: .color(p.veg))
        ctx.fill(circle(115, 105, 4, s), with: .color(p.veg))
        ctx.fill(circle(105, 90, 3, s), with: .color(p.dot))
    }

    private func drawSalad(_ ctx: GraphicsContext, _ s: CGFloat, _ p: Pal) {
        ctx.fill(circle(100, 100, 78, s), with: .color(p.base))
        var blob = Path(); blob.move(to: pt(60, 90, s))
        blob.addCurve(to: pt(100, 80, s), control1: pt(80, 70, s), control2: pt(80, 80, s))
        blob.addCurve(to: pt(140, 95, s), control1: pt(130, 80, s), control2: pt(140, 80, s))
        blob.addCurve(to: pt(65, 110, s), control1: pt(135, 115, s), control2: pt(80, 125, s))
        ctx.fill(blob, with: .color(p.veg))
        ctx.fill(circle(78, 95, 8, s), with: .color(p.accent))
        ctx.fill(circle(115, 88, 7, s), with: .color(p.accent.opacity(0.85)))
        ctx.fill(circle(125, 108, 6, s), with: .color(p.dot))
    }

    private func drawPan(_ ctx: GraphicsContext, _ s: CGFloat, _ p: Pal) {
        ctx.fill(ellipse(100, 105, 78, 60, s), with: .color(p.base))
        ctx.fill(ellipse(100, 105, 68, 50, s), with: .color(p.dot.opacity(0.25)))
        ctx.fill(ellipse(100, 102, 40, 22, s), with: .color(p.accent))
        ctx.fill(circle(68, 85, 5, s), with: .color(p.veg))
        ctx.fill(circle(135, 120, 5, s), with: .color(p.veg))
        ctx.fill(circle(80, 125, 3, s), with: .color(p.veg))
    }

    private func drawSmoothie(_ ctx: GraphicsContext, _ s: CGFloat, _ p: Pal) {
        var glass = Path()
        glass.move(to: pt(70, 50, s)); glass.addLine(to: pt(130, 50, s))
        glass.addLine(to: pt(125, 160, s))
        glass.addQuadCurve(to: pt(75, 160, s), control: pt(100, 175, s))
        glass.closeSubpath()
        ctx.fill(glass, with: .color(p.base))
        var inner = Path()
        inner.move(to: pt(72, 55, s)); inner.addLine(to: pt(128, 55, s))
        inner.addLine(to: pt(123, 155, s))
        inner.addQuadCurve(to: pt(77, 155, s), control: pt(100, 168, s))
        inner.closeSubpath()
        ctx.fill(inner, with: .color(p.accent.opacity(0.85)))
        ctx.fill(circle(90, 80, 4, s), with: .color(p.base))
        ctx.fill(circle(110, 95, 3, s), with: .color(p.base))
        let straw = Path(roundedRect: CGRect(x: 95*s, y: 35*s, width: 10*s, height: 22*s), cornerRadius: 3*s)
        ctx.fill(straw, with: .color(p.veg))
    }

    private func circle(_ cx: CGFloat, _ cy: CGFloat, _ r: CGFloat, _ s: CGFloat) -> Path {
        Path(ellipseIn: CGRect(x: (cx-r)*s, y: (cy-r)*s, width: r*2*s, height: r*2*s))
    }
    private func ellipse(_ cx: CGFloat, _ cy: CGFloat, _ rx: CGFloat, _ ry: CGFloat, _ s: CGFloat) -> Path {
        Path(ellipseIn: CGRect(x: (cx-rx)*s, y: (cy-ry)*s, width: rx*2*s, height: ry*2*s))
    }
    private func pt(_ x: CGFloat, _ y: CGFloat, _ s: CGFloat) -> CGPoint {
        CGPoint(x: x*s, y: y*s)
    }
}

// MARK: - NourriTabBar
struct NourriTabBar: View {
    @Binding var active: AppTab
    let palette: Palette
    let isDark: Bool

    enum AppTab: String, CaseIterable {
        case home    = "Accueil"
        case search  = "Recherche"
        case plan    = "Plan"
        case cart    = "Courses"
        case profile = "Profil"

        var icon: String {
            switch self {
            case .home: return "house"
            case .search: return "magnifyingglass"
            case .plan: return "calendar"
            case .cart: return "cart"
            case .profile: return "person"
            }
        }
        var iconFill: String { icon + ".fill" }
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            HStack(spacing: 0) {
                ForEach(NourriTabBar.AppTab.allCases, id: \.self) { tab in
                    let on = active == tab
                    Button { active = tab } label: {
                        VStack(spacing: 2) {
                            Image(systemName: on ? tab.iconFill : tab.icon)
                                .font(.system(size: 22, weight: on ? .semibold : .regular))
                            Text(tab.rawValue)
                                .font(.system(size: 10, weight: on ? .semibold : .medium))
                                .kerning(0.1)
                        }
                        .foregroundColor(on ? palette.sageDeep : palette.inkMuted)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 8)
                        .background(Color.clear)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 9)
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(isDark ? Color(hex: "#2A2620").opacity(0.92) : Color.white.opacity(0.92))
                    .shadow(color: .black.opacity(isDark ? 0.4 : 0.08), radius: 10, y: 4)
                    .overlay(RoundedRectangle(cornerRadius: 32).stroke(palette.line, lineWidth: 0.5))
            )
            .padding(.horizontal, 14)
            .padding(.bottom, 28)
        }
        .frame(height: 110)
        .ignoresSafeArea(edges: .bottom)
        .allowsHitTesting(true)
    }
}
