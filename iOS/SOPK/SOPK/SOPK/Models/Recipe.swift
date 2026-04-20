import Foundation

struct Recipe: Identifiable, Decodable, Hashable {
    let id: UUID
    let title: String
    let description: String?
    let imageUrl: String?
    let prepTime: Int?
    let cookTime: Int?
    let servings: Int?
    let conditions: [String]
    let mealType: String
    let tags: [String]
    let ingredients: [Ingredient]?
    let steps: [Step]?
    let createdAt: Date?

    var totalTime: Int? {
        guard let prep = prepTime, let cook = cookTime else { return prepTime ?? cookTime }
        return prep + cook
    }

    var conditionEnums: [Condition] {
        conditions.compactMap { Condition(rawValue: $0) }
    }

    var mealTypeEnum: MealType? {
        MealType(rawValue: mealType)
    }

    enum CodingKeys: String, CodingKey {
        case id, title, description, tags, conditions, servings
        case imageUrl = "image_url"
        case prepTime = "prep_time"
        case cookTime = "cook_time"
        case mealType = "meal_type"
        case ingredients, steps
        case createdAt = "created_at"
    }
}

struct Ingredient: Identifiable, Decodable, Hashable {
    let id: UUID
    let recipeId: UUID?
    let name: String
    let quantity: Double?
    let unit: String?
    let category: String?

    var categoryEnum: IngredientCategory {
        IngredientCategory(rawValue: category ?? "") ?? .other
    }

    var displayQuantity: String {
        var parts: [String] = []
        if let quantity {
            if quantity == quantity.rounded() {
                parts.append(String(Int(quantity)))
            } else {
                parts.append(String(format: "%.1f", quantity))
            }
        }
        if let unit { parts.append(unit) }
        return parts.joined(separator: " ")
    }

    enum CodingKeys: String, CodingKey {
        case id, name, quantity, unit, category
        case recipeId = "recipe_id"
    }
}

struct Step: Identifiable, Decodable, Hashable {
    let id: UUID
    let recipeId: UUID?
    let position: Int
    let instruction: String

    enum CodingKeys: String, CodingKey {
        case id, position, instruction
        case recipeId = "recipe_id"
    }
}

// MARK: - Mode local (sans Supabase)
extension Recipe {
    /// Recettes factices pour prévisualiser l’app lorsque Supabase n’est pas configuré.
    static let localDemoRecipes: [Recipe] = {
        let r1 = UUID(uuidString: "11111111-1111-4111-8111-111111111111")!
        let r2 = UUID(uuidString: "22222222-2222-4222-8222-222222222222")!
        let ing1 = UUID(uuidString: "aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa1")!
        let ing2 = UUID(uuidString: "aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa2")!
        let ing3 = UUID(uuidString: "aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa3")!
        let st1 = UUID(uuidString: "bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbb1")!
        let st2 = UUID(uuidString: "bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbb2")!
        return [
            Recipe(
                id: r1,
                title: "Bowl curcuma & lentilles (démo)",
                description: "Données locales — connectez Supabase pour les vraies recettes.",
                imageUrl: nil,
                prepTime: 10,
                cookTime: 15,
                servings: 2,
                conditions: [Condition.endometriose.rawValue],
                mealType: MealType.lunch.rawValue,
                tags: ["Sans gluten", "Vegan"],
                ingredients: [
                    Ingredient(id: ing1, recipeId: r1, name: "Lentilles corail", quantity: 120, unit: "g", category: "protéines"),
                    Ingredient(id: ing2, recipeId: r1, name: "Curcuma", quantity: 1, unit: "c.à.c.", category: "épices"),
                ],
                steps: [
                    Step(id: st1, recipeId: r1, position: 1, instruction: "Mijoter les lentilles avec épices et eau 15 min."),
                ],
                createdAt: nil
            ),
            Recipe(
                id: r2,
                title: "Salade avocat & graines (démo)",
                description: "Exemple local pour tester l’interface.",
                imageUrl: nil,
                prepTime: 15,
                cookTime: 0,
                servings: 1,
                conditions: [Condition.sopk.rawValue],
                mealType: MealType.dinner.rawValue,
                tags: ["Oméga-3"],
                ingredients: [
                    Ingredient(id: ing3, recipeId: r2, name: "Avocat", quantity: 1, unit: nil, category: "fruits"),
                ],
                steps: [
                    Step(id: st2, recipeId: r2, position: 1, instruction: "Couper, assaisonner, parsemer de graines."),
                ],
                createdAt: nil
            ),
        ]
    }()
}
