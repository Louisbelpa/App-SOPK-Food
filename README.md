# Ovéa

App iOS pour aider les femmes atteintes du **SOPK** (syndrome des ovaires polykystiques) au quotidien :
recettes anti-inflammatoires à index glycémique bas, séances d'activité adaptées à l'énergie du jour,
journal des symptômes et du cycle.

Ovéa informe et accompagne : elle ne pose pas de diagnostic, ne prédit ni l'ovulation ni la fertilité,
et ne remplace pas une consultation médicale.

## Principes

- **100 % local** : les données restent sur l'iPhone. Pas de compte, pas de serveur, pas de tracking.
- **Bienveillante** : ni poids ni calories par défaut, aucune culpabilisation.
- **Sourcée** : contenu aligné sur la recommandation internationale PCOS 2023, à faire relire par des professionnels de santé.

## État

Phase M0 (mise en place). Voir `docs/kickoff/07-synthese-decisions.md` pour les décisions et la roadmap.

| Dossier | Contenu |
|---|---|
| `App/` | App iOS SwiftUI (iOS 18+), à créer dans Xcode : voir `App/README.md` |
| `Packages/SOPKKit/` | Logique métier (cycle) et contenu (12 recettes, 8 séances), testés sous Linux |
| `docs/kickoff/` | Livrables des experts : architecture, iOS, design, médical, cuisine, sport |
| `docs/adr/` | Décisions d'architecture |

```bash
swift test --package-path Packages/SOPKKit
```
