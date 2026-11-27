//
//  DesignSystem.swift — Ovéa
//
//  Design system V3 « Mascotte & illustrations » (voir docs/design/05-illustration.md,
//  docs/design/tokens.json et docs/design/illustrations/).
//  À coller tel quel dans le projet Xcode (cible iOS 18, Swift 6, mode strict).
//  Aucune dépendance. Couleurs adaptatives via UIColor(dynamicProvider:) : light / dark / « Augmenter le contraste ».
//
//  Principes V3 :
//  - Base native : NavigationStack à grands titres, List(.insetGrouped), TabView standard, SF Pro.
//    Nos composants ne remplacent que ce que le natif ne fait pas (sélecteur d'énergie, mascotte, carte mise en avant).
//  - La personnalité vient de Mousse (OveaMascotView) et des illustrations de plats, PAS de cartes teintées.
//  - Une seule carte mise en avant par écran (OveaFeatureCard). Le reste en listes groupées.
//  - Un seul accent cliquable : myrtille. Typo système uniquement ; SF Pro Rounded pour les grands titres.
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

/// Tokens sémantiques V3. Contrastes vérifiés par palette.py (texte ≥ 4.5:1, UI ≥ 3:1, light et dark).
enum OveaColor {
    // Fonds
    static let background = adaptive(0xF4F3F1, 0x121117)
    static let surface = adaptive(0xFFFFFF, 0x1D1B23)
    static let surfaceMuted = adaptive(0xEAE8E4, 0x2A2731)
    static let surfaceRaised = adaptive(0xFFFFFF, 0x242129)
    static let separator = adaptive(0xDEDBD5, 0x34313C)
    static let border = adaptive(0x7F7A86, 0x837E8E, highContrastLight: 0x5C5863, highContrastDark: 0xA9A4B4)

    // Texte (encre)
    static let textPrimary = adaptive(0x1D1B22, 0xF3F1F6)
    static let textSecondary = adaptive(0x5D5966, 0xBDB8C7, highContrastLight: 0x45424D, highContrastDark: 0xDAD6E2)
    static let textTertiary = adaptive(0x67636F, 0xA39EAE, highContrastLight: 0x45424D, highContrastDark: 0xDAD6E2)

    // Interaction : myrtille (seul accent cliquable) et mousse
    static let accent = adaptive(0x3F3895, 0xB4AEF6, highContrastLight: 0x2E2878, highContrastDark: 0xCFCBFF)
    static let onAccent = adaptive(0xFFFFFF, 0x15123F)
    static let accentSoft = adaptive(0xE8E6F7, 0x2C2950)
    static let onAccentSoft = adaptive(0x383189, 0xD7D3FB)
    static let leaf = adaptive(0x456E1B, 0xB3D57A)
    static let leafSoft = adaptive(0xE5EDD6, 0x232D18)
    static let highlight = adaptive(0x8A5300, 0xF2C46B)
    static let onHighlight = adaptive(0xFFFFFF, 0x2B1D06)
    static let highlightSoft = adaptive(0xFBEBCB, 0x3A2C12)

    // États
    static let success = adaptive(0x456E1B, 0xB3D57A)
    static let successSoft = adaptive(0xE5EDD6, 0x232D18)
    static let warning = adaptive(0x8A5300, 0xF2C46B)
    static let warningSoft = adaptive(0xFBEBCB, 0x3A2C12)
    static let info = adaptive(0x2F6178, 0x9CCBE0)
    static let infoSoft = adaptive(0xE1EDF2, 0x1A2B33)
    static let destructive = adaptive(0xB3261E, 0xFFB4AB)

    // Cycle (framboise, plus claire que la myrtille)
    static let period = adaptive(0xA83A62, 0xEFA6C8, highContrastLight: 0x86284C, highContrastDark: 0xF6C6DC)
    static let onPeriod = adaptive(0xFFFFFF, 0x3A0F25)
    static let periodSoft = adaptive(0xF7E2EC, 0x3C1F30)
    static let spotting = adaptive(0xB06A8E, 0xC98BAA)
}

/// Teintes de catégorie : libellé, SF Symbol et tuile d'icône (style Réglages iOS).
/// Le fond doux ne sert JAMAIS de fond de carte : c'est la règle anti-« cartes teintées partout » de la V3.
struct OveaTint: Sendable, Hashable {
    let foreground: Color
    let soft: Color

    static let miel = OveaTint(foreground: adaptive(0x8A5A00, 0xEFC370), soft: adaptive(0xFAEBCD, 0x3A2D14))
    static let olive = OveaTint(foreground: adaptive(0x4D6A1E, 0xBCD58A), soft: adaptive(0xE8EED8, 0x262E18))
    static let lagon = OveaTint(foreground: adaptive(0x22655D, 0x8FD0C3), soft: adaptive(0xDDEEEA, 0x17302C))
    static let ardoise = OveaTint(foreground: adaptive(0x45577E, 0xAFC0E6), soft: adaptive(0xE3E8F3, 0x1E2536))
    static let cacao = OveaTint(foreground: adaptive(0x7A4A30, 0xDFB494), soft: adaptive(0xF3E5DA, 0x33251C))
    static let lavande = OveaTint(foreground: adaptive(0x6A4C8C, 0xCDB8E6), soft: adaptive(0xEEE7F5, 0x2C2438))
    static let mousse = OveaTint(foreground: OveaColor.leaf, soft: OveaColor.leafSoft)
    static let myrtille = OveaTint(foreground: OveaColor.accent, soft: OveaColor.accentSoft)
}

/// Palette d'illustration : couleurs FIXES (identiques en clair et en sombre, comme une photo).
/// Réservée aux illustrations dessinées en code (placeholder de la mascotte, graphiques décoratifs).
/// Les vrais assets sont des SVG/PDF vectoriels dans l'Asset Catalog (« Preserve Vector Data »).
enum OveaIllustration {
    private static func fixed(_ hex: UInt32) -> Color {
        Color(red: Double((hex >> 16) & 0xFF) / 255, green: Double((hex >> 8) & 0xFF) / 255, blue: Double(hex & 0xFF) / 255)
    }
    static let encre = fixed(0x2A2438)  // Trait unique (4 u sur 240), yeux, bouche
    static let galet = fixed(0xCEC7DB)  // Corps de Mousse
    static let galetOmbre = fixed(0xB2A8C4)  // Ombre portée sur le corps, mouchetures
    static let mousse = fixed(0x8DB34A)  // Coussin de mousse, feuilles, herbes
    static let mousseOmbre = fixed(0x6F9736)  // Ombre de la mousse, thym
    static let mousseClaire = fixed(0xC2DB86)  // Nouvelle feuille (célébration douce)
    static let abricot = fixed(0xF4B49A)  // Joues, coussin
    static let abricotOmbre = fixed(0xE3957A)  // Ombre abricot
    static let courge = fixed(0xF2A23A)  // Dahl, carottes, plaid (avec courgeOmbre)
    static let courgeOmbre = fixed(0xDA8228)  // Dés de butternut, rayures du plaid
    static let paprika = fixed(0xD9573B)  // Cocotte, pomme, épices
    static let betterave = fixed(0xA63A6B)  // Chou rouge, houmous (plats uniquement, jamais sur Mousse)
    static let betteraveClaire = fixed(0xD2709B)  // Houmous de betterave
    static let porcelaine = fixed(0xFAF8F5)  // Assiettes, bols, reflets, sauces blanches
    static let creme = fixed(0xEFE6D3)  // Riz, écrasé, flocons
    static let bois = fixed(0xCC9563)  // Planches, cuillère, quinoa
    static let boisOmbre = fixed(0xAE7546)  // Veinage des planches
    static let cacaoIllu = fixed(0x6B4331)  // Bouchées cacao, cumin
    static let table = fixed(0xE5E3EF)  // Fond des illustrations de plats (lavande grisée, complémentaire des plats chauds)
    static let tableOmbre = fixed(0xD2CFE1)  // Ombre portée à plat sous les contenants (décalage 5/7 u, sans flou)
    /// Épaisseur unique du trait, pour un viewBox de 240 (soit 1/60 de la taille affichée).
    static let strokeRatio: CGFloat = 4.0 / 240.0
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

// MARK: - Typographie (système uniquement, Dynamic Type)

enum OveaFont {
    /// Une seule voix d'affichage : SF Pro Rounded (système, rien à embarquer), pour les grands titres et le minuteur.
    /// Elle reprend la géométrie ronde de Mousse. Tout le reste est en SF Pro.
    static let display = Font.system(.largeTitle, design: .rounded, weight: .bold)
    static let title1 = Font.system(.title, design: .rounded, weight: .bold)
    static let title2 = Font.system(.title2, weight: .semibold)
    static let title3 = Font.system(.title3, weight: .semibold)
    /// Titre de section en casse de phrase (remplace les sur-titres en capitales espacées de la V2).
    static let sectionHeader = Font.system(.title3, weight: .semibold)
    static let headline = Font.headline
    static let body = Font.body
    static let bodyEmphasis = Font.body.weight(.medium)
    static let callout = Font.callout
    static let subheadline = Font.subheadline
    static let footnote = Font.footnote
    static let caption = Font.caption.weight(.medium)
    static let button = Font.headline
    static let metric = Font.system(.title2, design: .rounded, weight: .semibold).monospacedDigit()
}

/// Minuteur du lecteur de séance : grand, arrondi, chiffres tabulaires, qui suit Dynamic Type.
struct OveaTimerStyle: ViewModifier {
    @ScaledMetric(relativeTo: .largeTitle) private var size: CGFloat = 64
    func body(content: Content) -> some View {
        content
            .font(.system(size: size, weight: .semibold, design: .rounded).monospacedDigit())
            .contentTransition(.numericText(countsDown: true))
    }
}

extension View {
    func oveaTimerStyle() -> some View { modifier(OveaTimerStyle()) }

    /// Titre de section : « Pour toi aujourd'hui », en casse de phrase.
    func oveaSectionHeader() -> some View {
        font(OveaFont.sectionHeader)
            .foregroundStyle(OveaColor.textPrimary)
            .textCase(nil)
    }
}

// MARK: - Espacements, rayons, élévation

/// Grille 4/8 pt (la même que les illustrations : viewBox 240, pas de 8).
enum OveaSpacing {
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 48
    static let screenMargin: CGFloat = 16
    static let cardPadding: CGFloat = 16
    static let sectionGap: CGFloat = 28
    static let minTapTarget: CGFloat = 44
}

/// Proches d'iOS. Toujours avec `style: .continuous`. La rondeur vient de Mousse, pas des cartes.
enum OveaRadius {
    static let xs: CGFloat = 6     // badges
    static let sm: CGFloat = 10    // vignettes de plats dans les listes, tuiles
    static let md: CGFloat = 12    // options d'énergie, groupes de liste
    static let lg: CGFloat = 16    // la carte mise en avant
    static let xl: CGFloat = 22    // sheets custom
    static let button: CGFloat = 14
}

enum OveaElevation: Sendable {
    case flat, feature, raised
}

private struct OveaElevationModifier: ViewModifier {
    let level: OveaElevation
    @Environment(\.colorScheme) private var scheme
    private static let ink = Color(red: 0x1D / 255, green: 0x1B / 255, blue: 0x22 / 255)

    func body(content: Content) -> some View {
        switch (level, scheme) {
        case (.flat, _), (.feature, .dark):
            content                                   // en sombre, l'élévation vient de la surface plus claire
        case (.feature, _):
            content.shadow(color: Self.ink.opacity(0.06), radius: 12, y: 4)
        case (.raised, .dark):
            content.shadow(color: .black.opacity(0.45), radius: 28, y: 10)
        case (.raised, _):
            content.shadow(color: Self.ink.opacity(0.14), radius: 28, y: 10)
        }
    }
}

extension View {
    func oveaElevation(_ level: OveaElevation) -> some View { modifier(OveaElevationModifier(level: level)) }
}

// MARK: - Composant : OveaFeatureCard (une seule par écran)

/// La carte mise en avant de l'écran (ex. « Pour toi aujourd'hui » dans Cuisine, « Doux pour aujourd'hui » dans Bouger).
/// Fond `surface`, jamais teinté. Le reste de l'écran passe par des `List(.insetGrouped)`.
struct OveaFeatureCard<Content: View>: View {
    var illustration: String?            // nom d'asset d'un plat (identifiant de recette), affiché en bandeau
    var illustrationHeight: CGFloat = 150
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let illustration {
                Image(illustration)
                    .resizable()
                    .scaledToFill()
                    .frame(height: illustrationHeight)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .accessibilityHidden(true)
            }
            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(OveaSpacing.cardPadding)
        }
        .background(OveaColor.surface, in: RoundedRectangle(cornerRadius: OveaRadius.lg, style: .continuous))
        .clipShape(RoundedRectangle(cornerRadius: OveaRadius.lg, style: .continuous))
        .oveaElevation(.feature)
    }
}

/// Vignette d'illustration de plat pour une ligne de liste (60 pt, rayon 10).
struct OveaDishThumbnail: View {
    let recipeID: String
    var size: CGFloat = 60
    var body: some View {
        Image(recipeID)
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: OveaRadius.sm, style: .continuous))
            .accessibilityHidden(true)
    }
}

// MARK: - Composant : OveaChip (filtre / choix)

/// Chip de filtre ou de choix. Cible tactile ≥ 44 pt même si la capsule visible fait 32 pt.
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
            .frame(minHeight: 32)
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
            .foregroundStyle(isSelected ? OveaColor.onAccent : OveaColor.textPrimary)
            .background(isSelected ? OveaColor.accent : OveaColor.surface, in: Capsule())
            .overlay {
                Capsule().strokeBorder(isSelected ? .clear : OveaColor.separator, lineWidth: 0.5)
            }
            .padding(.vertical, 6)              // 32 pt visibles + 12 = 44 pt de cible tactile
            .contentShape(Rectangle())
            .opacity(isEnabled ? (configuration.isPressed ? 0.75 : 1) : 0.45)
    }
}

// MARK: - Boutons (formes iOS « filled » / « tinted »)

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

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(OveaFont.button)
            .foregroundStyle(isEnabled ? OveaColor.onAccent : OveaColor.textSecondary)
            .frame(maxWidth: .infinity, minHeight: 50)
            .padding(.horizontal, OveaSpacing.lg)
            .background(isEnabled ? OveaColor.accent : OveaColor.surfaceMuted,
                        in: RoundedRectangle(cornerRadius: OveaRadius.button, style: .continuous))
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

/// Bouton secondaire « tinted » (fond myrtille pâle), même gabarit.
struct OveaTintedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(OveaFont.button)
            .foregroundStyle(OveaColor.onAccentSoft)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(OveaColor.accentSoft, in: RoundedRectangle(cornerRadius: OveaRadius.button, style: .continuous))
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

// MARK: - Énergie : niveau, glyphe « tige », sélecteur

/// Niveau d'énergie déclaré. Mono-teinte : pas de feu rouge/vert, une énergie basse n'est pas « mauvaise ».
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
    /// État de Mousse correspondant : c'est l'élément signature de l'écran Aujourd'hui.
    var mascotState: OveaMascotState {
        switch self {
        case .basse: .energieBasse
        case .moyenne: .energieMoyenne
        case .bonne: .energieBonne
        }
    }
}

/// Une tige portant 1, 2 ou 3 feuilles : le même code que la tige de Mousse (remplace les barres de la V2).
struct EnergyGlyph: View {
    let level: Int
    var color: Color = OveaColor.leaf

    var body: some View {
        Canvas { context, size in
            let k = min(size.width, size.height) / 26
            func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * k, y: y * k) }
            let style = StrokeStyle(lineWidth: 2 * k, lineCap: .round, lineJoin: .round)
            let index = max(0, min(2, level - 1))
            let tops: [CGFloat] = [12, 9, 5]
            let top = tops[index]
            var stem = Path()
            stem.move(to: p(13, 23)); stem.addLine(to: p(13, top))
            context.stroke(stem, with: .color(color), style: style)
            // feuilles : (point d'attache y, côté)
            let allLeaves: [[(y: CGFloat, side: CGFloat)]] = [[(12, 1)], [(15, 1), (12, -1)], [(17, 1), (13.5, -1), (7.5, 1)]]
            let leaves = allLeaves[index]
            for (y, side) in leaves {
                var leaf = Path()
                leaf.move(to: p(13, y))
                leaf.addQuadCurve(to: p(13 + 6.5 * side, y - 5.5), control: p(13 + 1 * side, y - 5))
                leaf.addQuadCurve(to: p(13, y), control: p(13 + 6 * side, y - 0.5))
                context.fill(leaf, with: .color(color.opacity(0.25)))
                context.stroke(leaf, with: .color(color), style: style)
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
                    VStack(spacing: OveaSpacing.xs) {
                        EnergyGlyph(level: level.rawValue, color: isOn ? OveaColor.onAccent : OveaColor.leaf)
                            .frame(width: 26, height: 26)
                        Text(level.label).font(OveaFont.headline)
                    }
                    .frame(maxWidth: .infinity, minHeight: 76)
                    .foregroundStyle(isOn ? OveaColor.onAccent : OveaColor.textPrimary)
                    .background(isOn ? OveaColor.accent : OveaColor.surface,
                                in: RoundedRectangle(cornerRadius: OveaRadius.md, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: OveaRadius.md, style: .continuous)
                            .strokeBorder(isOn ? .clear : OveaColor.separator, lineWidth: 0.5)
                    }
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

// MARK: - Mascotte : Mousse

/// États de Mousse. `rawValue` = nom de l'asset dans l'Asset Catalog (SVG/PDF vectoriel, « Preserve Vector Data »),
/// identique au nom de fichier dans docs/design/illustrations/.
///
/// Règles d'usage (05-illustration.md §6) :
/// - au plus UNE apparition par écran ; jamais sur Mon cycle, l'alerte 90 jours, les signaux d'arrêt,
///   l'avertissement santé ni la suppression des données : le ton y est sobre ;
/// - Mousse ne parle pas (pas de bulle) : la voix de l'app reste « on » ;
/// - elle ne commente jamais le corps, le poids ni les règles.
enum OveaMascotState: String, CaseIterable, Identifiable, Sendable {
    case accueil = "mousse-accueil"
    case energieBasse = "mousse-energie-basse"
    case energieMoyenne = "mousse-energie-moyenne"
    case energieBonne = "mousse-energie-bonne"
    case jourDifficile = "mousse-jour-difficile"
    case cuisine = "mousse-cuisine"
    case mouvement = "mousse-mouvement"
    case repos = "mousse-repos"
    case etatVide = "mousse-etat-vide"
    case celebration = "mousse-celebration"

    var id: String { rawValue }

    /// Libellé VoiceOver : décrit l'image, sans interpréter l'état de la personne.
    var accessibilityLabel: String {
        switch self {
        case .accueil: "Mousse, un petit galet couvert de mousse, te fait signe"
        case .energieBasse: "Mousse se repose, sa tige porte une feuille"
        case .energieMoyenne: "Mousse, sa tige porte deux feuilles"
        case .energieBonne: "Mousse se tient droite, sa tige porte trois feuilles"
        case .jourDifficile: "Mousse se repose sous un plaid, une tasse à côté"
        case .cuisine: "Mousse tourne une cuillère dans une cocotte"
        case .mouvement: "Mousse fait un petit saut"
        case .repos: "Mousse dort sur un coussin"
        case .etatVide: "Mousse, à côté d'un bol vide"
        case .celebration: "Mousse sourit, une nouvelle feuille a poussé"
        }
    }

    /// Nombre de feuilles sur la tige (placeholder dessiné en code).
    fileprivate var leaves: Int {
        switch self {
        case .energieBasse, .jourDifficile, .repos: 1
        case .energieBonne, .mouvement, .celebration: 3
        default: 2
        }
    }
    fileprivate var eyesClosed: Bool {
        switch self {
        case .energieBasse, .jourDifficile, .repos, .celebration: true
        default: false
        }
    }
}

/// Affiche Mousse dans l'état demandé.
/// - Utilise l'asset vectoriel `state.rawValue` s'il est présent ; sinon un placeholder dessiné en code (mêmes formes,
///   même palette), pour que les previews et les tests marchent avant l'intégration des illustrations définitives.
/// - Changement d'état en fondu ; légère « respiration » (échelle 1 → 1,015) désactivée si Réduire les animations.
struct OveaMascotView: View {
    let state: OveaMascotState
    var size: CGFloat = 152
    /// `true` quand le texte voisin dit déjà tout (ex. « Aujourd'hui, on fait simple. ») : VoiceOver l'ignore.
    var isDecorative = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var breathe = false

    var body: some View {
        ZStack {
            if Self.hasAsset(state.rawValue) {
                Image(state.rawValue).resizable().scaledToFit()
            } else {
                MousseSketch(state: state)
            }
        }
        .id(state)                                          // fondu entre deux états
        .transition(.opacity)
        .frame(width: size, height: size)
        .scaleEffect(breathe && !reduceMotion ? 1.015 : 1, anchor: .bottom)
        .animation(.easeInOut(duration: 0.35), value: state)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true)) { breathe = true }
        }
        .accessibilityElement()
        .accessibilityLabel(isDecorative ? "" : state.accessibilityLabel)
        .accessibilityAddTraits(.isImage)
        .accessibilityHidden(isDecorative)
    }

    private static func hasAsset(_ name: String) -> Bool {
        #if canImport(UIKit)
        UIImage(named: name) != nil
        #else
        false
        #endif
    }
}

/// Placeholder vectoriel de Mousse (galet plus large que haut, coussin de mousse, tige à 1–3 feuilles).
private struct MousseSketch: View {
    let state: OveaMascotState

    var body: some View {
        Canvas { context, size in
            let k = min(size.width, size.height) / 240
            func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * k, y: y * k) }
            let ink = GraphicsContext.Shading.color(OveaIllustration.encre)
            let line = StrokeStyle(lineWidth: 4 * k, lineCap: .round, lineJoin: .round)
            let low = state.leaves == 1
            let top: CGFloat = low ? 112 : 92

            // ombre au sol
            context.fill(Path(ellipseIn: CGRect(x: 44 * k, y: 198 * k, width: 154 * k, height: 14 * k)),
                         with: .color(OveaIllustration.encre.opacity(0.12)))
            // corps (galet)
            var pebble = Path()
            pebble.move(to: p(58, 200))
            pebble.addCurve(to: p(32, low ? 166 : 158), control1: p(34, 200), control2: p(28, 180))
            pebble.addCurve(to: p(122, top), control1: p(38, top + 30), control2: p(76, top))
            pebble.addCurve(to: p(210, low ? 168 : 160), control1: p(170, top), control2: p(206, top + 28))
            pebble.addCurve(to: p(178, 200), control1: p(213, 190), control2: p(198, 200))
            pebble.closeSubpath()
            context.fill(pebble, with: .color(OveaIllustration.galet))
            context.stroke(pebble, with: ink, style: line)

            // tige + feuilles
            var stem = Path()
            stem.move(to: p(122, top - 10))
            stem.addLine(to: p(124, top - 10 - CGFloat(14 + 12 * state.leaves)))
            context.stroke(stem, with: ink, style: line)
            for i in 0..<state.leaves {
                let y = top - 22 - CGFloat(i * 13)
                let side: CGFloat = i % 2 == 0 ? 1 : -1
                var leaf = Path()
                leaf.move(to: p(123, y))
                leaf.addQuadCurve(to: p(123 + 22 * side, y - 8), control: p(123 + 6 * side, y - 14))
                leaf.addQuadCurve(to: p(123, y), control: p(123 + 16 * side, y + 6))
                context.fill(leaf, with: .color(OveaIllustration.mousse))
                context.stroke(leaf, with: ink, style: line)
            }
            // coussin de mousse
            let cap = Path(roundedRect: CGRect(x: 88 * k, y: (top - 14) * k, width: 68 * k, height: 26 * k), cornerRadius: 13 * k)
            context.fill(cap, with: .color(OveaIllustration.mousse))
            context.stroke(cap, with: ink, style: line)

            // visage
            let eyeY = top + (200 - top) * 0.5
            for x in [104.0, 142.0] as [CGFloat] {
                if state.eyesClosed {
                    var e = Path(); e.move(to: p(x - 6, eyeY)); e.addQuadCurve(to: p(x + 6, eyeY), control: p(x, eyeY + 5))
                    context.stroke(e, with: ink, style: line)
                } else {
                    context.fill(Path(ellipseIn: CGRect(x: (x - 4.6) * k, y: (eyeY - 6.2) * k, width: 9.2 * k, height: 12.4 * k)), with: ink)
                }
                context.fill(Path(ellipseIn: CGRect(x: (x - 22) * k, y: (eyeY + 12) * k, width: 18 * k, height: 10 * k)),
                             with: .color(OveaIllustration.abricot))
            }
            var mouth = Path(); mouth.move(to: p(116, eyeY + 15)); mouth.addQuadCurve(to: p(128, eyeY + 15), control: p(122, eyeY + 20))
            context.stroke(mouth, with: ink, style: line)
        }
        .accessibilityHidden(true)
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

// MARK: - Salutation

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

// MARK: - Previews

private struct DesignSystemGallery: View {
    @State private var igBas = true
    @State private var express = false
    @State private var energy: EnergyLevel?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: OveaSpacing.md) {
                        HStack(spacing: OveaSpacing.xs) {
                            OveaMascotView(state: energy?.mascotState ?? .accueil, size: 140)
                            VStack(alignment: .leading, spacing: OveaSpacing.xs) {
                                Text("Comment est ton énergie ?").font(OveaFont.title2)
                                Text("Un tap suffit. Le reste est facultatif.")
                                    .font(OveaFont.footnote).foregroundStyle(OveaColor.textSecondary)
                            }
                        }
                        EnergyPicker(selection: $energy)
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }

                Section {
                    HStack(spacing: OveaSpacing.md) {
                        OveaDishThumbnail(recipeID: "diner-dahl-lentilles-corail-butternut")
                        VStack(alignment: .leading, spacing: 2) {
                            Label(MealCategory.diner.label, systemImage: MealCategory.diner.symbol)
                                .font(OveaFont.caption).foregroundStyle(MealCategory.diner.tint.foreground)
                            Text("Dahl de lentilles corail et butternut").font(OveaFont.headline)
                            Text("30 min").font(OveaFont.subheadline).foregroundStyle(OveaColor.textSecondary)
                        }
                    }
                    Label("Jour 23 du cycle", systemImage: "drop")
                        .foregroundStyle(OveaColor.textPrimary)
                } header: {
                    Text("Pour toi aujourd'hui").oveaSectionHeader()
                }

                Section {
                    HStack(spacing: OveaSpacing.sm) {
                        OveaChip(title: "IG bas", isSelected: $igBas)
                        OveaChip(title: "15 min ou moins", isSelected: $express)
                    }
                    OveaPrimaryButton(title: "Valider") {}
                    Button("Commencer la séance") {}.buttonStyle(OveaTintedButtonStyle())
                }
                .listRowBackground(Color.clear)
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(OveaColor.background)
            .navigationTitle(OveaGreeting.text(name: "Léa"))
        }
        .tint(OveaColor.accent)
    }
}

/// Planche des états de la mascotte.
private struct MascotBoard: View {
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: OveaSpacing.lg) {
                ForEach(OveaMascotState.allCases) { state in
                    VStack(spacing: OveaSpacing.xs) {
                        OveaMascotView(state: state, size: 140)
                        Text(state.rawValue).font(OveaFont.caption).foregroundStyle(OveaColor.textSecondary)
                    }
                }
            }
            .padding(OveaSpacing.screenMargin)
        }
        .background(OveaColor.background)
    }
}

#Preview("Ovéa V3 — clair") {
    DesignSystemGallery()
}

#Preview("Ovéa V3 — sombre") {
    DesignSystemGallery()
        .preferredColorScheme(.dark)
}

#Preview("Ovéa V3 — AX3") {
    DesignSystemGallery()
        .dynamicTypeSize(.accessibility3)
}

#Preview("Mousse — tous les états") {
    MascotBoard()
}

#Preview("Mousse — énergie basse, sombre") {
    OveaMascotView(state: .energieBasse)
        .padding()
        .background(OveaColor.background)
        .preferredColorScheme(.dark)
}
