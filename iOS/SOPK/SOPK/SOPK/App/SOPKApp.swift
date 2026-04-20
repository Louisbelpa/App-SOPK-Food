import SwiftUI

@main
struct SOPKApp: App {
    // All stores are vended by the DI container so they can be replaced in tests.
    private let container = AppContainer.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(container.authViewModel)
                .environmentObject(container.favoritesStore)
                .environmentObject(container.recipeStore)
                .environmentObject(container.cycleStore)
                .environmentObject(container.mealPlanStore)
                .environmentObject(container.shoppingStore)
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
