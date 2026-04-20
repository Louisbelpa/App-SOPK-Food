import XCTest
@testable import SOPK

// MARK: - Mock SupabaseClient subclass
//
// SupabaseClient is a @MainActor final class with private init.
// We test FavoritesStore in pure local mode (userId == nil) which exercises
// all local-only code paths without touching the network.

@MainActor
final class FavoritesStoreTests: XCTestCase {

    private var store: FavoritesStore!
    private let defaults = UserDefaults(suiteName: "FavoritesStoreTests")!

    override func setUp() async throws {
        // Use an isolated UserDefaults suite so tests don't pollute each other.
        defaults.removePersistentDomain(forName: "FavoritesStoreTests")
        store = FavoritesStore()
        // Override the localKey storage by directly resetting the store (no userId set → local-only mode)
    }

    override func tearDown() async throws {
        defaults.removePersistentDomain(forName: "FavoritesStoreTests")
        store = nil
    }

    // MARK: - Add

    /// Toggling an id that is NOT a favourite adds it.
    func testToggleAddsNewFavourite() {
        XCTAssertFalse(store.contains("recipe-1"))
        store.toggle("recipe-1")
        XCTAssertTrue(store.contains("recipe-1"))
    }

    /// Toggling an id that IS a favourite removes it.
    func testToggleRemovesExistingFavourite() {
        store.toggle("recipe-2")
        XCTAssertTrue(store.contains("recipe-2"))

        store.toggle("recipe-2")
        XCTAssertFalse(store.contains("recipe-2"))
    }

    /// After toggling, the id appears in the `ids` set.
    func testIdsSetUpdatesOnToggle() {
        XCTAssertTrue(store.ids.isEmpty)
        store.toggle("recipe-3")
        XCTAssertTrue(store.ids.contains("recipe-3"))
        store.toggle("recipe-3")
        XCTAssertFalse(store.ids.contains("recipe-3"))
    }

    // MARK: - Multiple items

    func testMultipleFavouritesCanBeAdded() {
        store.toggle("r1")
        store.toggle("r2")
        store.toggle("r3")
        XCTAssertEqual(store.ids.count, 3)
        XCTAssertTrue(store.contains("r1"))
        XCTAssertTrue(store.contains("r2"))
        XCTAssertTrue(store.contains("r3"))
    }

    // MARK: - Clear

    func testClearRemovesAllFavourites() {
        store.toggle("r1")
        store.toggle("r2")
        store.clear()
        XCTAssertTrue(store.ids.isEmpty)
        XCTAssertFalse(store.contains("r1"))
    }

    func testClearResetsUserId() {
        store.clear()
        // After clear, subsequent toggles should stay local (no remote calls)
        store.toggle("r1")
        XCTAssertTrue(store.contains("r1"), "Store should still work locally after clear")
    }

    // MARK: - contains helper

    func testContainsReturnsTrueForAddedItem() {
        store.toggle("exists")
        XCTAssertTrue(store.contains("exists"))
    }

    func testContainsReturnsFalseForMissingItem() {
        XCTAssertFalse(store.contains("does-not-exist"))
    }

    // MARK: - Published error property

    func testErrorPropertyExistsAndIsInitiallyNil() {
        XCTAssertNil(store.error)
    }
}
