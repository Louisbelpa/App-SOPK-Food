import SwiftUI

@main
struct SOPKApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var favsStore = FavoritesStore()
    @StateObject private var recipeStore = RecipeStore()
    @StateObject private var cycleStore = CycleStore()
    @StateObject private var mealPlanStore = MealPlanStore()
    @StateObject private var shoppingStore = ShoppingStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authViewModel)
                .environmentObject(favsStore)
                .environmentObject(recipeStore)
                .environmentObject(cycleStore)
                .environmentObject(mealPlanStore)
                .environmentObject(shoppingStore)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var favsStore: FavoritesStore
    @EnvironmentObject var cycleStore: CycleStore
    @AppStorage("onboarding_completed") private var onboardingCompleted = false
    @AppStorage("family_setup_skipped") private var familySetupSkipped = false

    var body: some View {
        Group {
            if authViewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if authViewModel.currentUser == nil {
                NourriAuthWelcomeView(palette: .light)
            } else if authViewModel.currentProfile?.familyId == nil && !familySetupSkipped {
                FamilySetupView()
            } else if !onboardingCompleted {
                NourriOnboardingView(palette: .light) {
                    onboardingCompleted = true
                }
            } else {
                MainTabView()
            }
        }
        .task {
            await authViewModel.restoreSession()
        }
        .onChange(of: authViewModel.currentProfile) { _, profile in
            if let profile {
                Task { await favsStore.sync(userId: profile.id) }
                cycleStore.sync(profile: profile)
            } else {
                favsStore.clear()
                cycleStore.clear()
            }
        }
    }
}
