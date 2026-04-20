import SwiftUI

struct NourriProfileView: View {
    let palette: Palette
    let isDark: Bool
    let toggleDark: () -> Void
    let onTabChange: (NourriTabBar.AppTab) -> Void

    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var cycleStore: CycleStore
    @State private var showCycleSetup = false
    @State private var showLogoutAlert = false
    @State private var showDeleteAlert = false
    @State private var showConditionPicker = false

    private var displayName: String { authViewModel.currentProfile?.displayName ?? "Vous" }
    private var initials: String { String(displayName.prefix(1)).uppercased() }
    private var conditionLabel: String {
        switch authViewModel.currentProfile?.condition {
        case "sopk": return "SOPK"
        case "endometriose": return "Endométriose"
        case "both": return "SOPK & Endométriose"
        default: return "—"
        }
    }

    private var phaseIndex: Int {
        switch cycleStore.currentPhase {
        case "Folliculaire": return 1
        case "Ovulatoire":   return 2
        case "Lutéale":      return 3
        default:             return 0
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Profil")
                    .font(.custom("Fraunces", size: 30))
                    .foregroundColor(palette.ink)
                    .kerning(-0.5)
                    .padding(.top, 62)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 22)

                // Identity card
                HStack(spacing: 14) {
                    ZStack {
                        Circle().fill(palette.sage)
                        Text(initials)
                            .font(.custom("Fraunces", size: 26).weight(.medium))
                            .foregroundColor(.white)
                    }
                    .frame(width: 64, height: 64)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(displayName)
                            .font(.custom("Fraunces", size: 20).weight(.medium))
                            .foregroundColor(palette.ink)
                        Text(authViewModel.currentUser?.email ?? conditionLabel)
                            .font(.system(size: 12))
                            .foregroundColor(palette.inkSoft)
                    }
                    Spacer()
                }
                .padding(20)
                .background(
                    LinearGradient(colors: [palette.sageWash, palette.cardAlt], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .padding(.horizontal, 20)
                .padding(.bottom, 20)

                // Cycle card — tappable to configure
                Button { showCycleSetup = true } label: {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Mon cycle")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(palette.inkMuted)
                                .kerning(0.5)
                                .textCase(.uppercase)
                            Spacer()
                            Image(systemName: "pencil")
                                .font(.system(size: 13))
                                .foregroundColor(palette.inkMuted)
                        }

                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(cycleStore.isConfigured ? "Jour \(cycleStore.currentDay)" : "Non configuré")
                                    .font(.custom("Fraunces", size: 22).weight(.medium))
                                    .foregroundColor(palette.ink)
                                Text(cycleStore.isConfigured ? "Phase \(cycleStore.currentPhase.lowercased())" : "Appuyer pour configurer")
                                    .font(.system(size: 12))
                                    .foregroundColor(palette.terracottaDeep)
                            }
                            Spacer()
                            HStack(spacing: 4) {
                                ForEach(0..<4, id: \.self) { i in
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(i == phaseIndex && cycleStore.isConfigured ? palette.terracotta : palette.line)
                                        .frame(width: 10, height: 22)
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(palette.card)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.03), radius: 4, y: 1)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)

                // Settings sections
                VStack(spacing: 20) {
                    // Section Santé — lignes tappables
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Santé")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(palette.inkMuted)
                            .kerning(0.5)
                            .textCase(.uppercase)
                            .padding(.horizontal, 4)

                        VStack(spacing: 0) {
                            // Ligne Condition — ouvre le picker
                            Button { showConditionPicker = true } label: {
                                HStack {
                                    Text("Condition")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(palette.ink)
                                    Spacer()
                                    HStack(spacing: 6) {
                                        Text(conditionLabel)
                                            .font(.system(size: 13))
                                            .foregroundColor(palette.inkSoft)
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 13))
                                            .foregroundColor(palette.inkMuted)
                                    }
                                }
                                .padding(.horizontal, 16).padding(.vertical, 14)
                            }
                            .buttonStyle(.plain)

                            Divider().padding(.horizontal, 16)

                            // Ligne Longueur du cycle — ouvre la config cycle
                            Button { showCycleSetup = true } label: {
                                HStack {
                                    Text("Longueur du cycle")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(palette.ink)
                                    Spacer()
                                    HStack(spacing: 6) {
                                        Text("\(cycleStore.cycleLength) jours")
                                            .font(.system(size: 13))
                                            .foregroundColor(palette.inkSoft)
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 13))
                                            .foregroundColor(palette.inkMuted)
                                    }
                                }
                                .padding(.horizontal, 16).padding(.vertical, 14)
                            }
                            .buttonStyle(.plain)
                        }
                        .background(palette.card)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }

                    // Section Application
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Application")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(palette.inkMuted)
                            .kerning(0.5)
                            .textCase(.uppercase)
                            .padding(.horizontal, 4)

                        VStack(spacing: 0) {
                            HStack {
                                Text("Mode sombre")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(palette.ink)
                                Spacer()
                                Toggle("", isOn: Binding(get: { isDark }, set: { _ in toggleDark() }))
                                    .tint(palette.sageDeep)
                                    .labelsHidden()
                            }
                            .padding(.horizontal, 16).padding(.vertical, 14)
                        }
                        .background(palette.card)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }

                    // Logout button
                    Button { showLogoutAlert = true } label: {
                        HStack {
                            Spacer()
                            Text("Se déconnecter")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.red)
                            Spacer()
                        }
                        .padding(.vertical, 14)
                        .background(palette.card)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    .buttonStyle(.plain)

                    // Delete account button
                    Button { showDeleteAlert = true } label: {
                        HStack {
                            Spacer()
                            Text("Supprimer le compte")
                                .font(.system(size: 13))
                                .foregroundColor(palette.inkMuted)
                            Spacer()
                        }
                        .padding(.vertical, 14)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 110)
        }
        .background(palette.bg.ignoresSafeArea())
        .sheet(isPresented: $showCycleSetup) {
            CycleSetupView(palette: palette)
        }
        .sheet(isPresented: $showConditionPicker) {
            ConditionPickerSheet(palette: palette)
        }
        .alert("Se déconnecter ?", isPresented: $showLogoutAlert) {
            Button("Annuler", role: .cancel) {}
            Button("Déconnexion", role: .destructive) {
                Task { await authViewModel.logout() }
            }
        }
        .alert("Supprimer le compte ?", isPresented: $showDeleteAlert) {
            Button("Annuler", role: .cancel) {}
            Button("Supprimer définitivement", role: .destructive) {
                Task { await authViewModel.deleteAccount() }
            }
        } message: {
            Text("Cette action est irréversible. Toutes vos données seront supprimées.")
        }
    }
}

struct ProfileItem {
    let label: String
    let value: String?
    var isToggle: Bool = false
}

// MARK: - Condition Picker Sheet
private struct ConditionPickerSheet: View {
    let palette: Palette
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss

    private let options: [(label: String, value: String?)] = [
        ("SOPK", "sopk"),
        ("Endométriose", "endometriose"),
        ("SOPK & Endométriose", "both"),
        ("Je m'informe", nil),
    ]

    var body: some View {
        VStack(spacing: 0) {
            Text("Votre condition")
                .font(.custom("Fraunces", size: 22))
                .foregroundColor(palette.ink)
                .padding(.top, 28)
                .padding(.bottom, 20)

            ForEach(options, id: \.label) { option in
                Button {
                    Task {
                        await saveCondition(option.value)
                        dismiss()
                    }
                } label: {
                    HStack {
                        Text(option.label)
                            .font(.system(size: 16))
                            .foregroundColor(palette.ink)
                        Spacer()
                        if authViewModel.currentProfile?.condition == option.value {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(palette.sageDeep)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                }
                Divider().padding(.horizontal, 24)
            }
            Spacer()
        }
        .background(palette.bg.ignoresSafeArea())
    }

    private func saveCondition(_ condition: String?) async {
        guard let userId = authViewModel.currentUser?.id else { return }
        struct ConditionUpdate: Encodable { let condition: String? }
        let client = SupabaseClient.shared
        try? await client.requestVoid(
            table: "profiles",
            method: .PATCH,
            query: [("id", "eq.\(userId.uuidString)")],
            body: ConditionUpdate(condition: condition)
        )
        await authViewModel.refreshProfile()
    }
}

// MARK: - Favorites screen
struct NouririFavoritesView: View {
    let palette: Palette
    let isDark: Bool
    let onRecipeTap: (String) -> Void

    @EnvironmentObject private var favsStore: FavoritesStore
    @EnvironmentObject private var recipeStore: RecipeStore

    private var favRecipes: [AppRecipe] { recipeStore.recipes.filter { favsStore.contains($0.id) } }

    private var collections: [(name: String, seed: Int, count: Int)] {
        let grouped = Dictionary(grouping: recipeStore.recipes, by: \.category)
        return grouped.sorted { $0.key < $1.key }.map { key, recipes in
            (name: key, seed: abs(key.hashValue) % 6, count: recipes.count)
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Favoris")
                        .font(.custom("Fraunces", size: 30))
                        .foregroundColor(palette.ink)
                        .kerning(-0.5)
                    Text("\(favRecipes.count) recette\(favRecipes.count != 1 ? "s" : "") · \(collections.count) collection\(collections.count != 1 ? "s" : "")")
                        .font(.system(size: 13))
                        .foregroundColor(palette.inkSoft)
                }
                .padding(.top, 62).padding(.horizontal, 20).padding(.bottom, 16)

                // Collections grid
                VStack(alignment: .leading, spacing: 12) {
                    Text("Mes collections")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(palette.inkMuted)
                        .kerning(0.5).textCase(.uppercase)
                        .padding(.horizontal, 20)

                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                        ForEach(collections, id: \.name) { col in
                            VStack(alignment: .leading, spacing: 0) {
                                RecipePlateView(seed: col.seed, palette: palette)
                                    .aspectRatio(1.5, contentMode: .fill)
                                    .background(palette.cardAlt)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(col.name)
                                        .font(.custom("Fraunces", size: 14).weight(.medium))
                                        .foregroundColor(palette.ink)
                                        .lineLimit(2)
                                    Text("\(col.count) recette\(col.count != 1 ? "s" : "")")
                                        .font(.system(size: 10))
                                        .foregroundColor(palette.inkMuted)
                                }
                                .padding(.horizontal, 12).padding(.vertical, 8)
                            }
                            .background(palette.card)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .shadow(color: .black.opacity(0.03), radius: 4)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 24)

                // Favorite recipes
                VStack(alignment: .leading, spacing: 12) {
                    Text("Récemment aimées")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(palette.inkMuted)
                        .kerning(0.5).textCase(.uppercase)
                        .padding(.horizontal, 20)

                    if favRecipes.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "heart")
                                .font(.system(size: 32))
                                .foregroundColor(palette.inkMuted)
                            Text("Pas encore de favoris")
                                .font(.custom("Fraunces", size: 16))
                                .foregroundColor(palette.ink)
                            Text("Appuyez sur ♡ sur n'importe quelle recette pour l'ajouter.")
                                .font(.system(size: 12))
                                .foregroundColor(palette.inkSoft)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(24)
                        .background(palette.cardAlt)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal, 20)
                    } else {
                        VStack(spacing: 10) {
                            ForEach(favRecipes) { recipe in
                                NourriRecipeRowCard(
                                    recipe: recipe, palette: palette,
                                    isFav: true,
                                    onTap: { onRecipeTap(recipe.id) },
                                    onFav: { favsStore.toggle(recipe.id) }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .padding(.bottom, 110)
        }
        .background(palette.bg.ignoresSafeArea())
    }
}
