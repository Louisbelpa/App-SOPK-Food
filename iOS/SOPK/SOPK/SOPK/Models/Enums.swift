import Foundation

enum Condition: String, CaseIterable, Codable, Identifiable {
    case sopk = "sopk"
    case endometriose = "endometriose"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .sopk: return "SOPK"
        case .endometriose: return "Endométriose"
        }
    }
}

enum MealType: String, CaseIterable, Codable, Identifiable {
    case breakfast = "breakfast"
    case lunch = "lunch"
    case dinner = "dinner"
    case snack = "snack"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .breakfast: return "Petit-déjeuner"
        case .lunch: return "Déjeuner"
        case .dinner: return "Dîner"
        case .snack: return "Snack"
        }
    }

    var icon: String {
        switch self {
        case .breakfast: return "sun.rise.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "moon.fill"
        case .snack: return "leaf.fill"
        }
    }
}

enum IngredientCategory: String, Codable {
    case vegetables = "légumes"
    case proteins = "protéines"
    case grains = "céréales"
    case dairy = "produits laitiers"
    case spices = "épices"
    case fats = "matières grasses"
    case fruits = "fruits"
    case other = "autre"

    var displayName: String { rawValue }
}
