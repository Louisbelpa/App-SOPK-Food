import SwiftUI

/// Featured hero recipe card with a "Pour votre phase" section header.
struct FeaturedRecipeSection: View {
    let palette: Palette
    let featured: AppRecipe
    let isFav: Bool
    let onRecipeTap: (String) -> Void
    let onFavTap: (String) -> Void
    let onSeeAllTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            sectionHeader
            heroCard
        }
    }

    // MARK: - Section title
    private var sectionHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Pour votre phase")
                .font(.custom("Fraunces", size: 22).weight(.medium))
                .foregroundColor(palette.ink)
                .kerning(-0.3)
            Spacer()
            Button(action: onSeeAllTap) {
                Text("Tout voir")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(palette.sageDeep)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    // MARK: - Hero card
    private var heroCard: some View {
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
                        Button { onFavTap(featured.id) } label: {
                            Image(systemName: isFav ? "heart.fill" : "heart")
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
    }
}

/// Placeholder shown while recipes are loading or when none are available.
struct FeaturedRecipePlaceholder: View {
    let palette: Palette
    let isLoading: Bool

    var body: some View {
        if isLoading {
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.top, 60)
        } else {
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
        }
    }
}
