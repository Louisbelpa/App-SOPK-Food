import SwiftUI
import Combine

@MainActor
final class RecipeStore: ObservableObject {
    @Published private(set) var recipes: [AppRecipe] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: String?

    private let service = RecipeService.shared

    func load() async {
        guard recipes.isEmpty else { return }  // évite les rechargements inutiles
        isLoading = true
        error = nil
        do {
            if SupabaseConfig.isConfigured {
                recipes = try await service.fetchAll()
            } else {
                // Mode local : convertit SampleData en AppRecipe
                recipes = SampleData.appRecipes
            }
        } catch {
            self.error = error.localizedDescription
            recipes = SampleData.appRecipes  // fallback toujours dispo
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
