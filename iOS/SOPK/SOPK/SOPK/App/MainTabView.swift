import SwiftUI

// Main app shell with Nourrir design tab bar
struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var recipeStore: RecipeStore
    @AppStorage("isDarkMode") var isDark = false
    @State private var activeTab: NourriTabBar.AppTab = .home
    @State private var selectedRecipeId: String? = nil

    var palette: Palette { isDark ? .dark : .light }

    var body: some View {
        TabView(selection: $activeTab) {
            NourriHomeView(
                palette: palette,
                isDark: isDark,
                onRecipeTap: { id in selectedRecipeId = id },
                onTabChange: { activeTab = $0 }
            )
            .tag(NourriTabBar.AppTab.home)
            .tabItem {
                Label("Accueil", systemImage: "house")
            }

            NourriSearchView(
                palette: palette,
                isDark: isDark,
                onRecipeTap: { id in selectedRecipeId = id }
            )
            .tag(NourriTabBar.AppTab.search)
            .tabItem {
                Label("Recherche", systemImage: "magnifyingglass")
            }

            NourriPlanView(
                palette: palette,
                isDark: isDark,
                onRecipeTap: { id in selectedRecipeId = id }
            )
            .tag(NourriTabBar.AppTab.plan)
            .tabItem {
                Label("Plan", systemImage: "calendar")
            }

            NourriShoppingView(palette: palette, isDark: isDark)
                .tag(NourriTabBar.AppTab.cart)
                .tabItem {
                    Label("Courses", systemImage: "cart")
                }

            NourriProfileView(
                palette: palette,
                isDark: isDark,
                toggleDark: { isDark.toggle() },
                onTabChange: { activeTab = $0 }
            )
            .tag(NourriTabBar.AppTab.profile)
            .tabItem {
                Label("Profil", systemImage: "person")
            }
        }
        .tint(palette.sageDeep)
        .sheet(item: Binding(
            get: { selectedRecipeId.map { RecipeIDWrapper(id: $0) } },
            set: { selectedRecipeId = $0?.id }
        )) { wrapper in
            if let recipe = recipeStore.recipe(id: wrapper.id) {
                NourriRecipeDetailView(recipe: recipe, palette: palette, isDark: isDark)
            }
        }
        .task { await recipeStore.load() }
    }
}

struct RecipeIDWrapper: Identifiable {
    let id: String
}
