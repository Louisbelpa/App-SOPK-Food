import Foundation

// MARK: - DTO types
struct ShoppingItemDTO {
    let id: String
    let name: String
    let quantity: Double?
    let unit: String?
    let category: String?
    let isChecked: Bool
}

// MARK: - Protocol
protocol ShoppingRepository {
    func fetchItems(familyId: UUID) async throws -> [ShoppingItemDTO]
    func toggleItem(itemId: String, isChecked: Bool) async throws
    func addItem(familyId: UUID, name: String, qty: String, category: String) async throws
    func clearCheckedItems(familyId: UUID) async throws
}

// MARK: - Supabase implementation
final class SupabaseShoppingRepository: ShoppingRepository {
    private let client: SupabaseClient

    init(client: SupabaseClient = .shared) {
        self.client = client
    }

    func fetchItems(familyId: UUID) async throws -> [ShoppingItemDTO] {
        struct FetchedItem: Decodable {
            let id: String
            let name: String
            let quantity: Double?
            let unit: String?
            let category: String?
            let isChecked: Bool

            enum CodingKeys: String, CodingKey {
                case id, name, quantity, unit, category
                case isChecked = "is_checked"
            }
        }

        do {
            let items: [FetchedItem] = try await client.callFunction(
                "shopping",
                method: .GET,
                query: [("family_id", familyId.uuidString)]
            )
            return items.map { ShoppingItemDTO(id: $0.id, name: $0.name, quantity: $0.quantity,
                                                unit: $0.unit, category: $0.category,
                                                isChecked: $0.isChecked) }
        } catch {
            throw AppError(from: error)
        }
    }

    func toggleItem(itemId: String, isChecked: Bool) async throws {
        struct ToggleBody: Encodable {
            let item_id: String
            let is_checked: Bool
        }
        do {
            try await client.callFunctionVoid(
                "shopping",
                method: .PATCH,
                body: ToggleBody(item_id: itemId, is_checked: isChecked)
            )
        } catch {
            throw AppError(from: error)
        }
    }

    func addItem(familyId: UUID, name: String, qty: String, category: String) async throws {
        struct NewItem: Encodable {
            let family_id: String
            let name: String
            let qty: String
            let category: String
        }
        do {
            try await client.callFunctionVoid(
                "shopping",
                method: .POST,
                body: NewItem(family_id: familyId.uuidString, name: name, qty: qty, category: category)
            )
        } catch {
            throw AppError(from: error)
        }
    }

    func clearCheckedItems(familyId: UUID) async throws {
        do {
            try await client.callFunctionVoid(
                "shopping",
                method: .DELETE,
                body: ["family_id": familyId.uuidString]
            )
        } catch {
            throw AppError(from: error)
        }
    }
}
