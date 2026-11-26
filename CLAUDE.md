# CLAUDE.md

Guide pour Claude Code (claude.ai/code) dans ce dépôt.

## Projet

**Ovéa** est une app iOS qui aide les femmes atteintes de SOPK au quotidien : alimentation anti-inflammatoire
à IG bas, activité physique adaptée, journal des symptômes et du cycle. **Ce n'est pas un dispositif médical.**

Le dépôt a été remis à zéro en novembre 2026. La V0 (SwiftUI + Supabase + backoffice Next.js) reste sur `main`
jusqu'au merge de la V1, et dans l'historique git. Ne pas s'en inspirer sans relire `docs/kickoff/`.

## Documents de référence (à lire avant toute fonctionnalité)

- `docs/kickoff/07-synthese-decisions.md` : décisions et arbitrages. **En cas de conflit, l'avis médical (`04`) prime.**
- `01-architecture` · `02-ios` (conventions + backlog) · `03-design` · `04-medical` · `05-cuisine` · `06-sport`
- `docs/adr/` : décisions d'architecture (ADR-001 : 100 % local).

## Règles produit non négociables

- **Jamais** de prédiction d'ovulation, de fenêtre fertile, de « jours sûrs » ni de phase du cycle.
- Estimation des prochaines règles : désactivée par défaut, uniquement si les cycles sont réguliers
  (voir `CycleEngine`), toujours en fourchette avec la mention « estimation indicative ».
- Pas de poids (option masquée, désactivée par défaut) ni de calories. Pas de série de jours consécutifs, jamais « en retard ».
- Suggestions de repas et de séances selon le **check-in du jour** (énergie, douleurs, règles, sommeil), pas selon la phase.
- Aucune donnée ne quitte l'appareil. Aucun SDK tiers, aucun analytics.
- Vocabulaire : voir le lexique de `03-design.md` et les formulations interdites de `04-medical.md`.

## Structure

```
App/                 # projet Xcode (à créer sur un Mac, voir App/README.md)
Packages/SOPKKit/    # logique pure + contenu, Foundation uniquement, testable sous Linux
  Sources/SOPKKit/Cycle/     # LocalDate, CycleEngine
  Sources/SOPKKit/Content/   # Recipe, Workout, ContentLibrary
  Sources/SOPKKit/Resources/Content/{recipes,workouts}.json
  Tests/SOPKKitTests/        # Swift Testing, dont validation du contenu
docs/kickoff/  docs/adr/
```

## Commandes

```bash
swift test --package-path Packages/SOPKKit   # tests du package (Linux ou macOS)
swiftlint lint --strict                      # lint (bloquant en CI)
```
App iOS : ouvrir `App/SOPK.xcodeproj` dans Xcode 26, `Cmd+U` pour les tests.

## Conventions iOS (détails dans `02-ios.md`)

- iOS 18 minimum, Swift 6 en mode strict, isolation `MainActor` par défaut.
- SwiftUI + `@Observable` (pas d'`ObservableObject`), SwiftData avec schéma versionné (`SchemaV1` + `MigrationPlan`).
- Une `NavigationStack` par onglet, routes en `enum`. Injection de dépendances via `Environment`, sans framework.
- Toute logique testable (calculs, règles de suggestion, validation) va dans `SOPKKit`, pas dans les vues.
- Les jours se manipulent en `LocalDate`, jamais en `Date` brut.
- Textes dans un String Catalog, français d'abord. Accessibilité : Dynamic Type, VoiceOver, contrastes AA.

## Contenu

Ajouter une recette ou une séance = modifier le JSON correspondant dans `Resources/Content/` en respectant le schéma
de `05-cuisine.md` / `06-sport.md`. `ContentValidationTests` doit passer : identifiants uniques, allergènes cohérents,
exercices existants, aucun mot interdit. Mettre `validation.dieteticienne` à `false` tant qu'elle n'a pas relu.

## CI (`.github/workflows/ci.yml`)

`lint` (SwiftLint strict) et `kit-tests` (`swift test` dans un conteneur `swift:6.2`) à chaque push.
`app-build-test` (macOS, `xcodebuild test`) uniquement sur PR et `main`, et seulement si le projet Xcode existe.
