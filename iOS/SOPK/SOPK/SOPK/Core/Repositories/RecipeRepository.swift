import Foundation

// MARK: - Paginated response wrapper (mirrors Edge Function { data, meta })
private struct PaginatedRecipes: Decodable {
    let data: [AppRecipe]
}

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
            let response: PaginatedRecipes = try await client.callFunction("recipes", method: .GET)
            return response.data
        } catch {
            throw AppError(from: error)
        }
    }

    func fetchByCondition(_ condition: String) async throws -> [AppRecipe] {
        do {
            let response: PaginatedRecipes = try await client.callFunction(
                "recipes", method: .GET, query: [("condition", condition)]
            )
            return response.data
        } catch {
            throw AppError(from: error)
        }
    }
}
