//
//  DesignSystem.swift — Ovéa
//
//  Design system v1 (voir docs/design/02-ui.md et docs/design/tokens.json).
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

/// Tokens sémantiques. Contrastes vérifiés par script (texte ≥ 4.5:1, UI ≥ 3:1).
enum OveaColor {
    // Fonds
    static let background = adaptive(0xF8F5EF, 0x121614)
    static let surface = adaptive(0xFFFFFF, 0x1B201D)
    static let surfaceMuted = adaptive(0xEFEAE1, 0x252C28)
    static let surfaceRaised = adaptive(0xFFFFFF, 0x222825)
    static let separator = adaptive(0xE2DCD1, 0x323A35)
    static let border = adaptive(0x8A8276, 0x7D8680, highContrastLight: 0x5E574D, highContrastDark: 0xA3ACA6)

    // Texte
    static let textPrimary = adaptive(0x1E2621, 0xF0EDE6)
    static let textSecondary = adaptive(0x566059, 0xB4BBB5, highContrastLight: 0x3F4842, highContrastDark: 0xD2D8D3)
    static let textTertiary = adaptive(0x5F6661, 0x959D97, highContrastLight: 0x3F4842, highContrastDark: 0xD2D8D3)

    // Interaction (sauge) et mise en avant (terracotta)
    static let accent = adaptive(0x3B6A55, 0x8EC3A6, highContrastLight: 0x2C5442, highContrastDark: 0xA9DABF)
    static let onAccent = adaptive(0xFFFFFF, 0x0E2218)
    static let accentSoft = adaptive(0xE2ECE5, 0x21362B)
    static let onAccentSoft = adaptive(0x2A4F3F, 0xAAD6BD)
    static let highlight = adaptive(0xA54F2E, 0xEE9F7D)
    static let onHighlight = adaptive(0xFFFFFF, 0x2A1206)
    static let highlightSoft = adaptive(0xF6E5DB, 0x3B251B)

    // États
    static let success = adaptive(0x2D6A47, 0x8DCB9F)
    static let successSoft = adaptive(0xE1EEE4, 0x1E3426)
    static let warning = adaptive(0x855600, 0xE8BD69)
    static let warningSoft = adaptive(0xFAEFD8, 0x372C13)
    static let info = adaptive(0x2E5C78, 0x90C1DE)
    static let infoSoft = adaptive(0xE2EDF3, 0x1B2E39)
    /// Réservé aux actions destructives (supprimer mes données). Jamais sur une donnée corporelle.
    static let destructive = adaptive(0xB3261E, 0xFFB4AB)

    // Cycle
    static let period = adaptive(0x9E3957, 0xF097AF, highContrastLight: 0x7E2643, highContrastDark: 0xF7B8C9)
    static let onPeriod = adaptive(0xFFFFFF, 0x33101C)
    static let periodSoft = adaptive(0xF5E3E7, 0x3C1E28)
    static let spotting = adaptive(0xB2647A, 0xD99AAB)
}

/// Teintes « de saison » : une paire premier plan / fond doux, réutilisée par les catégories.
struct OveaTint: Sendable, Hashable {
    let foreground: Color
    let soft: Color

    static let miel = OveaTint(foreground: adaptive(0x795610, 0xE3BF72), soft: adaptive(0xF6ECD3, 0x382E17))
    static let olive = OveaTint(foreground: adaptive(0x4A6220, 0xB6CB86), soft: adaptive(0xE7EED8, 0x2A321F))
    static let lagon = OveaTint(foreground: adaptive(0x1E6662, 0x80CAC7), soft: adaptive(0xDBEEED, 0x173434))
    static let ardoise = OveaTint(foreground: adaptive(0x3C4E86, 0xA9B6EB), soft: adaptive(0xE4E8F5, 0x222A43))
    static let argile = OveaTint(foreground: adaptive(0x984829, 0xEDA585), soft: adaptive(0xF7E5DB, 0x3B251B))
    static let lavande = OveaTint(foreground: adaptive(0x654F8E, 0xC7B7E6), soft: adaptive(0xECE6F5, 0x2D273E))
    static let sauge = OveaTint(foreground: OveaColor.accent, soft: OveaColor.accentSoft)
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
        case .collation: .argile
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
        case .strength: .argile
        case .cardio: .miel
        case .mobility: .lagon
        case .breathing: .lavande
        case .hiit: .ardoise
        }
    }
}

// MARK: - Typographie (Dynamic Type uniquement)

enum OveaFont {
    /// New York — titres éditoriaux (titre d'écran, nom de recette, message du jour).
    static let display = Font.system(.largeTitle, design: .serif, weight: .semibold)
    static let title1 = Font.system(.title, design: .serif, weight: .semibold)
    static let title2 = Font.system(.title2, design: .serif, weight: .semibold)
    static let quote = Font.system(.title3, design: .serif).italic()
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
    /// SF Pro Rounded — chiffres (jour du cycle, durées).
    static let metric = Font.system(.title2, design: .rounded, weight: .semibold).monospacedDigit()
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
    static let xs: CGFloat = 6     // pastilles, badges
    static let sm: CGFloat = 10    // champs, petites vignettes
    static let md: CGFloat = 14    // boutons
    static let lg: CGFloat = 20    // cartes
    static let xl: CGFloat = 28    // héros, sheets custom
}

enum OveaElevation: Sendable {
    case flat, card, raised
}

private struct OveaElevationModifier: ViewModifier {
    let level: OveaElevation
    @Environment(\.colorScheme) private var scheme
    private static let shadowTone = Color(red: 0x2B / 255, green: 0x3A / 255, blue: 0x30 / 255)

    func body(content: Content) -> some View {
        // En dark : pas d'ombre (illisible), l'élévation passe par la surface + un filet.
        if scheme == .dark || level == .flat {
            content
        } else if level == .card {
            content
                .shadow(color: Self.shadowTone.opacity(0.04), radius: 1, y: 1)
                .shadow(color: Self.shadowTone.opacity(0.06), radius: 12, y: 4)
        } else {
            content.shadow(color: Self.shadowTone.opacity(0.10), radius: 24, y: 8)
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
            .overlay {
                RoundedRectangle(cornerRadius: OveaRadius.lg, style: .continuous)
                    .strokeBorder(OveaColor.separator, lineWidth: tint == nil ? 0.5 : 0)
            }
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
            .font(OveaFont.headline)
            .foregroundStyle(isEnabled ? OveaColor.onAccent : OveaColor.textSecondary)
            .frame(maxWidth: .infinity, minHeight: 52)
            .padding(.horizontal, OveaSpacing.lg)
            .background(
                isEnabled ? OveaColor.accent : OveaColor.surfaceMuted,
                in: RoundedRectangle(cornerRadius: OveaRadius.md, style: .continuous)
            )
            .opacity(configuration.isPressed ? 0.85 : 1)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

/// Bouton secondaire (contour sauge), même gabarit.
struct OveaSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(OveaFont.headline)
            .foregroundStyle(OveaColor.accent)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(
                RoundedRectangle(cornerRadius: OveaRadius.md, style: .continuous)
                    .strokeBorder(OveaColor.accent, lineWidth: 1.5)
            )
            .contentShape(RoundedRectangle(cornerRadius: OveaRadius.md, style: .continuous))
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

// MARK: - Composant : EnergyPicker

/// Niveau d'énergie déclaré. Volontairement mono-teinte (sauge) : pas de feu rouge/vert,
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
                        Text(level.label).font(OveaFont.subheadline.weight(.semibold))
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
                    Text("Bonjour Léa").font(OveaFont.display).foregroundStyle(OveaColor.textPrimary)
                }

                OveaCard {
                    HStack(spacing: OveaSpacing.md) {
                        Image(systemName: "calendar")
                            .font(.title3)
                            .foregroundStyle(OveaColor.accent)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Jour 23").font(OveaFont.metric).foregroundStyle(OveaColor.textPrimary)
                            Text("de ton cycle en cours").font(OveaFont.subheadline)
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
