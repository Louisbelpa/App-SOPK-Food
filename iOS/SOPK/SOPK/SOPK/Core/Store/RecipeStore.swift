import SwiftUI
import Combine

@MainActor
final class RecipeStore: ObservableObject {
    @Published private(set) var recipes: [AppRecipe] = []
    @Published private(set) var isLoading = false
    @Published var error: AppError?

    private let repository: any RecipeRepository

    init(repository: any RecipeRepository = SupabaseRecipeRepository()) {
        self.repository = repository
    }

    func load() async {
        guard recipes.isEmpty else { return }  // évite les rechargements inutiles
        isLoading = true
        error = nil
        do {
            recipes = try await repository.fetchAll()
        } catch let appError as AppError {
            self.error = appError
            recipes = SampleData.appRecipes  // fallback toujours dispo
        } catch {
            self.error = AppError(from: error)
            recipes = SampleData.appRecipes
        }
        isLoading = false
    }

    func reload() async {
        recipes = []
        await load()
    }

    func recipe(id: String) -> AppRecipe? {
        recipes.first { $0.id == id }
    }
}
