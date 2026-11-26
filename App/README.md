# App iOS Ovéa

Le projet Xcode n'existe pas encore : il doit être créé **sur un Mac** (ticket iOS n°2 de `docs/kickoff/02-ios.md`).

1. Xcode 26 → *File › New › Project* → iOS App, nom `SOPK`, interface SwiftUI, stockage *None*,
   tests *Swift Testing*. Emplacement : ce dossier `App/` (le projet doit finir en `App/SOPK.xcodeproj`).
2. Réglages de la cible : *Minimum Deployments* iOS 18.0, *Swift Language Version* 6,
   *Default Actor Isolation* `MainActor`, nom affiché « Ovéa ».
3. *File › Add Package Dependencies › Add Local…* → `Packages/SOPKKit`, puis lier `SOPKKit` à la cible.
4. *Signing & Capabilities* : ajouter *Data Protection* → *Complete Protection*.
5. Partager le schéma `SOPK` (*Manage Schemes › Shared*) pour que la CI puisse l'utiliser.

Dès que `App/SOPK.xcodeproj` existe, le job macOS de la CI le compile et lance ses tests sur les PR et sur `main`.
