import Foundation

// MARK: - Sample recipe data (French, adapted for SOPK / endométriose)
struct SampleRecipe: Identifiable {
    let id: Int
    let name: String
    let category: String
    let time: Int
    let antiInflam: Int
    let calories: Int
    let seed: Int
    let tags: [String]
    let symptoms: [String]
    let phase: String
    let benefits: [(label: String, detail: String)]
    let ingredients: [(name: String, qty: String, why: String)]
    let steps: [String]
}

struct SampleCollection: Identifiable {
    let id: String
    let name: String
    let count: Int
    let seed: Int
    let desc: String
}

struct MealPlanDay {
    let day: String
    let date: Int
    let meals: [(slot: String, recipeId: Int)]
}

struct ShoppingCategory {
    let category: String
    let items: [ShoppingListItem]
}
struct ShoppingListItem {
    let name: String
    let qty: String
    var checked: Bool
    let recipes: [Int]
}

struct SymptomItem: Identifiable {
    let id: String
    let label: String
    let icon: String
}
struct AvoidTag: Identifiable {
    let id: String
    let label: String
}

enum SampleData {
    static let recipes: [SampleRecipe] = [
        SampleRecipe(
            id: 1, name: "Bowl curcuma, lentilles corail et épinards",
            category: "Déjeuner", time: 25, antiInflam: 9, calories: 420, seed: 0,
            tags: ["Sans gluten", "Sans lactose", "Vegan"],
            symptoms: ["fatigue", "douleurs"], phase: "Lutéale",
            benefits: [("Anti-inflammatoire", "Curcumine + oméga-3"), ("Riche en fer", "6,2 mg — 43% AJR"), ("Fibres", "14 g — transit régulier")],
            ingredients: [
                ("Lentilles corail", "120 g", "Protéines végétales, index glycémique bas"),
                ("Curcuma frais", "1 c.à.c.", "Curcumine anti-inflammatoire"),
                ("Épinards frais", "80 g", "Fer + magnésium"),
                ("Lait de coco", "150 ml", "Acides gras à chaîne moyenne"),
                ("Gingembre frais", "2 cm", "Réduit les ballonnements"),
                ("Huile d'olive", "1 c.à.s.", "Oméga-9"),
                ("Graines de courge", "15 g", "Zinc — régulation hormonale"),
            ],
            steps: [
                "Rincer les lentilles corail à l'eau froide jusqu'à ce que l'eau soit claire.",
                "Faire revenir le gingembre et le curcuma râpés dans l'huile d'olive pendant 1 minute.",
                "Ajouter les lentilles et couvrir de lait de coco + 200 ml d'eau. Laisser mijoter 15 min.",
                "Incorporer les épinards en fin de cuisson, saler à peine.",
                "Servir dans un bol, parsemer de graines de courge torréfiées.",
            ]
        ),
        SampleRecipe(
            id: 2, name: "Saumon sauvage, quinoa et brocoli rôti",
            category: "Dîner", time: 30, antiInflam: 10, calories: 520, seed: 4,
            tags: ["Sans gluten", "Sans lactose"],
            symptoms: ["inflammation", "humeur"], phase: "Ovulatoire",
            benefits: [("Oméga-3 EPA/DHA", "2,1 g — anti-inflammatoire majeur"), ("Protéines complètes", "38 g"), ("Sélénium", "Thyroïde et ovaires")],
            ingredients: [
                ("Filet de saumon sauvage", "140 g", "Oméga-3 EPA/DHA"),
                ("Quinoa", "80 g", "Protéines complètes, sans gluten"),
                ("Brocoli", "200 g", "Indole-3-carbinol"),
                ("Ail", "2 gousses", "Allicine antioxydante"),
                ("Citron", "1/2", "Vitamine C + détox hépatique"),
                ("Huile d'olive", "2 c.à.s.", "Polyphénols"),
            ],
            steps: [
                "Préchauffer le four à 200°C.",
                "Cuire le quinoa 12 minutes dans l'eau bouillante salée.",
                "Disposer le brocoli et l'ail sur une plaque, arroser d'huile d'olive, rôtir 15 min.",
                "Déposer le saumon sur la plaque les 8 dernières minutes.",
                "Dresser et arroser de jus de citron frais.",
            ]
        ),
        SampleRecipe(
            id: 3, name: "Porridge chia, myrtilles et cannelle",
            category: "Petit-déjeuner", time: 10, antiInflam: 8, calories: 310, seed: 5,
            tags: ["Sans gluten", "Vegan"],
            symptoms: ["énergie", "glycémie"], phase: "Folliculaire",
            benefits: [("Index glycémique bas", "Stabilise l'insuline"), ("Antioxydants", "Anthocyanes des myrtilles"), ("Oméga-3 végétaux", "ALA — graines de chia")],
            ingredients: [
                ("Graines de chia", "3 c.à.s.", "Oméga-3 + fibres"),
                ("Lait d'amande", "250 ml", "Sans lactose"),
                ("Myrtilles fraîches", "80 g", "Anthocyanes"),
                ("Cannelle de Ceylan", "1 c.à.c.", "Sensibilité à l'insuline"),
                ("Amandes effilées", "15 g", "Magnésium"),
            ],
            steps: [
                "Mélanger les graines de chia avec le lait d'amande et la cannelle.",
                "Laisser reposer au réfrigérateur pendant minimum 4 heures (idéalement une nuit).",
                "Au matin, remuer pour détacher la texture.",
                "Garnir de myrtilles et d'amandes effilées.",
            ]
        ),
        SampleRecipe(
            id: 4, name: "Velouté de patate douce au gingembre",
            category: "Dîner", time: 35, antiInflam: 8, calories: 280, seed: 2,
            tags: ["Sans gluten", "Sans lactose", "Vegan"],
            symptoms: ["ballonnements", "digestion"], phase: "Menstruelle",
            benefits: [("Bêta-carotène", "Peau & muqueuses"), ("Digestion apaisée", "Gingembre + cuisson douce"), ("Potassium", "Réduit la rétention d'eau")],
            ingredients: [
                ("Patate douce", "500 g", "Bêta-carotène, IG modéré"),
                ("Gingembre frais", "3 cm", "Anti-nauséeux naturel"),
                ("Lait de coco", "200 ml", "Onctuosité sans lactose"),
                ("Oignon doux", "1", "Prébiotique"),
                ("Bouillon de légumes", "500 ml", ""),
            ],
            steps: [
                "Éplucher et couper la patate douce en cubes.",
                "Faire suer l'oignon dans une casserole avec un peu d'huile.",
                "Ajouter patate douce, gingembre râpé et bouillon. Cuire 20 min.",
                "Mixer finement avec le lait de coco.",
                "Rectifier l'assaisonnement, servir bien chaud.",
            ]
        ),
        SampleRecipe(
            id: 5, name: "Salade tiède de pois chiches, avocat et grenade",
            category: "Déjeuner", time: 15, antiInflam: 9, calories: 450, seed: 3,
            tags: ["Sans gluten", "Sans lactose", "Vegan"],
            symptoms: ["hormones", "énergie"], phase: "Folliculaire",
            benefits: [("Fibres prébiotiques", "Microbiote intestinal"), ("Bons gras", "Avocat — oméga-9"), ("Polyphénols", "Grenade — anti-oxydant puissant")],
            ingredients: [
                ("Pois chiches cuits", "200 g", "Fibres + protéines végétales"),
                ("Avocat mûr", "1", "Acides gras mono-insaturés"),
                ("Graines de grenade", "50 g", "Punicalagines"),
                ("Roquette", "60 g", "Glucosinolates"),
                ("Tahin", "1 c.à.s.", "Calcium végétal"),
                ("Citron", "1", "Vitamine C"),
            ],
            steps: [
                "Réchauffer les pois chiches quelques minutes à la poêle avec une pincée de cumin.",
                "Préparer une sauce tahin, citron et eau tiède.",
                "Dresser la roquette, les pois chiches tièdes, l'avocat en tranches.",
                "Parsemer de graines de grenade, arroser de sauce.",
            ]
        ),
        SampleRecipe(
            id: 6, name: "Smoothie anti-fatigue cacao et banane",
            category: "Petit-déjeuner", time: 5, antiInflam: 7, calories: 290, seed: 1,
            tags: ["Sans gluten", "Vegan"],
            symptoms: ["fatigue", "humeur"], phase: "Lutéale",
            benefits: [("Magnésium", "Cacao cru — détente musculaire"), ("Potassium", "Banane — anti-crampes"), ("Tryptophane", "Précurseur de la sérotonine")],
            ingredients: [
                ("Banane congelée", "1", "Texture onctueuse + potassium"),
                ("Cacao cru en poudre", "2 c.à.c.", "Magnésium élevé"),
                ("Beurre de cacahuète", "1 c.à.s.", "Protéines + gras"),
                ("Lait d'avoine", "250 ml", "Bêta-glucanes"),
                ("Graines de lin", "1 c.à.s.", "Riches en fibres et oméga-3 ALA"),
            ],
            steps: [
                "Placer tous les ingrédients dans un blender.",
                "Mixer 45 secondes jusqu'à obtenir une texture lisse.",
                "Servir immédiatement dans un grand verre.",
            ]
        ),
    ]

    static let collections: [SampleCollection] = [
        SampleCollection(id: "c1", name: "Menstruations douces", count: 12, seed: 2, desc: "Recettes réconfortantes pour la phase menstruelle"),
        SampleCollection(id: "c2", name: "Énergie du matin", count: 8, seed: 5, desc: "Petits-déjeuners stabilisants"),
        SampleCollection(id: "c3", name: "Anti-ballonnements", count: 6, seed: 3, desc: "Digestion légère, ventre apaisé"),
        SampleCollection(id: "c4", name: "Boost hormonal", count: 14, seed: 4, desc: "Zinc, oméga-3, magnésium"),
    ]

    static let mealPlan: [MealPlanDay] = [
        MealPlanDay(day: "Lun", date: 21, meals: [("Matin", 3), ("Midi", 5), ("Soir", 4)]),
        MealPlanDay(day: "Mar", date: 22, meals: [("Matin", 6), ("Midi", 1), ("Soir", 2)]),
        MealPlanDay(day: "Mer", date: 23, meals: [("Matin", 3), ("Midi", 1), ("Soir", 2)]),
        MealPlanDay(day: "Jeu", date: 24, meals: [("Matin", 6), ("Midi", 5), ("Soir", 4)]),
        MealPlanDay(day: "Ven", date: 25, meals: [("Matin", 3), ("Midi", 5), ("Soir", 2)]),
        MealPlanDay(day: "Sam", date: 26, meals: [("Matin", 6), ("Midi", 1), ("Soir", 4)]),
        MealPlanDay(day: "Dim", date: 27, meals: [("Matin", 3), ("Midi", 5), ("Soir", 2)]),
    ]

    static let shopping: [ShoppingCategory] = [
        ShoppingCategory(category: "Légumes & fruits", items: [
            ShoppingListItem(name: "Épinards frais", qty: "160 g", checked: false, recipes: [1]),
            ShoppingListItem(name: "Brocoli", qty: "400 g", checked: true, recipes: [2]),
            ShoppingListItem(name: "Patate douce", qty: "500 g", checked: false, recipes: [4]),
            ShoppingListItem(name: "Avocat mûr", qty: "2", checked: false, recipes: [5]),
            ShoppingListItem(name: "Myrtilles", qty: "160 g", checked: false, recipes: [3]),
            ShoppingListItem(name: "Citron", qty: "3", checked: false, recipes: [2, 5]),
            ShoppingListItem(name: "Grenade", qty: "1", checked: true, recipes: [5]),
            ShoppingListItem(name: "Roquette", qty: "120 g", checked: false, recipes: [5]),
        ]),
        ShoppingCategory(category: "Protéines", items: [
            ShoppingListItem(name: "Saumon sauvage", qty: "280 g", checked: false, recipes: [2]),
            ShoppingListItem(name: "Lentilles corail", qty: "240 g", checked: false, recipes: [1]),
            ShoppingListItem(name: "Pois chiches cuits", qty: "400 g", checked: false, recipes: [5]),
        ]),
        ShoppingCategory(category: "Épicerie", items: [
            ShoppingListItem(name: "Quinoa", qty: "160 g", checked: true, recipes: [2]),
            ShoppingListItem(name: "Graines de chia", qty: "100 g", checked: false, recipes: [3]),
            ShoppingListItem(name: "Lait de coco", qty: "400 ml", checked: false, recipes: [1, 4]),
            ShoppingListItem(name: "Lait d'amande", qty: "500 ml", checked: false, recipes: [3]),
            ShoppingListItem(name: "Curcuma frais", qty: "50 g", checked: false, recipes: [1]),
            ShoppingListItem(name: "Gingembre frais", qty: "80 g", checked: false, recipes: [1, 4]),
            ShoppingListItem(name: "Tahin", qty: "1 pot", checked: false, recipes: [5]),
        ]),
    ]

    static let symptoms: [SymptomItem] = [
        SymptomItem(id: "fatigue", label: "Fatigue", icon: "moon"),
        SymptomItem(id: "douleurs", label: "Douleurs", icon: "flame"),
        SymptomItem(id: "ballonnements", label: "Ballonnements", icon: "drop"),
        SymptomItem(id: "humeur", label: "Humeur basse", icon: "sparkles"),
        SymptomItem(id: "acne", label: "Acné hormonale", icon: "circle.fill"),
        SymptomItem(id: "sommeil", label: "Sommeil agité", icon: "moon.zzz"),
        SymptomItem(id: "glycemie", label: "Fringales sucrées", icon: "bolt"),
        SymptomItem(id: "cycle", label: "Cycle irrégulier", icon: "leaf"),
    ]

    static let avoidTags: [AvoidTag] = [
        AvoidTag(id: "gluten", label: "Sans gluten"),
        AvoidTag(id: "lactose", label: "Sans lactose"),
        AvoidTag(id: "sucre", label: "Sans sucre ajouté"),
        AvoidTag(id: "soja", label: "Sans soja"),
        AvoidTag(id: "oeuf", label: "Sans œuf"),
        AvoidTag(id: "fodmap", label: "Low FODMAP"),
    ]

    // MARK: - AppRecipe versions (fallback quand Supabase non configuré)
    static let appRecipes: [AppRecipe] = recipes.map { r in
        AppRecipe(
            id: "sample-\(r.id)",
            name: r.name,
            category: r.category,
            mealType: mealTypeKey(r.category),
            time: r.time,
            antiInflam: r.antiInflam,
            calories: r.calories,
            conditions: ["sopk", "endometriose"],
            tags: r.tags,
            phase: r.phase,
            description: "",
            benefits: r.benefits.map { AppRecipe.Benefit(label: $0.label, detail: $0.detail) },
            ingredients: r.ingredients.map { AppRecipe.Ingredient(name: $0.name, qty: $0.qty, why: $0.why) },
            steps: r.steps
        )
    }

    private static func mealTypeKey(_ category: String) -> String {
        switch category {
        case "Petit-déjeuner": return "breakfast"
        case "Déjeuner":       return "lunch"
        case "Dîner":          return "dinner"
        default:               return "snack"
        }
    }
}
