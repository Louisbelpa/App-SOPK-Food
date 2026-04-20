import SwiftUI

/// 2-column grid of recipe cards (items after the featured hero) + collections row.
struct RecipesGridSection: View {
    let palette: Palette
    let recipes: [AppRecipe]         // items to display in grid (dropFirst already applied)
    let collections: [(name: String, seed: Int, count: Int)]
    let favIds: Set<String>
    let onRecipeTap: (String) -> Void
    let onFavTap: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            recipeGrid
            collectionsSection
        }
    }

    // MARK: - 2-column grid
    private var recipeGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
            spacing: 12
        ) {
            ForEach(Array(recipes.prefix(4))) { recipe in
                NourriRecipeCard(
                    recipe: recipe,
                    palette: palette,
                    isFav: favIds.contains(recipe.id),
                    onTap: { onRecipeTap(recipe.id) },
                    onFav: { onFavTap(recipe.id) }
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }

    // MARK: - Collections horizontal scroll
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
}
