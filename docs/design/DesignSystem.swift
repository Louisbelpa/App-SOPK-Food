//
//  DesignSystem.swift — Ovéa
//
//  Design system v2 « cosy » (voir docs/design/02-ui.md et docs/design/tokens.json).
//  À coller tel quel dans le projet Xcode (cible iOS 18, Swift 6, mode strict).
//  Aucune dépendance, aucun Asset Catalog requis : les couleurs sont adaptatives
//  via UIColor(dynamicProvider:) et gèrent light / dark / « Augmenter le contraste ».
//
//  Règles d'usage :
//  - Toujours passer par ces tokens (jamais de Color(red:…) dans les vues).
//  - Typo uniquement via Dynamic Type (OveaFont.*), jamais de taille fixe
//    (exception : le minuteur, qui reste indexé sur .largeTitle via @ScaledMetric).
//  - Une couleur ne porte jamais seule une information : icône + libellé.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Couleurs

/// Construit une couleur adaptative light / dark (+ variantes contraste élevé facultatives).
/// Les valeurs sont des hex sRGB 0xRRGGBB, identiques à tokens.json.
nonisolated private func adaptive(
    _ light: UInt32,
    _ dark: UInt32,
    highContrastLight: UInt32? = nil,
    highContrastDark: UInt32? = nil
) -> Color {
    #if canImport(UIKit)
    // Closure @Sendable : UIKit peut la résoudre hors du main thread (Swift 6).
    let provider = UIColor { @Sendable traits in
        let isDark = traits.userInterfaceStyle == .dark
        let isHigh = traits.accessibilityContrast == .high
        let hex: UInt32
        switch (isDark, isHigh) {
        case (false, false): hex = light
        case (true, false): hex = dark
        case (false, true): hex = highContrastLight ?? light
        case (true, true): hex = highContrastDark ?? dark
        }
        return UIColor(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
    return Color(uiColor: provider)
    #else
    return Color(
        red: Double((light >> 16) & 0xFF) / 255,
        green: Double((light >> 8) & 0xFF) / 255,
        blue: Double(light & 0xFF) / 255
    )
    #endif
}

/// Tokens sémantiques V2 « cosy ». Contrastes vérifiés par palette.py (texte ≥ 4.5:1, UI ≥ 3:1).
enum OveaColor {
    // Fonds : lin ensoleillé (clair) / chocolat noir (sombre). Jamais de #FFFFFF pur.
    static let background = adaptive(0xFBF3E7, 0x1C1512)
    static let surface = adaptive(0xFFFAF2, 0x271E1A)
    static let surfaceMuted = adaptive(0xF4E7D5, 0x33281F)
    static let surfaceRaised = adaptive(0xFFFCF7, 0x2E241F)
    static let separator = adaptive(0xEEE1CF, 0x3A2E27)
    static let border = adaptive(0x937F69, 0x8F7D6F, highContrastLight: 0x64543F, highContrastDark: 0xB3A294)

    // Texte : bruns chauds
    static let textPrimary = adaptive(0x2F221B, 0xF6EBDD)
    static let textSecondary = adaptive(0x6A5545, 0xCDBBA9, highContrastLight: 0x4E3D31, highContrastDark: 0xE3D5C6)
    static let textTertiary = adaptive(0x6F5B4B, 0xAA988A, highContrastLight: 0x4E3D31, highContrastDark: 0xE3D5C6)

    // Interaction : terracotta « argile cuite ». Nature / calme : sauge dorée. Mise en avant : miel.
    static let accent = adaptive(0xA1482A, 0xF0A27D, highContrastLight: 0x7E3418, highContrastDark: 0xF8BE9F)
    static let onAccent = adaptive(0xFFFFFF, 0x2B1307)
    static let accentSoft = adaptive(0xF9E3D5, 0x45291D)
    static let onAccentSoft = adaptive(0x7A3219, 0xF9C5AA)
    static let leaf = adaptive(0x556A2C, 0xBFD08F)
    static let leafSoft = adaptive(0xEBEDD5, 0x2E3119)
    static let highlight = adaptive(0x855810, 0xEDC47C)
    static let onHighlight = adaptive(0xFFFFFF, 0x2B1D06)
    static let highlightSoft = adaptive(0xFBEACB, 0x3D2E17)

    // États
    static let success = adaptive(0x4E6727, 0xBBCD8C)
    static let successSoft = adaptive(0xE9EDD3, 0x2C301B)
    static let warning = adaptive(0x8A5300, 0xF0C173)
    static let warningSoft = adaptive(0xFCEBCB, 0x3D2C12)
    static let info = adaptive(0x3D5F6B, 0xA2C8D0)
    static let infoSoft = adaptive(0xE4ECE9, 0x1F2E30)
    /// Réservé aux actions destructives (supprimer mes données). Jamais sur une donnée corporelle.
    static let destructive = adaptive(0xA3172B, 0xFFB1AA)

    // Cycle : prune, nettement distincte du terracotta de l'accent
    static let period = adaptive(0x86345F, 0xE8A5C5, highContrastLight: 0x6B2149, highContrastDark: 0xF3C2D9)
    static let onPeriod = adaptive(0xFFFFFF, 0x3A0F25)
    static let periodSoft = adaptive(0xF6E2EA, 0x3F2131)
    static let spotting = adaptive(0xA9688A, 0xCA8DAC)
}

/// Teintes « de saison » : une paire premier plan / fond doux, réutilisée par les catégories.
struct OveaTint: Sendable, Hashable {
    let foreground: Color
    let soft: Color

    static let miel = OveaTint(foreground: adaptive(0x7E5512, 0xE7C37D), soft: adaptive(0xF9EACB, 0x3B2D17))
    static let olive = OveaTint(foreground: adaptive(0x566529, 0xC3CF8F), soft: adaptive(0xEDECD2, 0x2F3019))
    static let lagon = OveaTint(foreground: adaptive(0x2C625C, 0x8ECFC2), soft: adaptive(0xDFEDE6, 0x1C3230))
    static let ardoise = OveaTint(foreground: adaptive(0x544878, 0xC0B6E4), soft: adaptive(0xEDE5EC, 0x30273A))
    static let cacao = OveaTint(foreground: adaptive(0x74482F, 0xDEB391), soft: adaptive(0xF3E3D6, 0x3A281D))
    static let lavande = OveaTint(foreground: adaptive(0x694E86, 0xCEB9E3), soft: adaptive(0xEFE5F1, 0x31263A))
    static let sauge = OveaTint(foreground: OveaColor.leaf, soft: OveaColor.leafSoft)
    static let abricot = OveaTint(foreground: OveaColor.onAccentSoft, soft: OveaColor.accentSoft)
}

/// Catégories de repas (clés de recipes.json → types_repas).
enum MealCategory: String, CaseIterable, Identifiable, Sendable {
    case petitDejeuner = "petit_dejeuner", dejeuner, diner, collation
    var id: String { rawValue }

    var label: String {
        switch self {
        case .petitDejeuner: "Petit-déjeuner"
        case .dejeuner: "Déjeuner"
        case .diner: "Dîner"
        case .collation: "Collation"
        }
    }
    var symbol: String {
        switch self {
        case .petitDejeuner: "cup.and.saucer"
        case .dejeuner: "takeoutbag.and.cup.and.straw"
        case .diner: "moon.stars"
        case .collation: "carrot"
        }
    }
    var tint: OveaTint {
        switch self {
        case .petitDejeuner: .miel
        case .dejeuner: .olive
        case .diner: .ardoise
        case .collation: .cacao
        }
    }
}

/// Catégories d'activité (clés de workouts.json → sessions[].type).
enum ActivityCategory: String, CaseIterable, Identifiable, Sendable {
    case strength, cardio, mobility, breathing, hiit
    var id: String { rawValue }

    var label: String {
        switch self {
        case .strength: "Renforcement"
        case .cardio: "Cardio doux"
        case .mobility: "Mobilité"
        case .breathing: "Respiration"
        case .hiit: "Fractionné"
        }
    }
    var symbol: String {
        switch self {
        case .strength: "figure.strengthtraining.functional"
        case .cardio: "figure.walk"
        case .mobility: "figure.yoga"
        case .breathing: "wind"
        case .hiit: "figure.mixed.cardio"
        }
    }
    var tint: OveaTint {
        switch self {
        case .strength: .cacao
        case .cardio: .miel
        case .mobility: .lagon
        case .breathing: .lavande
        case .hiit: .ardoise
        }
    }
}

// MARK: - Typographie (Dynamic Type uniquement)

enum OveaFont {
    /// Titres éditoriaux : Fraunces (OFL, axe SOFT=100) si elle est embarquée, sinon New York.
    /// Embarquer : ajouter `Fraunces-VariableFont_SOFT,WONK,opsz,wght.ttf` (+ Italic) au target,
    /// déclarer les fichiers dans Info.plist > UIAppFonts. Le nom PostScript est « Fraunces ».
    static let display = editorial(size: 34, relativeTo: .largeTitle, fallback: .largeTitle, weight: .semibold)
    static let title1 = editorial(size: 28, relativeTo: .title, fallback: .title, weight: .semibold)
    static let title2 = editorial(size: 22, relativeTo: .title2, fallback: .title2, weight: .semibold)
    static let quote = editorial(size: 20, relativeTo: .title3, fallback: .title3, weight: .regular).italic()
    /// SF Pro — interface.
    static let title3 = Font.system(.title3, weight: .semibold)
    static let headline = Font.headline
    static let body = Font.body
    static let bodyEmphasis = Font.body.weight(.medium)
    static let callout = Font.callout
    static let subheadline = Font.subheadline
    static let footnote = Font.footnote
    static let caption = Font.caption.weight(.medium)
    /// Sur-titre de section (à combiner avec .textCase(.uppercase) et .tracking(0.6)).
    static let overline = Font.caption2.weight(.semibold)
    /// SF Pro Rounded — boutons, options d'énergie, chiffres : plus doux au toucher.
    static let button = Font.system(.headline, design: .rounded, weight: .semibold)
    static let metric = Font.system(.title2, design: .rounded, weight: .semibold).monospacedDigit()

    /// `Font.custom(_:size:relativeTo:)` suit Dynamic Type. Repli New York si la police n'est pas embarquée.
    private static func editorial(
        size: CGFloat,
        relativeTo style: Font.TextStyle,
        fallback: Font.TextStyle,
        weight: Font.Weight
    ) -> Font {
        #if canImport(UIKit)
        if UIFont(name: "Fraunces", size: size) != nil {
            return Font.custom("Fraunces", size: size, relativeTo: style).weight(weight)
        }
        #endif
        return Font.system(fallback, design: .serif, weight: weight)
    }
}

/// Minuteur du lecteur de séance : grand, arrondi, chiffres tabulaires, qui suit Dynamic Type.
struct OveaTimerStyle: ViewModifier {
    @ScaledMetric(relativeTo: .largeTitle) private var size: CGFloat = 72
    func body(content: Content) -> some View {
        content
            .font(.system(size: size, weight: .light, design: .rounded).monospacedDigit())
            .contentTransition(.numericText(countsDown: true))
    }
}

extension View {
    func oveaTimerStyle() -> some View { modifier(OveaTimerStyle()) }

    /// Sur-titre de section : « POUR TOI AUJOURD'HUI ».
    func oveaOverline() -> some View {
        font(OveaFont.overline)
            .textCase(.uppercase)
            .tracking(0.6)
            .foregroundStyle(OveaColor.textSecondary)
    }
}

// MARK: - Espacements, rayons, élévation

/// Grille 4/8 pt.
enum OveaSpacing {
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 48
    static let screenMargin: CGFloat = 20
    static let cardPadding: CGFloat = 16
    static let sectionGap: CGFloat = 32
    static let minTapTarget: CGFloat = 44
}

/// Toujours avec `style: .continuous`.
enum OveaRadius {
    static let xs: CGFloat = 8     // pastilles, badges
    static let sm: CGFloat = 12    // champs, petites vignettes
    static let md: CGFloat = 18    // options d'énergie, vignettes
    static let lg: CGFloat = 24    // cartes, bannières
    static let xl: CGFloat = 32    // héros, sheets custom
    // Boutons et chips : Capsule()
}

enum OveaElevation: Sendable {
    case flat, card, raised
}

private struct OveaElevationModifier: ViewModifier {
    let level: OveaElevation
    @Environment(\.colorScheme) private var scheme
    /// Ombres teintées brun (jamais grises) : plus chaudes, plus diffuses.
    private static let warmShadow = Color(red: 0x5C / 255, green: 0x34 / 255, blue: 0x1C / 255)

    func body(content: Content) -> some View {
        switch (level, scheme) {
        case (.flat, _):
            content
        case (.card, .dark):
            content.shadow(color: .black.opacity(0.28), radius: 16, y: 6)
        case (.card, _):
            content
                .shadow(color: Self.warmShadow.opacity(0.04), radius: 1, y: 1)
                .shadow(color: Self.warmShadow.opacity(0.07), radius: 20, y: 8)
        case (.raised, .dark):
            content.shadow(color: .black.opacity(0.40), radius: 28, y: 10)
        case (.raised, _):
            content.shadow(color: Self.warmShadow.opacity(0.12), radius: 32, y: 12)
        }
    }
}

extension View {
    func oveaElevation(_ level: OveaElevation) -> some View { modifier(OveaElevationModifier(level: level)) }
}

// MARK: - Composant : OveaCard

/// Carte de contenu. `tint` donne un fond doux (catégorie, mise en avant) au lieu du blanc.
struct OveaCard<Content: View>: View {
    var tint: OveaTint?
    var padding: CGFloat = OveaSpacing.cardPadding
    @ViewBuilder var content: Content

    var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(padding)
            .background(
                tint?.soft ?? OveaColor.surface,
                in: RoundedRectangle(cornerRadius: OveaRadius.lg, style: .continuous)
            )
            .oveaElevation(tint == nil ? .card : .flat)
    }
}

// MARK: - Composant : OveaChip (filtre / choix)

/// Chip de filtre ou de choix. Cible tactile ≥ 44 pt même si la capsule visible fait 36 pt.
struct OveaChip: View {
    let title: String
    var systemImage: String?
    @Binding var isSelected: Bool

    var body: some View {
        Button {
            isSelected.toggle()
        } label: {
            HStack(spacing: OveaSpacing.xs + 2) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.bold))
                        .transition(.opacity.combined(with: .scale))
                } else if let systemImage {
                    Image(systemName: systemImage).font(.caption.weight(.semibold))
                }
                Text(title).font(OveaFont.subheadline.weight(.medium))
            }
            .padding(.horizontal, OveaSpacing.md + 2)
            .frame(minHeight: 36)
        }
        .buttonStyle(OveaChipStyle(isSelected: isSelected))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .sensoryFeedback(.selection, trigger: isSelected)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

private struct OveaChipStyle: ButtonStyle {
    let isSelected: Bool
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(isSelected ? OveaColor.onAccentSoft : OveaColor.textPrimary)
            .background(isSelected ? OveaColor.accentSoft : OveaColor.surfaceMuted, in: Capsule())
            .overlay {
                Capsule().strokeBorder(isSelected ? OveaColor.accent : .clear, lineWidth: 1.5)
            }
            .padding(.vertical, 4)              // 36 pt visibles + 8 = 44 pt de cible tactile
            .contentShape(Rectangle())
            .opacity(isEnabled ? (configuration.isPressed ? 0.75 : 1) : 0.45)
    }
}

// MARK: - Composant : OveaPrimaryButton

/// Bouton principal pleine largeur (1 par écran au maximum).
struct OveaPrimaryButton: View {
    let title: String
    var systemImage: String?
    var isLoading = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: OveaSpacing.sm) {
                if isLoading {
                    ProgressView().tint(OveaColor.onAccent)
                } else if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
            }
        }
        .buttonStyle(OveaPrimaryButtonStyle())
        .disabled(isLoading)
        .accessibilityLabel(isLoading ? "\(title), en cours" : title)
    }
}

struct OveaPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(OveaFont.button)
            .foregroundStyle(isEnabled ? OveaColor.onAccent : OveaColor.textSecondary)
            .frame(maxWidth: .infinity, minHeight: 54)
            .padding(.horizontal, OveaSpacing.lg)
            .background(isEnabled ? OveaColor.accent : OveaColor.surfaceMuted, in: Capsule())
            .shadow(color: isEnabled ? OveaColor.accent.opacity(0.25) : .clear, radius: 12, y: 6)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

/// Bouton secondaire (contour terracotta), même gabarit.
struct OveaSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(OveaFont.button)
            .foregroundStyle(OveaColor.accent)
            .frame(maxWidth: .infinity, minHeight: 54)
            .background(
                Capsule()
                    .strokeBorder(OveaColor.accent, lineWidth: 1.5)
            )
            .contentShape(Capsule())
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

// MARK: - Composant : EnergyPicker

/// Niveau d'énergie déclaré. Volontairement mono-teinte (terracotta) : pas de feu rouge/vert,
/// une énergie basse n'est pas « mauvaise ».
enum EnergyLevel: Int, CaseIterable, Identifiable, Sendable {
    case basse = 1, moyenne, bonne
    var id: Int { rawValue }
    var label: String {
        switch self {
        case .basse: "Basse"
        case .moyenne: "Moyenne"
        case .bonne: "Bonne"
        }
    }
    var hint: String {
        switch self {
        case .basse: "On fait simple aujourd'hui"
        case .moyenne: "Un peu d'élan"
        case .bonne: "Envie de bouger"
        }
    }
}

/// Trois barres croissantes ; `level` barres sont pleines.
struct EnergyGlyph: View {
    let level: Int
    var filled: Color = OveaColor.accent
    var empty: Color = OveaColor.border

    var body: some View {
        HStack(alignment: .bottom, spacing: 3) {
            ForEach(1...3, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(index <= level ? filled : .clear)
                    .overlay {
                        RoundedRectangle(cornerRadius: 2, style: .continuous)
                            .strokeBorder(index <= level ? filled : empty, lineWidth: 1.5)
                    }
                    .frame(width: 7, height: CGFloat(6 + index * 5))
            }
        }
        .accessibilityHidden(true)
    }
}

struct EnergyPicker: View {
    @Binding var selection: EnergyLevel?

    var body: some View {
        HStack(spacing: OveaSpacing.sm) {
            ForEach(EnergyLevel.allCases) { level in
                let isOn = selection == level
                Button {
                    selection = isOn ? nil : level
                } label: {
                    VStack(spacing: OveaSpacing.sm) {
                        EnergyGlyph(
                            level: level.rawValue,
                            filled: isOn ? OveaColor.onAccent : OveaColor.accent,
                            empty: isOn ? OveaColor.onAccent.opacity(0.6) : OveaColor.border
                        )
                        .frame(height: 22, alignment: .bottom)
                        Text(level.label).font(.system(.subheadline, design: .rounded, weight: .bold))
                    }
                    .frame(maxWidth: .infinity, minHeight: 76)
                    .foregroundStyle(isOn ? OveaColor.onAccent : OveaColor.textPrimary)
                    .background(
                        isOn ? OveaColor.accent : OveaColor.surfaceMuted,
                        in: RoundedRectangle(cornerRadius: OveaRadius.md, style: .continuous)
                    )
                    .contentShape(RoundedRectangle(cornerRadius: OveaRadius.md, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Énergie \(level.label.lowercased())")
                .accessibilityHint(level.hint)
                .accessibilityAddTraits(isOn ? .isSelected : [])
            }
        }
        .sensoryFeedback(.selection, trigger: selection)
        .animation(.easeInOut(duration: 0.2), value: selection)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Énergie du jour")
    }
}

// MARK: - Composant : bannière d'alerte douce

struct OveaBanner: View {
    enum Kind: Sendable { case info, warning, success }
    let kind: Kind
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?

    private var colors: (fg: Color, bg: Color, symbol: String) {
        switch kind {
        case .info: (OveaColor.info, OveaColor.infoSoft, "info.circle")
        case .warning: (OveaColor.warning, OveaColor.warningSoft, "exclamationmark.circle")
        case .success: (OveaColor.success, OveaColor.successSoft, "checkmark.circle")
        }
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: OveaSpacing.md) {
            Image(systemName: colors.symbol)
                .font(.body.weight(.semibold))
                .foregroundStyle(colors.fg)
            VStack(alignment: .leading, spacing: OveaSpacing.xs) {
                Text(title).font(OveaFont.headline).foregroundStyle(OveaColor.textPrimary)
                Text(message).font(OveaFont.subheadline).foregroundStyle(OveaColor.textPrimary)
                if let actionTitle, let action {
                    Button(actionTitle, action: action)
                        .font(OveaFont.subheadline.weight(.semibold))
                        .foregroundStyle(colors.fg)
                        .frame(minHeight: OveaSpacing.minTapTarget, alignment: .leading)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(OveaSpacing.lg)
        .background(colors.bg, in: RoundedRectangle(cornerRadius: OveaRadius.lg, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Détails « cosy » : salutation, petit mot du jour, tartan, doodle

/// Salutation selon le moment de la journée (clés today.greeting.* de strings.fr.json).
enum OveaGreeting {
    static func text(for date: Date = .now, name: String?, calendar: Calendar = .current) -> String {
        let hour = calendar.component(.hour, from: date)
        let base: String = switch hour {
        case 5..<12: "Bonjour"
        case 12..<18: "Bon après-midi"
        default: "Bonsoir"
        }
        guard let name, !name.isEmpty else { return base }
        return "\(base) \(name)"
    }
}

/// Bande de tartan discrète (motif textile « plaid »), décorative.
struct OveaPlaid: View {
    var tone: Color = OveaColor.highlight

    var body: some View {
        Canvas { context, size in
            let step: CGFloat = 14
            var x: CGFloat = 0
            while x < size.width {
                context.fill(Path(CGRect(x: x, y: 0, width: 4, height: size.height)), with: .color(tone.opacity(0.22)))
                context.fill(Path(CGRect(x: x + 6, y: 0, width: 1, height: size.height)), with: .color(tone.opacity(0.10)))
                x += step
            }
            var y: CGFloat = 0
            while y < size.height {
                context.fill(Path(CGRect(x: 0, y: y, width: size.width, height: 4)), with: .color(tone.opacity(0.22)))
                y += step
            }
        }
        .accessibilityHidden(true)
    }
}

/// Tasse fumante dessinée « à la main » (trait arrondi, légèrement irrégulier).
struct OveaTeaCupDoodle: View {
    var body: some View {
        Canvas { context, size in
            let k = min(size.width, size.height) / 64
            func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * k, y: y * k) }
            let ink = GraphicsContext.Shading.color(OveaColor.textPrimary)
            let style = StrokeStyle(lineWidth: 2.2 * k, lineCap: .round, lineJoin: .round)

            var cup = Path()
            cup.move(to: p(13.5, 28.5))
            cup.addCurve(to: p(30, 47.7), control1: p(12.9, 38.5), control2: p(17.7, 47.5))
            cup.addCurve(to: p(46.2, 28.3), control1: p(42.3, 47.5), control2: p(46.8, 38.3))
            cup.closeSubpath()
            context.fill(cup, with: .color(OveaColor.surface))
            context.stroke(cup, with: ink, style: style)

            var handle = Path()
            handle.move(to: p(46, 31.5))
            handle.addCurve(to: p(45, 41.3), control1: p(55, 29), control2: p(56, 43))
            context.stroke(handle, with: ink, style: style)

            var tea = Path()
            tea.move(to: p(19, 37))
            tea.addQuadCurve(to: p(29.6, 37), control: p(24.3, 39.5))
            tea.addQuadCurve(to: p(40.2, 37), control: p(34.9, 34.5))
            context.stroke(tea, with: .color(OveaColor.accent), style: style)

            var saucer = Path()
            saucer.move(to: p(9, 52.5))
            saucer.addQuadCurve(to: p(51, 52.5), control: p(30, 56.5))
            context.stroke(saucer, with: ink, style: style)

            for x in [23.0, 31.5, 40.0] as [CGFloat] {
                var steam = Path()
                steam.move(to: p(x, 22))
                steam.addCurve(to: p(x, 11), control1: p(x - 4, 18), control2: p(x + 4, 15))
                context.stroke(steam, with: .color(OveaColor.textPrimary.opacity(0.55)), style: style)
            }
        }
        .accessibilityHidden(true)
    }
}

/// Carte « Petit mot du jour » : miel, bande de tartan, tasse dessinée.
struct OveaDailyNoteCard: View {
    let text: String
    var actionTitle: String? = "Pourquoi ?"
    var action: (() -> Void)?

    private var shape: RoundedRectangle { RoundedRectangle(cornerRadius: OveaRadius.lg, style: .continuous) }

    var body: some View {
        HStack(alignment: .top, spacing: OveaSpacing.md) {
            VStack(alignment: .leading, spacing: OveaSpacing.sm) {
                Label("Petit mot du jour", systemImage: "sparkles")
                    .font(OveaFont.caption.weight(.bold))
                    .foregroundStyle(OveaColor.highlight)
                Text(text)
                    .font(OveaFont.quote)
                    .foregroundStyle(OveaColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                if let actionTitle, let action {
                    Button("\(actionTitle) ›", action: action)
                        .font(OveaFont.subheadline.weight(.bold))
                        .foregroundStyle(OveaColor.highlight)
                        .frame(minHeight: OveaSpacing.minTapTarget, alignment: .leading)
                }
            }
            Spacer(minLength: 0)
            OveaTeaCupDoodle().frame(width: 64, height: 64)
        }
        .padding(OveaSpacing.lg)
        .padding(.leading, OveaSpacing.md)
        .background(OveaColor.highlightSoft, in: shape)
        .overlay(alignment: .leading) {
            OveaPlaid().frame(width: 14)
        }
        .clipShape(shape)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Previews

private struct DesignSystemGallery: View {
    @State private var igBas = true
    @State private var express = false
    @State private var sansLactose = false
    @State private var energy: EnergyLevel? = .basse

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: OveaSpacing.xl) {
                VStack(alignment: .leading, spacing: OveaSpacing.xs) {
                    Text("jeudi 26 novembre").font(OveaFont.subheadline).foregroundStyle(OveaColor.textSecondary)
                    Text(OveaGreeting.text(name: "Léa")).font(OveaFont.display).foregroundStyle(OveaColor.textPrimary)
                }

                OveaDailyNoteCard(
                    text: "Des protéines au petit-déjeuner aident à garder une énergie plus stable jusqu'à midi.",
                    action: {}
                )

                OveaCard {
                    HStack(spacing: OveaSpacing.md) {
                        Image(systemName: "calendar")
                            .font(.title3)
                            .foregroundStyle(OveaColor.accent)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Jour 23").font(OveaFont.metric).foregroundStyle(OveaColor.textPrimary)
                            Text("du cycle").font(OveaFont.subheadline)
                                .foregroundStyle(OveaColor.textSecondary)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: OveaSpacing.sm) {
                    Text("Énergie du jour").oveaOverline()
                    EnergyPicker(selection: $energy)
                }

                VStack(alignment: .leading, spacing: OveaSpacing.sm) {
                    Text("Filtres").oveaOverline()
                    HStack(spacing: OveaSpacing.sm) {
                        OveaChip(title: "IG bas", systemImage: "leaf", isSelected: $igBas)
                        OveaChip(title: "15 min ou moins", systemImage: "timer", isSelected: $express)
                        OveaChip(title: "Sans lactose", isSelected: $sansLactose)
                    }
                }

                OveaCard(tint: MealCategory.diner.tint) {
                    VStack(alignment: .leading, spacing: OveaSpacing.sm) {
                        Label(MealCategory.diner.label, systemImage: MealCategory.diner.symbol)
                            .font(OveaFont.caption)
                            .foregroundStyle(MealCategory.diner.tint.foreground)
                        Text("Dahl de lentilles corail et butternut")
                            .font(OveaFont.title2)
                            .foregroundStyle(OveaColor.textPrimary)
                        Text("30 min · IG bas · réconfortant")
                            .font(OveaFont.subheadline)
                            .foregroundStyle(OveaColor.textSecondary)
                    }
                }

                OveaBanner(
                    kind: .warning,
                    title: "Pas de règles notées depuis plus de 90 jours",
                    message: "C'est fréquent avec le SOPK, et ça vaut le coup d'en parler à ton médecin.",
                    actionTitle: "En savoir plus",
                    action: {}
                )

                Text("02:41").oveaTimerStyle().foregroundStyle(OveaColor.textPrimary)
                    .frame(maxWidth: .infinity)

                OveaPrimaryButton(title: "Valider", systemImage: "checkmark") {}
                OveaPrimaryButton(title: "Valider") {}.disabled(true)
                Button("Ajouter aux courses") {}.buttonStyle(OveaSecondaryButtonStyle())
            }
            .padding(OveaSpacing.screenMargin)
        }
        .background(OveaColor.background)
    }
}

#Preview("Ovéa — clair") {
    DesignSystemGallery()
}

#Preview("Ovéa — sombre") {
    DesignSystemGallery()
        .preferredColorScheme(.dark)
}

#Preview("Ovéa — AX3") {
    DesignSystemGallery()
        .dynamicTypeSize(.accessibility3)
}
