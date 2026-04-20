import Foundation

// MARK: - DI Container (simple factory, no external dependencies)
//
// All stores/repositories are exposed as protocol-typed lazy vars so they can
// be replaced with mocks in unit tests.  Pass a custom AppContainer to
// SOPKApp (or individual views in Previews) to inject test doubles.
//
// Usage (production):  AppContainer.shared
// Usage (tests):       let container = AppContainer(); container.recipeRepository = MockRecipeRepository()

@MainActor
final class AppContainer {

    // MARK: - Singleton (production)
    static let shared = AppContainer()

    // MARK: - Supabase client (shared, concrete)
    var supabaseClient: SupabaseClient { .shared }

    // MARK: - Repositories (protocol-typed, lazy)
    lazy var recipeRepository: any RecipeRepository = SupabaseRecipeRepository(client: supabaseClient)
    lazy var mealPlanRepository: any MealPlanRepository = SupabaseMealPlanRepository(client: supabaseClient)
    lazy var shoppingRepository: any ShoppingRepository = SupabaseShoppingRepository(client: supabaseClient)

    // MARK: - Stores (ObservableObject, lazy)
    lazy var recipeStore: RecipeStore = RecipeStore(repository: recipeRepository)
    lazy var mealPlanStore: MealPlanStore = MealPlanStore(repository: mealPlanRepository)
    lazy var shoppingStore: ShoppingStore = ShoppingStore(repository: shoppingRepository)
    lazy var favoritesStore: FavoritesStore = FavoritesStore(client: supabaseClient)
    lazy var cycleStore: CycleStore = CycleStore(client: supabaseClient)
    lazy var authViewModel: AuthViewModel = AuthViewModel()

    // MARK: - Init
    init() {}
}
