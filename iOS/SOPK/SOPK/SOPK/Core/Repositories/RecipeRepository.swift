import Foundation

// MARK: - Protocol
protocol RecipeRepository {
    func fetchAll() async throws -> [AppRecipe]
    func fetchByCondition(_ condition: String) async throws -> [AppRecipe]
}

// MARK: - Supabase implementation
final class SupabaseRecipeRepository: RecipeRepository {
    private let client: SupabaseClient

    init(client: SupabaseClient = .shared) {
        self.client = client
    }

    func fetchAll() async throws -> [AppRecipe] {
        do {
            return try await client.callFunction("recipes", method: .GET)
        } catch {
            throw AppError(from: error)
        }
    }

    func fetchByCondition(_ condition: String) async throws -> [AppRecipe] {
        do {
            return try await client.callFunction("recipes", method: .GET, query: [("condition", condition)])
        } catch {
            throw AppError(from: error)
        }
    }
}
