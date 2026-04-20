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

    // Derive collections from recipe categories
    private var collections: [(name: String, seed: Int, count: Int)] {
        let grouped = Dictionary(grouping: recipeStore.recipes, by: \.category)
        return grouped.sorted { $0.key < $1.key }.map { key, recipes in
            (name: key, seed: abs(key.hashValue) % 6, count: recipes.count)
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                header
                featuredHero
                recipeGrid
                collectionsSection
            }
            .padding(.bottom, 110)
        }
        .background(palette.bg.ignoresSafeArea())
        .sheet(isPresented: $showProfile) {
            NourriProfileView(palette: palette).environmentObject(authViewModel)
        }
    }

    // MARK: - Header
    private var header: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(todayString)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(palette.inkMuted)
                        .kerning(0.3)
                        .textCase(.uppercase)
                    Text("Bonjour ") + Text(firstName.isEmpty ? "" : firstName).italic().foregroundColor(palette.sageDeep) + Text("")
                }
                .font(.custom("Fraunces", size: 30).weight(.regular))
                .foregroundColor(palette.ink)

                Spacer()

                Button { showProfile = true } label: {
                    Image(systemName: "person")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(palette.ink)
                        .frame(width: 42, height: 42)
                        .background(palette.surface)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(palette.line, lineWidth: 1))
                }
            }

            // Cycle phase banner
            HStack(spacing: 14) {
                CycleDial(day: phase.day, of: phase.of, palette: palette)
                    .frame(width: 56, height: 56)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Phase \(phase.name.lowercased()) · J\(phase.day)")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(palette.inkMuted)
                        .kerning(0.4)
                        .textCase(.uppercase)
                    Text(cycleStore.isConfigured ? cycleStore.phaseAdvice : "Configurez votre cycle pour des recommandations personnalisées")
                        .font(.custom("Fraunces", size: 17))
                        .foregroundColor(palette.ink)
                        .lineSpacing(2)
                }
                Spacer()
            }
            .padding(16)
            .background(palette.cardAlt)
            .clipShape(RoundedRectangle(cornerRadius: 22))
        }
        .padding(.top, 70)
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }

    // MARK: - Section title
    private var sectionHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Pour votre phase")
                .font(.custom("Fraunces", size: 22).weight(.medium))
                .foregroundColor(palette.ink)
                .kerning(-0.3)
            Spacer()
            Button { onTabChange(.search) } label: {
                Text("Tout voir")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(palette.sageDeep)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    // MARK: - Featured hero
    private var featuredHero: some View {
        if recipeStore.isLoading && recipeStore.recipes.isEmpty {
            return AnyView(
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
            )
        }
        guard let featured = recipeStore.recipes.first else {
            return AnyView(
                VStack(spacing: 12) {
                    Image(systemName: "fork.knife")
                        .font(.system(size: 36))
                        .foregroundColor(palette.inkMuted)
                    Text("Aucune recette disponible")
                        .font(.custom("Fraunces", size: 18))
                        .foregroundColor(palette.inkSoft)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 60)
            )
        }
        return AnyView(VStack(spacing: 0) {
            sectionHeader

            Button { onRecipeTap(featured.id) } label: {
                ZStack(alignment: .bottom) {
                    RecipePlateView(seed: featured.seed, palette: palette)
                        .aspectRatio(4/3, contentMode: .fill)

                    // gradient overlay
                    LinearGradient(
                        colors: [.black.opacity(0.6), .clear],
                        startPoint: .bottom, endPoint: .init(x: 0.5, y: 0.45)
                    )

                    VStack(alignment: .leading, spacing: 8) {
                        Spacer()
                        HStack {
                            HStack(spacing: 4) {
                                Image(systemName: "sparkle")
                                    .font(.system(size: 10, weight: .semibold))
                                Text("Recommandé")
                                    .font(.system(size: 11, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 9).padding(.vertical, 4)
                            .background(.white.opacity(0.2))
                            .clipShape(Capsule())
                            .background(Capsule().fill(.ultraThinMaterial).opacity(0.6))
                            Spacer()

                            // Fav button
                            Button { toggleFav(featured.id) } label: {
                                Image(systemName: favsStore.contains(featured.id) ? "heart.fill" : "heart")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .background(.white.opacity(0.25))
                                    .clipShape(Circle())
                                    .background(Circle().fill(.ultraThinMaterial).opacity(0.6))
                            }
                        }
                        .padding(.horizontal, 16)

                        VStack(alignment: .leading, spacing: 8) {
                            Text(featured.name)
                                .font(.custom("Fraunces", size: 22).weight(.medium))
                                .foregroundColor(.white)
                                .lineSpacing(1)
                                .kerning(-0.2)
                            HStack(spacing: 10) {
                                Label("\(featured.time) min", systemImage: "clock")
                                Text("·")
                                Text("\(featured.calories) kcal")
                                Text("·")
                                Text("Anti-inflam \(featured.antiInflam)/10")
                            }
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.9))
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                }
            }
            .buttonStyle(.plain)
            .clipShape(RoundedRectangle(cornerRadius: 26))
            .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
            .padding(.horizontal, 20)
            .padding(.top, 12)
        })
    }

    // MARK: - Recipe grid
    private var recipeGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            ForEach(Array(recipeStore.recipes.dropFirst().prefix(4))) { recipe in
                NourriRecipeCard(recipe: recipe, palette: palette, isFav: favsStore.contains(recipe.id),
                                 onTap: { onRecipeTap(recipe.id) }, onFav: { toggleFav(recipe.id) })
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }

    // MARK: - Collections
    private var collectionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Collections")
                .font(.custom("Fraunces", size: 22).weight(.medium))
                .foregroundColor(palette.ink)
                .kerning(-0.3)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(collections, id: \.name) { col in
                        VStack(alignment: .leading, spacing: 0) {
                            RecipePlateView(seed: col.seed, palette: palette)
                                .aspectRatio(1.3, contentMode: .fill)
                                .frame(width: 180)
                                .clipped()

                            VStack(alignment: .leading, spacing: 2) {
                                Text(col.name)
                                    .font(.custom("Fraunces", size: 15).weight(.medium))
                                    .foregroundColor(palette.ink)
                                Text("\(col.count) recette\(col.count != 1 ? "s" : "")")
                                    .font(.system(size: 11))
                                    .foregroundColor(palette.inkMuted)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                        }
                        .frame(width: 180)
                        .background(palette.card)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(palette.line, lineWidth: 1))
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.top, 20)
    }

    private func toggleFav(_ id: String) {
        favsStore.toggle(id)
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
