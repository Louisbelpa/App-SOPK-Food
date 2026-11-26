import Foundation

// Modèle d'une recette. Le schéma JSON est décrit dans `docs/kickoff/05-cuisine.md` (clés en français, snake_case).

public struct Recipe: Codable, Hashable, Identifiable, Sendable {
    public let schemaVersion: Int
    public let id: String
    public let titre: String
    public let description: String
    public let typesRepas: [MealType]
    public let portions: Int
    public let temps: Timing
    public let difficulte: String
    public let ingredients: [Ingredient]
    public let etapes: [Step]
    public let tags: Tags
    public let allergenes: [Allergen]
    public let saisons: [Season]
    public let compositionAssiette: PlateComposition
    public let astuces: [Tip]
    public let conservation: Storage?
    public let image: RecipeImage?
    public let source: String
    public let validation: Validation

    public struct Timing: Codable, Hashable, Sendable {
        public let preparationMin: Int
        public let cuissonMin: Int
        public let reposMin: Int
        /// Temps actif (préparation + cuisson), hors repos.
        public let totalMin: Int
    }

    public struct Ingredient: Codable, Hashable, Sendable {
        /// Clé canonique : sert à fusionner les lignes dans la liste de courses.
        public let cle: String
        public let nom: String
        public let quantite: Double?
        public let unite: Unit
        public let rayon: Aisle
        public let preparation: String?
        public let optionnel: Bool
        /// Produit de placard (sel, épices…) : exclu par défaut de la liste de courses.
        public let placard: Bool
        public let groupe: String?
        public let allergenes: [Allergen]
    }

    public struct Step: Codable, Hashable, Sendable {
        public let ordre: Int
        public let texte: String
    }

    public struct Tags: Codable, Hashable, Sendable {
        public let temps: String
        public let igEstime: GlycemicIndex
        public let regimes: [String]
        public let caracteristiques: [String]
    }

    public struct PlateComposition: Codable, Hashable, Sendable {
        public let legumes: Bool
        public let proteines: Bool
        public let feculents: Bool
        public let bonsGras: Bool
    }

    public struct Tip: Codable, Hashable, Sendable {
        public let type: String
        public let texte: String
    }

    public struct Storage: Codable, Hashable, Sendable {
        public let refrigerateurJours: Int?
        public let congelation: Bool
        public let note: String?
    }

    public struct RecipeImage: Codable, Hashable, Sendable {
        public let url: String?
        public let alt: String
        public let credit: String?
    }

    public struct Validation: Codable, Hashable, Sendable {
        public let chef: Bool
        public let dieteticienne: Bool
        public let date: String
    }
}

public enum MealType: String, Codable, CaseIterable, Sendable {
    case petitDejeuner = "petit_dejeuner"
    case dejeuner
    case diner
    case collation
}

public enum Season: String, Codable, CaseIterable, Sendable {
    case printemps, ete, automne, hiver
}

/// Index glycémique **estimé** de la recette. Pas de valeur « élevé » : ces recettes ne sont pas retenues.
public enum GlycemicIndex: String, Codable, Sendable {
    case bas
    case modere
}

/// Les 14 allergènes à déclaration obligatoire (règlement UE 1169/2011, annexe II).
public enum Allergen: String, Codable, CaseIterable, Sendable {
    case gluten, crustaces, oeufs, poissons, arachides, soja, lait
    case fruitsACoque = "fruits_a_coque"
    case celeri, moutarde, sesame, sulfites, lupin, mollusques
}

public enum Unit: String, Codable, CaseIterable, Sendable {
    case g, kg, ml, cl, l
    case piece, tranche, gousse, botte, boite, pincee
    case cac, cas
    case auGout = "au_gout"
}

public enum Aisle: String, Codable, CaseIterable, Sendable {
    case fruitsLegumes = "fruits_legumes"
    case fraisVegetal = "frais_vegetal"
    case cremerieOeufs = "cremerie_oeufs"
    case boucherieVolaille = "boucherie_volaille"
    case poissonnerie
    case boulangerie
    case epicerieSeche = "epicerie_seche"
    case epicerieSucree = "epicerie_sucree"
    case fruitsSecsGraines = "fruits_secs_graines"
    case huilesCondiments = "huiles_condiments"
    case conserves
    case surgeles
}
