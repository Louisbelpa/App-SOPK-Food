import Foundation

struct MealPlanEntry: Identifiable, Decodable {
    let id: UUID
    let familyId: UUID
    let recipeId: UUID
    let date: String
    let mealType: String
    let addedBy: UUID?
    var recipe: Recipe?

    var mealTypeEnum: MealType? { MealType(rawValue: mealType) }

    enum CodingKeys: String, CodingKey {
        case id, date, recipe
        case familyId = "family_id"
        case recipeId = "recipe_id"
        case mealType = "meal_type"
        case addedBy = "added_by"
    }
}

struct ShoppingItem: Identifiable, Decodable {
    let id: UUID
    let familyId: UUID
    let name: String
    let quantity: Double?
    let unit: String?
    let category: String?
    var isChecked: Bool
    let addedBy: UUID?
    let createdAt: Date?

    var categoryEnum: IngredientCategory {
        IngredientCategory(rawValue: category ?? "") ?? .other
    }

    enum CodingKeys: String, CodingKey {
        case id, name, quantity, unit, category
        case familyId = "family_id"
        case isChecked = "is_checked"
        case addedBy = "added_by"
        case createdAt = "created_at"
    }
}
