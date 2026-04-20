import SwiftUI

struct NourriSearchView: View {
    let palette: Palette
    let isDark: Bool
    let onRecipeTap: (String) -> Void

    @EnvironmentObject private var favsStore: FavoritesStore
    @EnvironmentObject private var recipeStore: RecipeStore
    @State private var query = ""
    @State private var activeSymptoms: Set<String> = []
    @State private var activeAvoid: Set<String> = []
    @State private var sortOrder: SortOrder = .recommended

    enum SortOrder { case recommended, quickest, antiInflam }

    private let symptomTagMap: [String: [String]] = [
        "Fatigue chronique": ["énergie", "fer", "magnésium"],
        "Règles douloureuses": ["anti-inflammatoire", "oméga", "magnésium"],
        "Ballonnements": ["fibres", "digestif", "probiotique"],
        "Prise de poids": ["ig bas", "protéine", "fibre"],
        "Acné hormonale": ["zinc", "antioxydant", "oméga"],
        "Troubles du sommeil": ["magnésium", "anti-stress", "tryptophane"],
        "Anxiété": ["magnésium", "anti-stress"],
        "Douleurs pelviennes": ["anti-inflammatoire", "oméga", "curcuma"],
    ]

    private var filtered: [AppRecipe] {
        recipeStore.recipes.filter { recipe in
            if !query.isEmpty && !recipe.name.lowercased().contains(query.lowercased()) { return false }
            if !activeAvoid.isEmpty && !activeAvoid.isSubset(of: Set(recipe.tags.map { $0.lowercased() })) { return false }
            if !activeSymptoms.isEmpty {
                let targetTags = activeSymptoms.flatMap { symptomTagMap[$0] ?? [] }.map { $0.lowercased() }
                if !targetTags.isEmpty {
                    let recipeTags = Set(recipe.tags.map { $0.lowercased() })
                    let desc = recipe.description.lowercased()
                    if !targetTags.contains(where: { recipeTags.contains($0) || desc.contains($0) }) {
                        return false
                    }
                }
            }
            return true
        }
        .sorted { a, b in
            switch sortOrder {
            case .recommended: return a.antiInflam > b.antiInflam
            case .quickest: return a.time < b.time
            case .antiInflam: return a.antiInflam > b.antiInflam
            }
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 16) {
                    Text("Recherche")
                        .font(.custom("Fraunces", size: 30))
                        .foregroundColor(palette.ink)
                        .kerning(-0.5)

                    // Search field
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 18))
                            .foregroundColor(palette.inkMuted)
                        TextField("Ingrédient, recette, symptôme…", text: $query)
                            .font(.system(size: 15))
                            .foregroundColor(palette.ink)
                        if !query.isEmpty {
                            Button { query = "" } label: {
                                Image(systemName: "xmark").font(.system(size: 16)).foregroundColor(palette.inkMuted)
                            }
                        }
                    }
                    .padding(.horizontal, 16).padding(.vertical, 12)
                    .background(palette.surface)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(palette.line, lineWidth: 1))
                }
                .padding(.top, 62)
                .padding(.horizontal, 20)
                .padding(.bottom, 12)

                // Symptoms section
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Cibler un symptôme")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(palette.inkMuted)
                            .kerning(0.5)
                            .textCase(.uppercase)
                        Spacer()
                        Text("\(activeSymptoms.count) actif\(activeSymptoms.count > 1 ? "s" : "")")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(palette.sageDeep)
                    }
                    .padding(.horizontal, 20)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(SampleData.symptoms) { s in
                                FilterChip(
                                    label: s.label,
                                    isActive: activeSymptoms.contains(s.id),
                                    palette: palette,
                                    icon: s.icon
                                ) {
                                    if activeSymptoms.contains(s.id) { activeSymptoms.remove(s.id) }
                                    else { activeSymptoms.insert(s.id) }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.vertical, 12)

                // Avoid tags section
                VStack(alignment: .leading, spacing: 10) {
                    Text("À éviter")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(palette.inkMuted)
                        .kerning(0.5)
                        .textCase(.uppercase)
                        .padding(.horizontal, 20)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(SampleData.avoidTags) { t in
                                FilterChip(
                                    label: t.label,
                                    isActive: activeAvoid.contains(t.id),
                                    palette: palette
                                ) {
                                    if activeAvoid.contains(t.id) { activeAvoid.remove(t.id) }
                                    else { activeAvoid.insert(t.id) }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 12)

                // Results header
                HStack(alignment: .firstTextBaseline) {
                    Text("\(filtered.count) recette\(filtered.count != 1 ? "s" : "") trouvée\(filtered.count != 1 ? "s" : "")")
                        .font(.custom("Fraunces", size: 20).weight(.medium))
                        .foregroundColor(palette.ink)
                    Spacer()
                    Menu {
                        Button("Recommandé") { sortOrder = .recommended }
                        Button("Temps de préparation") { sortOrder = .quickest }
                        Button("Score anti-inflammatoire") { sortOrder = .antiInflam }
                    } label: {
                        HStack(spacing: 4) {
                            Text(sortOrder == .quickest ? "plus rapide" : sortOrder == .antiInflam ? "anti-inflam" : "recommandé")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(palette.ink)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 11))
                                .foregroundColor(palette.inkMuted)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(palette.surface)
                        .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 4)

                // Results list
                Group {
                    if filtered.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 40))
                                .foregroundColor(palette.inkMuted)
                            Text("Aucune recette trouvée")
                                .font(.custom("Fraunces_9pt-Regular", size: 22))
                                .foregroundColor(palette.ink)
                            Text("Essayez d'ajuster vos filtres ou votre recherche.")
                                .font(.system(size: 14))
                                .foregroundColor(palette.inkSoft)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 60)
                        .padding(.horizontal, 32)
                    } else {
                        VStack(spacing: 10) {
                            ForEach(filtered) { recipe in
                                NourriRecipeRowCard(
                                    recipe: recipe, palette: palette,
                                    isFav: favsStore.contains(recipe.id),
                                    onTap: { onRecipeTap(recipe.id) },
                                    onFav: { favsStore.toggle(recipe.id) }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                    }
                }
            }
            .padding(.bottom, 110)
        }
        .background(palette.bg.ignoresSafeArea())
    }
}
