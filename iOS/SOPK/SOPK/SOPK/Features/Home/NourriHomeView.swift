import SwiftUI

struct NourriHomeView: View {
    let palette: Palette
    let isDark: Bool
    let onRecipeTap: (String) -> Void
    let onTabChange: (NourriTabBar.AppTab) -> Void

    @EnvironmentObject private var favsStore: FavoritesStore
    @EnvironmentObject private var recipeStore: RecipeStore
    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var cycleStore: CycleStore
    @State private var showProfile = false

    // MARK: - Derived properties

    private var todayString: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE d MMMM"
        f.locale = Locale(identifier: "fr_FR")
        return f.string(from: Date()).capitalized
    }

    private var firstName: String {
        let name = authViewModel.currentProfile?.displayName ?? ""
        return name.components(separatedBy: " ").first ?? name
    }

    private var phase: (name: String, day: Int, of: Int) {
        (name: cycleStore.currentPhase, day: cycleStore.currentDay, of: cycleStore.cycleLength)
    }

    /// Derive collections from recipe categories.
    private var collections: [(name: String, seed: Int, count: Int)] {
        let grouped = Dictionary(grouping: recipeStore.recipes, by: \.category)
        return grouped.sorted { $0.key < $1.key }.map { key, recipes in
            (name: key, seed: abs(key.hashValue) % 6, count: recipes.count)
        }
    }

    // MARK: - Body

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                HomeHeaderView(
                    palette: palette,
                    firstName: firstName,
                    todayString: todayString,
                    phase: phase,
                    phaseAdvice: cycleStore.phaseAdvice,
                    isCycleConfigured: cycleStore.isConfigured,
                    onProfileTap: { showProfile = true }
                )

                featuredSection

                if !recipeStore.recipes.isEmpty {
                    RecipesGridSection(
                        palette: palette,
                        recipes: Array(recipeStore.recipes.dropFirst()),
                        collections: collections,
                        favIds: favsStore.ids,
                        onRecipeTap: onRecipeTap,
                        onFavTap: { favsStore.toggle($0) }
                    )
                }
            }
            .padding(.bottom, 110)
        }
        .background(palette.bg.ignoresSafeArea())
        .sheet(isPresented: $showProfile) {
            NourriProfileView(palette: palette).environmentObject(authViewModel)
        }
    }

    // MARK: - Featured section (loading / empty / hero)

    @ViewBuilder
    private var featuredSection: some View {
        if recipeStore.isLoading && recipeStore.recipes.isEmpty {
            FeaturedRecipePlaceholder(palette: palette, isLoading: true)
        } else if let featured = recipeStore.recipes.first {
            FeaturedRecipeSection(
                palette: palette,
                featured: featured,
                isFav: favsStore.contains(featured.id),
                onRecipeTap: onRecipeTap,
                onFavTap: { favsStore.toggle($0) },
                onSeeAllTap: { onTabChange(.search) }
            )
        } else {
            FeaturedRecipePlaceholder(palette: palette, isLoading: false)
        }
    }
}

// MARK: - Cycle Dial SVG-like
struct CycleDial: View {
    let day: Int
    let of: Int
    let palette: Palette

    var body: some View {
        ZStack {
            Circle().stroke(palette.line, lineWidth: 3)
            Circle()
                .trim(from: 0, to: CGFloat(day) / CGFloat(of))
                .stroke(palette.terracotta, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(day)")
                .font(.custom("Fraunces", size: 14).weight(.medium))
                .foregroundColor(palette.ink)
        }
    }
}

// MARK: - Recipe Card (magazine variant)
struct NourriRecipeCard: View {
    let recipe: AppRecipe
    let palette: Palette
    let isFav: Bool
    let onTap: () -> Void
    let onFav: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    RecipePlateView(seed: recipe.seed, palette: palette)
                        .aspectRatio(4/3, contentMode: .fill)
                        .background(palette.cardAlt)

                    Button(action: onFav) {
                        Image(systemName: isFav ? "heart.fill" : "heart")
                            .font(.system(size: 14))
                            .foregroundColor(isFav ? palette.terracottaDeep : palette.ink)
                            .frame(width: 34, height: 34)
                            .background(.white.opacity(0.85))
                            .clipShape(Circle())
                    }
                    .padding(10)

                    PhaseChip(phase: recipe.phase, palette: palette, small: true)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                        .padding(10)
                }
                .clipped()

                VStack(alignment: .leading, spacing: 8) {
                    Text(recipe.name)
                        .font(.custom("Fraunces", size: 15).weight(.medium))
                        .foregroundColor(palette.ink)
                        .lineLimit(2)
                        .lineSpacing(1)

                    HStack {
                        Label("\(recipe.time) min", systemImage: "clock")
                            .font(.system(size: 11))
                            .foregroundColor(palette.inkSoft)
                        Spacer()
                        AntiInflamBadge(score: recipe.antiInflam, palette: palette, size: .sm)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
            }
        }
        .buttonStyle(.plain)
        .background(palette.card)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 3)
    }
}

// MARK: - Horizontal minimal recipe card
struct NourriRecipeRowCard: View {
    let recipe: AppRecipe
    let palette: Palette
    let isFav: Bool
    let onTap: () -> Void
    let onFav: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                RecipePlateView(seed: recipe.seed, palette: palette)
                    .frame(width: 82, height: 82)
                    .background(palette.cardAlt)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 4) {
                    TagPill(text: recipe.category, foreground: palette.sageDeep, background: palette.sageWash)
                    Text(recipe.name)
                        .font(.custom("Fraunces", size: 15).weight(.medium))
                        .foregroundColor(palette.ink)
                        .lineLimit(2)
                    HStack {
                        Label("\(recipe.time) min", systemImage: "clock")
                            .font(.system(size: 11))
                            .foregroundColor(palette.inkSoft)
                        Spacer()
                        AntiInflamBadge(score: recipe.antiInflam, palette: palette, size: .sm)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(10)
        }
        .buttonStyle(.plain)
        .background(palette.card)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.03), radius: 6, y: 2)
    }
}
