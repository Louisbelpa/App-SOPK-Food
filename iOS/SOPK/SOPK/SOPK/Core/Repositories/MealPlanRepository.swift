import Foundation

// MARK: - DTO types shared between protocol and implementation
struct MealPlanEntryDTO {
    let id: String
    let familyId: String
    let recipeId: String
    let date: String
    let mealType: String
}

// MARK: - Protocol
protocol MealPlanRepository {
    func fetchEntries(familyId: UUID, date: Date) async throws -> [MealPlanEntryDTO]
    func addEntry(familyId: UUID, recipeId: String, date: Date, mealType: String) async throws
    func removeEntry(entryId: String) async throws
}

// MARK: - Supabase implementation
final class SupabaseMealPlanRepository: MealPlanRepository {
    private let client: SupabaseClient

    init(client: SupabaseClient = .shared) {
        self.client = client
    }

    func fetchEntries(familyId: UUID, date: Date) async throws -> [MealPlanEntryDTO] {
        struct DBEntry: Decodable {
            let id: String
            let familyId: String
            let recipeId: String
            let date: String
            let mealType: String

            enum CodingKeys: String, CodingKey {
                case id, date
                case familyId  = "family_id"
                case recipeId  = "recipe_id"
                case mealType  = "meal_type"
            }
        }

        do {
            let entries: [DBEntry] = try await client.callFunction(
                "meal-plan",
                method: .GET,
                query: [
                    ("family_id", familyId.uuidString),
                    ("date", DateFormatter.isoDate.string(from: date))
                ]
            )
            return entries.map { MealPlanEntryDTO(id: $0.id, familyId: $0.familyId,
                                                   recipeId: $0.recipeId, date: $0.date,
                                                   mealType: $0.mealType) }
        } catch {
            throw AppError(from: error)
        }
    }

    func addEntry(familyId: UUID, recipeId: String, date: Date, mealType: String) async throws {
        struct Body: Encodable {
            let family_id: String
            let recipe_id: String
            let date: String
            let meal_type: String
        }
        do {
            try await client.callFunctionVoid(
                "meal-plan",
                method: .POST,
                body: Body(
                    family_id: familyId.uuidString,
                    recipe_id: recipeId,
                    date: DateFormatter.isoDate.string(from: date),
                    meal_type: mealType
                )
            )
        } catch {
            throw AppError(from: error)
        }
    }

    func removeEntry(entryId: String) async throws {
        do {
            try await client.callFunctionVoid(
                "meal-plan",
                method: .DELETE,
                body: ["entry_id": entryId]
            )
        } catch {
            throw AppError(from: error)
        }
    }
}
