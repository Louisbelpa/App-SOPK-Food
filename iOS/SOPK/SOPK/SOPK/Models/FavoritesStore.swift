import SwiftUI
import Combine

@MainActor
final class FavoritesStore: ObservableObject {
    @Published private(set) var ids: Set<String> = []
    @Published var error: AppError?

    private let localKey = "nourrir.favs.v2"
    private let client: SupabaseClient
    private var userId: UUID?

    // MARK: - Init (charge depuis UserDefaults en attendant la synchro)
    init(client: SupabaseClient = .shared) {
        self.client = client
        if let saved = UserDefaults.standard.array(forKey: localKey) as? [String] {
            ids = Set(saved)
        }
    }

    // MARK: - Sync depuis Supabase (appelé après login)
    func sync(userId: UUID) async {
        self.userId = userId
        do {
            struct FavRow: Decodable { let recipe_id: String }
            let rows: [FavRow] = try await client.request(
                table: "favorites",
                query: [("user_id", "eq.\(userId.uuidString)"), ("select", "recipe_id")]
            )
            ids = Set(rows.map(\.recipe_id))
            persist()
        } catch {
            // On garde les favoris locaux si le réseau échoue — pas d'erreur publiée ici
        }
    }

    // MARK: - Toggle (optimistic + Supabase)
    func toggle(_ id: String) {
        if ids.contains(id) {
            ids.remove(id)
            persist()
            Task { await removeRemote(id) }
        } else {
            ids.insert(id)
            persist()
            Task { await addRemote(id) }
        }
    }

    func contains(_ id: String) -> Bool { ids.contains(id) }

    // MARK: - Réinitialiser à la déconnexion
    func clear() {
        userId = nil
        ids = []
        UserDefaults.standard.removeObject(forKey: localKey)
    }

    // MARK: - Privé
    private func persist() {
        UserDefaults.standard.set(Array(ids), forKey: localKey)
    }

    private func addRemote(_ recipeId: String) async {
        guard let uid = userId else { return }
        struct Body: Encodable { let user_id: String; let recipe_id: String }
        do {
            try await client.requestVoid(
                table: "favorites",
                method: .POST,
                body: Body(user_id: uid.uuidString, recipe_id: recipeId)
            )
        } catch {
            self.error = AppError(from: error)
        }
    }

    private func removeRemote(_ recipeId: String) async {
        guard let uid = userId else { return }
        do {
            try await client.requestVoid(
                table: "favorites",
                method: .DELETE,
                query: [
                    ("user_id",   "eq.\(uid.uuidString)"),
                    ("recipe_id", "eq.\(recipeId)"),
                ]
            )
        } catch {
            self.error = AppError(from: error)
        }
    }
}
