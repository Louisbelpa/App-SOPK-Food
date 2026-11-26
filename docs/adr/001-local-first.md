# ADR-001 — Application 100 % locale, sans backend

- **Statut** : accepté (kickoff, 26/11/2026)
- **Contexte** : `docs/kickoff/01-architecture.md`, `04-medical.md`

## Décision
Les données de l'utilisatrice (journal, cycle, symptômes, repas, activités) sont stockées **uniquement sur l'iPhone**
avec SwiftData, dans un fichier protégé par iOS (`FileProtectionType.complete`). Il n'y a ni compte, ni serveur,
ni SDK tiers (analytics, crash reporting). Le contenu éditorial (recettes, séances, fiches) est en JSON versionné
dans `Packages/SOPKKit` et embarqué dans l'app.

## Raisons
- Données de santé = catégorie particulière (RGPD art. 9). Ne pas les collecter supprime l'essentiel du risque,
  l'obligation d'hébergeur HDS et le besoin d'une AIPD lourde.
- Coût d'infrastructure nul, rien à maintenir côté serveur pour un développeur solo.
- Le contenu change rarement : une PR suffit, et la CI valide le JSON.

## Conséquences
- Pas de synchronisation entre appareils au MVP : export/import JSON et sauvegarde iCloud de l'appareil.
- Le partage avec un soignant passe par un export (PDF/CSV, post-MVP).
- Toute fonctionnalité future qui enverrait des données hors de l'appareil (sync CloudKit, IA, communauté)
  nécessite un nouvel ADR, une analyse RGPD et, en cas d'hébergement tiers, un hébergeur certifié HDS.
