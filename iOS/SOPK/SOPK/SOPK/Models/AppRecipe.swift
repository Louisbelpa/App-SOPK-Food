import Foundation

// MARK: - Canonical recipe model — decoded directly from the /functions/v1/recipes API
struct AppRecipe: Identifiable, Hashable, Decodable {
    let id: String
    let name: String
    let category: String
    let mealType: String
    let time: Int
    let antiInflam: Int
    let calories: Int
    let conditions: [String]
    let tags: [String]
    let allergens: [String]
    let phase: String
    let description: String
    let benefits: [Benefit]
    let ingredients: [Ingredient]
    let steps: [String]

    var seed: Int { abs(id.hashValue) % 6 }

    struct Benefit: Decodable, Hashable {
        let label: String
        let detail: String
    }

    struct Ingredient: Decodable, Hashable {
        let name: String
        let qty: String
        let why: String

        init(name: String, qty: String, why: String) {
            self.name = name; self.qty = qty; self.why = why
        }

        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            name = try c.decode(String.self, forKey: .name)
            qty  = try c.decode(String.self, forKey: .qty)
            why  = (try? c.decode(String.self, forKey: .why)) ?? ""
        }

        enum CodingKeys: String, CodingKey { case name, qty, why }
    }

    enum CodingKeys: String, CodingKey {
        case id, name, category, time, phase, description, benefits, ingredients, steps, tags, conditions
        case mealType   = "meal_type"
        case antiInflam = "anti_inflam"
        case calories
        case allergens
    }

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: AppRecipe, rhs: AppRecipe) -> Bool { lhs.id == rhs.id }
}
