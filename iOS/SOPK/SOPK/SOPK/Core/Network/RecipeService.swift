import Foundation

actor RecipeService {
    static let shared = RecipeService()
    private let client = SupabaseClient.shared

    func fetchAll() async throws -> [AppRecipe] {
        try await client.callFunction("recipes", method: .GET)
    }

    func fetchByCondition(_ condition: String) async throws -> [AppRecipe] {
        try await client.callFunction("recipes", method: .GET, query: [("condition", condition)])
    }
}
