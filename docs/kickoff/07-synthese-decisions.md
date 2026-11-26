# Synthèse du kickoff & décisions

Ce document consolide les 6 livrables (`01` à `06`) et tranche leurs contradictions. **En cas de conflit, l'avis médical (`04`) prime.**

## Consensus des 6 experts

| Sujet | Décision |
|---|---|
| Architecture | **100 % local** (SwiftData chiffré sur l'iPhone), sans compte, sans backend, sans backoffice. 0 € d'infra. |
| Contenu | Recettes, séances, fiches = **JSON versionnés** dans le repo, embarqués dans un package Swift local, validés en CI. |
| Stack | Uniquement Apple, **aucune dépendance tierce**, aucun analytics : Swift 6 (strict, MainActor par défaut), SwiftUI + `@Observable`, SwiftData versionné, Swift Charts, notifications locales. |
| Cycle | **Aucune prédiction d'ovulation, de fenêtre fertile ni de phase.** Historique factuel (« jour 23 du cycle »), alertes de seuil (ex. pas de règles depuis plus de 90 jours → conseiller de consulter). La formule V0 `ovulation = durée − 14` est abandonnée. |
| Ton | Bienveillant, zéro culpabilisation. **Ni poids ni calories par défaut**, pas de série de jours consécutifs, jamais « en retard ». |
| Alimentation | Pas de « régime SOPK » miracle : IG bas / méditerranéen, assiette ½ légumes, ¼ protéines, ¼ féculents complets. Sans gluten / sans lactose = filtres de préférence, jamais présentés comme nécessaires. |
| Sport | 150–300 min/sem modérées + renforcement 2 j/sem. Séance proposée selon **l'énergie du jour**, pas selon la phase du cycle. |
| Réglementaire | Rester hors dispositif médical (MDR 2017/745) : pas de diagnostic, pas de fertilité, disclaimer validé à la 1re ouverture. Cible 18 ans et plus. |
| Données | Export JSON/CSV + suppression complète dès le MVP. Verrou Face ID en option. |

## Contradictions arbitrées

| Conflit | Arbitrage |
|---|---|
| iOS (`02`) prévoit des « prédictions avec niveau de confiance » sur l'écran Aujourd'hui et Cycle. Médecin (`04`) : rien par défaut. | **Avis médical retenu.** Estimation des prochaines règles **désactivée par défaut**. Elle n'est activable que si les 3 derniers cycles varient de 7 jours au plus, et s'affiche alors sous forme de fourchette avec une mention d'estimation. Jamais d'ovulation ni de phase. Tickets iOS 8, 14 et 15 à ajuster. |
| Suggestions repas/activité « selon la phase » (`02`) vs selon l'énergie déclarée (`04`, `06`). | **Selon le check-in du jour** (énergie, douleurs, règles, sommeil). |
| Nom du package : `SOPKKit` (`01`) vs `SOPKDomain` (`02`). | **`SOPKKit`** : il contient aussi le contenu JSON, pas seulement le domaine. |
| Dossier app : `App/` (`01`) vs `ios/` (`02`). | **`App/`**. Ça évite aussi le conflit de casse avec l'ancien `iOS/` sur macOS. |
| Recettes V0 (19) à réutiliser (`01`) vs à ne pas reprendre sans checklist (`04`). | Repartir des **12 nouvelles recettes** (`recettes-seed.json`). Les recettes V0 ne sont reprises qu'après relecture selon la checklist. |

## Architecture d'information (design `03`)

4 onglets : **Aujourd'hui · Cuisine · Bouger · Mon cycle**. Profil et réglages sont accessibles via l'avatar. Palette sauge / terracotta / crème, conforme WCAG AA.

## Décisions à prendre par le porteur

1. **iOS minimum** : 17 ou **18 (recommandé, SwiftData plus stable)**. Dépend de l'iPhone de l'utilisatrice principale.
2. **Nom de l'app** : Saison, Sauge, Ovéa, Équilibre, Myrtille (vérifier App Store + INPI).
3. **Périmètre** : SOPK seul (endométriose de la V0 retirée) ?
4. **Repo public ou privé** : la CI macOS est gratuite et illimitée en public, environ 200 min/mois en privé.
5. **Suivi du poids** : absent, ou en option masquée ?
6. **Sync CloudKit** : non au MVP (export/import + sauvegarde iCloud de l'appareil).

## Actions hors code

- Fermer les projets **Supabase, Vercel, Sentry** de la V0 et supprimer les secrets GitHub associés (une clé Supabase reste dans l'historique git).
- Prendre le compte **Apple Developer** (99 €/an) avant TestFlight.
- Trouver un·e **médecin** et un·e **diététicien·ne** pour relire le contenu avant toute ouverture à d'autres utilisatrices.
- Revérifier les références signalées « citées de mémoire » dans `04` et `06`.

## Prochaine étape : M0 (≈ 1 semaine)

1. `git tag v0-archive`, puis suppression de `iOS/`, `supabase/`, `backoffice/`, `supabase_migration.sql`, `package*.json`, des workflows de déploiement et des `.claude/commands` de la V0.
2. Réécriture de `CLAUDE.md` et `README.md` pour la V1.
3. Création du package `Packages/SOPKKit` (testable sous Linux) et de la CI : SwiftLint strict + `swift test` sur Ubuntu, `xcodebuild` sur macOS pour les PR.
4. Création du projet Xcode `App/SOPK.xcodeproj` **sur un Mac** (ticket iOS n°2).

Roadmap ensuite : M1 Fondations → M2 Journal & cycle → M3 Contenu → M4 Rappels & confidentialité → M5 Bêta TestFlight.
