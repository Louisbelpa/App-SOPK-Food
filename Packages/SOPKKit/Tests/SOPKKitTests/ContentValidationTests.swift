import Testing
@testable import SOPKKit

/// Garde-fous éditoriaux sur le contenu embarqué (`docs/kickoff/04-medical.md`, `05-cuisine.md`, `06-sport.md`).
/// Un JSON mal formé ou un mot interdit fait échouer la CI.
struct ContentValidationTests {
    /// Vocabulaire culpabilisant ou pseudo-médical à ne jamais employer.
    static let forbiddenWords = ["détox", "detox", "triche", "calorie", "minceur", "maigrir", "brûle-graisse", "guérir", "miracle"]

    @Test func recipesDecodeAndHaveUniqueIds() throws {
        let recipes = try ContentLibrary.recipes()
        #expect(recipes.count >= 12)
        #expect(Set(recipes.map(\.id)).count == recipes.count)
    }

    @Test func recipesAreConsistent() throws {
        for recipe in try ContentLibrary.recipes() {
            #expect(recipe.portions > 0, "\(recipe.id)")
            #expect(!recipe.ingredients.isEmpty && !recipe.etapes.isEmpty, "\(recipe.id)")
            #expect(recipe.etapes.map(\.ordre) == Array(1...recipe.etapes.count), "\(recipe.id) : étapes mal numérotées")
            // Les allergènes de la recette couvrent ceux de chaque ingrédient non optionnel.
            let fromIngredients = Set(recipe.ingredients.filter { !$0.optionnel }.flatMap(\.allergenes))
            #expect(fromIngredients.isSubset(of: Set(recipe.allergenes)), "\(recipe.id) : allergène manquant")
            #expect(recipe.image?.alt.isEmpty == false, "\(recipe.id) : texte alternatif d'image manquant")
        }
    }

    @Test func workoutsReferenceExistingExercises() throws {
        let catalog = try ContentLibrary.workouts()
        #expect(Set(catalog.exercises.map(\.id)).count == catalog.exercises.count)
        #expect(Set(catalog.sessions.map(\.id)).count == catalog.sessions.count)
        for session in catalog.sessions {
            #expect((1...3).contains(session.level), "\(session.id)")
            for item in session.blocks.flatMap(\.items) {
                #expect(catalog.exercise(id: item.exerciseId) != nil, "\(session.id) : exercice inconnu \(item.exerciseId)")
                #expect(item.durationSec != nil || item.reps != nil, "\(session.id) : ni durée ni répétitions")
            }
        }
    }

    @Test func contentAvoidsForbiddenWords() throws {
        var texts: [String] = []
        for recipe in try ContentLibrary.recipes() {
            texts += [recipe.titre, recipe.description]
            texts += recipe.etapes.map(\.texte)
            texts += recipe.astuces.map(\.texte)
        }
        for session in try ContentLibrary.workouts().sessions {
            texts += [session.title, session.subtitle]
            texts += session.instructions
        }

        for text in texts {
            let lowered = text.lowercased()
            for word in Self.forbiddenWords {
                #expect(!lowered.contains(word), "« \(word) » trouvé dans : \(text)")
            }
        }
    }
}
