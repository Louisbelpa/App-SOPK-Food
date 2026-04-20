import XCTest
@testable import SOPK

// MARK: - Mock repository that always throws a network error

final class FailingRecipeRepository: RecipeRepository {
    func fetchAll() async throws -> [AppRecipe] {
        throw AppError.network("No connection")
    }
    func fetchByCondition(_ condition: String) async throws -> [AppRecipe] {
        throw AppError.network("No connection")
    }
}

// MARK: - Mock repository that returns a single stub recipe

final class StubRecipeRepository: RecipeRepository {
    let stubRecipes: [AppRecipe]

    init(recipes: [AppRecipe] = SampleData.appRecipes) {
        self.stubRecipes = recipes
    }

    func fetchAll() async throws -> [AppRecipe] {
        return stubRecipes
    }

    func fetchByCondition(_ condition: String) async throws -> [AppRecipe] {
        return stubRecipes.filter { $0.conditions.contains(condition) }
    }
}

// MARK: - Tests

@MainActor
final class RecipeStoreTests: XCTestCase {

    /// When the repository throws, the store falls back to SampleData and publishes an error.
    func testOfflineFallbackToSampleData() async {
        let store = RecipeStore(repository: FailingRecipeRepository())
        XCTAssertTrue(store.recipes.isEmpty, "Recipes should be empty before load")

        await store.load()

        XCTAssertFalse(store.recipes.isEmpty, "Store should fall back to sample data on network failure")
        XCTAssertEqual(store.recipes.count, SampleData.appRecipes.count)
        XCTAssertNotNil(store.error, "An error should be published after a network failure")
        if case .network = store.error! {
            // correct error case
        } else {
            XCTFail("Expected .network error, got \(store.error!)")
        }
    }

    /// When the repository succeeds, recipes are populated and no error is set.
    func testSuccessfulLoad() async {
        let store = RecipeStore(repository: StubRecipeRepository())
        await store.load()

        XCTAssertEqual(store.recipes.count, SampleData.appRecipes.count)
        XCTAssertNil(store.error, "No error expected on successful load")
        XCTAssertFalse(store.isLoading, "isLoading should be false after load completes")
    }

    /// A second call to load() should be a no-op (guard recipes.isEmpty).
    func testLoadIsIdempotent() async {
        var callCount = 0
        final class CountingRepository: RecipeRepository {
            var onFetch: () -> Void = {}
            func fetchAll() async throws -> [AppRecipe] {
                onFetch()
                return SampleData.appRecipes
            }
            func fetchByCondition(_ condition: String) async throws -> [AppRecipe] { [] }
        }
        let repo = CountingRepository()
        repo.onFetch = { callCount += 1 }
        let store = RecipeStore(repository: repo)

        await store.load()
        await store.load()   // second call — should be skipped

        XCTAssertEqual(callCount, 1, "Repository should only be called once while recipes are cached")
    }

    /// reload() clears the cache and fetches again.
    func testReloadRefetchesData() async {
        var callCount = 0
        final class CountingRepository: RecipeRepository {
            var onFetch: () -> Void = {}
            func fetchAll() async throws -> [AppRecipe] { onFetch(); return SampleData.appRecipes }
            func fetchByCondition(_ condition: String) async throws -> [AppRecipe] { [] }
        }
        let repo = CountingRepository()
        repo.onFetch = { callCount += 1 }
        let store = RecipeStore(repository: repo)

        await store.load()
        await store.reload()

        XCTAssertEqual(callCount, 2, "reload() should trigger a second network fetch")
    }

    /// recipe(id:) returns the correct recipe by id.
    func testRecipeLookupById() async {
        let store = RecipeStore(repository: StubRecipeRepository())
        await store.load()

        let first = SampleData.appRecipes[0]
        let found = store.recipe(id: first.id)
        XCTAssertEqual(found?.id, first.id)
        XCTAssertNil(store.recipe(id: "non-existent-id"))
    }
}
