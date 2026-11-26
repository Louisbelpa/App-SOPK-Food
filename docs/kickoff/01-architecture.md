# 01 — Architecture technique (redémarrage V1)

> Rôle : architecte logiciel. Entrée : `00-brief.md`. Statut : **proposition à valider par le porteur** (voir §7).

---

## 0. Leçons tirées de la V0

| Constat V0 | Conséquence pour la V1 |
|---|---|
| 3 sous-systèmes (iOS + Supabase/Edge Functions + backoffice Next.js/Vercel/Sentry) pour un dev solo | Trop de surface à maintenir et sécuriser → **un seul produit : l'app iOS** |
| Données de cycle stockées en clair dans `UserDefaults` puis envoyées à Supabase (hébergement non HDS) | Données de santé **sur l'appareil uniquement**, fichier chiffré par iOS Data Protection |
| `CycleStore.phaseFor` suppose un cycle régulier (ovulation = longueur − 14) | Inadapté au SOPK (cycles longs/irréguliers, anovulation) → **pas de prédiction d'ovulation**, statistiques descriptives + fourchette prudente |
| Clé anon Supabase en dur dans `SupabaseClient.swift` et `project.pbxproj`, `.next/` versionné | Aucun secret nécessaire en V1 ; désactiver/supprimer le projet Supabase V0 |
| Client REST maison, Realtime, familles, rôles admin, RLS | Complexité sans valeur pour une première utilisatrice → supprimé |
| Arborescence `iOS/SOPK/SOPK/SOPK/` | Arborescence plate et lisible |
| Contenu (19 recettes) en base + backoffice | Contenu **JSON versionné dans le repo**, revu par PR |

---

## 1. Recommandation globale : **local-first, sans backend**

**Décision : 100 % local (SwiftData sur l'appareil), aucun serveur au MVP. Pas de backoffice. Contenu embarqué en JSON dans le bundle.**

Justification :

- **RGPD art. 9** : cycle, symptômes, poids, diagnostic SOPK = données de santé (catégorie particulière). Si elles ne quittent jamais l'appareil, le porteur **n'est pas responsable de traitement** pour ces données (pas de collecte) → pas d'AIPD lourde, pas de registre complexe, pas de DPO, pas de gestion de violation de données serveur.
- **HDS** (art. L1111-8 CSP) : tout hébergement de données de santé pour le compte de tiers en France impose un hébergeur certifié HDS (OVHcloud HDS, Scaleway HDS, AWS/Azure HDS…) → coût (≈ 50–300 €/mois minimum) et contraintes contractuelles incompatibles avec le budget. Supabase n'est pas HDS. **Pas de serveur = pas de sujet HDS.**
- **Coût** : 0 € d'infra. Seul coût : Apple Developer Program (99 €/an).
- **Simplicité** : pas d'auth, pas de comptes, pas de mot de passe oublié, pas de RLS, pas de déploiement backend, fonctionne hors-ligne. Pour un débutant iOS, SwiftData + `@Query` est le chemin le plus court.
- **Confiance utilisatrices** : argument marketing fort (« vos données ne quittent pas votre iPhone »), notamment post-Roe pour les apps de cycle.

**Synchronisation multi-appareils / sauvegarde** :
- MVP : sauvegarde iCloud/Finder standard de l'appareil (chiffrée par Apple) + **export/import manuel** (fichier JSON) choisi par l'utilisatrice.
- Plus tard (option) : SwiftData + CloudKit **base privée** de l'utilisatrice. Le dev n'a aucun accès aux données. ⚠️ Risque App Review guideline 5.1.3(ii) (« may not store personal health information in iCloud ») → décision ouverte D3. Le modèle de données est conçu **compatible CloudKit dès le départ** pour garder l'option ouverte sans migration douloureuse.

**Contenu (recettes, exercices, fiches)** : fichiers JSON versionnés dans le repo, embarqués dans le bundle, chargés en mémoire (lecture seule, pas dans SwiftData). Mise à jour = nouvelle version de l'app. Un backoffice ne se justifie qu'au-delà de ~200 contenus ou avec une rédactrice non-dev (D5). Étape intermédiaire possible plus tard : JSON publié sur un hébergement statique (GitHub Pages) et téléchargé par l'app — **aucune donnée personnelle envoyée**, donc toujours hors RGPD art. 9.

---

## 2. Stack

| Domaine | Choix | Notes |
|---|---|---|
| Outils | **Xcode 26.x**, Swift 6.2 | Dossiers synchronisés (Xcode 16+) → quasi plus de conflits `project.pbxproj` ; pas besoin de XcodeGen/Tuist |
| Langage | Swift 6 language mode, **default actor isolation = MainActor** (Swift 6.2) | Concurrence stricte mais abordable pour un débutant |
| Cible | **iOS 17.0 minimum** (voir D1 : iOS 18 recommandé si la cible le permet) | |
| UI | SwiftUI, `@Observable` (Observation), `NavigationStack`, Swift Charts | Pas de `ObservableObject`/Combine |
| Persistance | **SwiftData** avec `VersionedSchema` + `SchemaMigrationPlan` dès la v1 | Store chiffré via Data Protection (§5) |
| Contenu | JSON + `Codable`, package local `SOPKKit` (`Bundle.module`) | Validé par tests en CI |
| Notifications | `UserNotifications` **locales uniquement** (pas d'APNs) | Textes neutres sur l'écran verrouillé |
| Verrou app | `LocalAuthentication` (Face ID / code), optionnel | |
| Widget | **WidgetKit** (M4), opt-in, données minimales via App Group | |
| HealthKit | **Post-MVP, optionnel** : lecture/écriture flux menstruel (`menstrualFlow`), poids, pas/entraînements | Revue App Store plus stricte ; à faire une fois le cœur stable |
| Tests | **Swift Testing** (`import Testing`) pour la logique ; XCTest UI pour 2-3 parcours critiques | |
| Lint | SwiftLint (installé en CI via Homebrew, pas en dépendance SPM) | |
| Crash/qualité | Rapports Xcode Organizer / MetricKit (consentement géré par Apple) | **Pas de Sentry, Firebase, analytics tiers** |
| Localisation | String Catalog (`Localizable.xcstrings`), FR d'abord | EN prêt sans refacto |

**Dépendances tierces : zéro au MVP.** Toute ajout doit passer par une ADR (`docs/adr/`).

Architecture applicative : **SwiftUI « vanilla »** — vues + `@Query` pour la lecture, petits services `@Observable` pour la logique, logique métier pure (calculs de cycle, insights, filtres de contenu) dans le package `SOPKKit` sans dépendance à SwiftUI/SwiftData → testable rapidement, y compris sur Linux. Pas de Repository/DI généralisés (sur-ingénierie V0).

---

## 3. Modèle de données

### 3.1 Données utilisatrice (SwiftData, `SchemaV1`)

Règles de compatibilité CloudKit appliquées dès maintenant : tous les attributs ont une valeur par défaut ou sont optionnels, relations optionnelles avec règle de suppression explicite, **pas de `@Attribute(.unique)`** (unicité gérée en code), enums stockés en `String` (rawValue).

| Entité | Champs principaux | Remarques |
|---|---|---|
| `UserProfile` (singleton) | `firstName?`, `birthYear?`, `diagnosisStatus` (confirmé / suspecté / non précisé), `goals: [String]` (cycle, poids, énergie, peau, fertilité…), `dietaryExclusions: [String]` (gluten, lactose, végétarien…), `activityLevel`, `onboardingCompletedAt?`, `createdAt` | Minimisation : pas de nom complet, pas d'email |
| `DayLog` | `date` (jour normalisé, 1 par jour), `flow` (aucun / spotting / léger / moyen / abondant), `mood?` (1-5), `energy?` (1-5), `sleepQuality?` (1-5), `stress?` (1-5), `weightKg?` (opt-in), `note?`, relations `symptoms`, `meals`, `activities` | Pivot du journal quotidien |
| `SymptomEntry` | `kind` (acné, pilosité, chute de cheveux, ballonnements, fatigue, fringales, douleurs pelviennes, migraine, irritabilité…), `intensity` (1-3), `dayLog` | Liste de `kind` définie dans `SOPKKit` (extensible sans migration) |
| `MealLog` | `date`, `mealType` (petit-déj, déjeuner, dîner, collation), `recipeID?` (réf. contenu), `freeText?`, `satiety?` (1-5), `cravings: Bool`, `dayLog?` | Référence au contenu par **ID stable texte** |
| `ActivityLog` | `date`, `kind` (marche, renfo, yoga, cardio doux…), `exerciseID?`, `durationMin`, `perceivedEffort?` (1-5), `dayLog?` | |
| `Favorite` | `contentID`, `contentType` (recette / exercice / fiche), `addedAt` | |
| `MealPlanEntry` *(M5)* | `date`, `mealType`, `recipeID` | Planning hebdo |
| `ShoppingItem` *(M5)* | `name`, `quantity?`, `unit?`, `category`, `isChecked`, `sourceRecipeID?` | |
| `ReminderSetting` | `kind` (journal du soir, hydratation, activité), `hour`, `minute`, `isEnabled` | Planifie des notifications locales |

**Cycles = données dérivées, non stockées** : `SOPKKit.CycleEngine` reconstruit les cycles à partir des `DayLog.flow` (début de cycle = premier jour de flux ≥ léger après ≥ N jours sans flux). Il calcule : longueur médiane, min/max, variabilité, jour du cycle courant, et une **fourchette** de prochaines règles uniquement si ≥ 3 cycles et variabilité faible ; sinon « cycle irrégulier, pas de prévision fiable ». **Aucune prédiction d'ovulation/fertilité** (non-dispositif médical, et non fiable dans le SOPK).

### 3.2 Contenu (JSON embarqué, `SOPKKit/Resources/Content/`)

- `recipes.json` : `id` (slug stable), `title`, `summary`, `mealType`, `prepMinutes`, `servings`, `ingredients[{name, quantity, unit, category}]`, `steps[]`, `tags` (ig-bas, anti-inflammatoire, riche-en-fibres, protéiné…), `allergens[]`, `diet[]`, `imageName`.
- `exercises.json` : `id`, `title`, `kind`, `durationMin`, `level`, `steps[]`, `contraindications?`.
- `articles.json` (fiches) : `id`, `title`, `body` (Markdown), `sources[{title, url}]`, `reviewedAt`.
- `manifest.json` : `schemaVersion`, `contentVersion`.

Images dans `Assets.xcassets` (WebP/HEIC compressé). Les tests vérifient : décodage, unicité des IDs, références valides, présence de sources sur les fiches.

---

## 4. Structure du nouveau repo

```
App-SOPK-Food/
├── App/
│   ├── SOPK.xcodeproj
│   ├── SOPK/                      # cible app (dossiers synchronisés)
│   │   ├── App/                   # SOPKApp, RootView, AppLock
│   │   ├── Features/
│   │   │   ├── Onboarding/        # disclaimer médical + consentement + profil
│   │   │   ├── Today/             # écran du jour : saisie rapide, conseil
│   │   │   ├── Journal/           # DayLog, symptômes, humeur
│   │   │   ├── Cycle/             # calendrier, stats, graphiques
│   │   │   ├── Food/              # recettes, filtres, favoris (+ planning M5)
│   │   │   ├── Activity/          # exercices, log d'activité
│   │   │   ├── Library/           # fiches info
│   │   │   └── Settings/          # rappels, verrou, export/suppression
│   │   ├── Persistence/           # SchemaV1, modèles @Model, MigrationPlan, ModelContainer
│   │   ├── Services/              # Notifications, Export/Import, (HealthKit plus tard)
│   │   ├── DesignSystem/          # couleurs, typo, composants
│   │   └── Resources/             # Assets, Localizable.xcstrings, PrivacyInfo.xcprivacy
│   ├── SOPKWidget/                # (M4)
│   ├── SOPKTests/                 # tests app (SwiftData en mémoire)
│   └── SOPKUITests/
├── Packages/
│   └── SOPKKit/                   # logique pure : CycleEngine, Insights, modèles de contenu
│       ├── Package.swift
│       ├── Sources/SOPKKit/{Cycle,Content,Insights}/
│       ├── Sources/SOPKKit/Resources/Content/*.json
│       └── Tests/SOPKKitTests/
├── docs/{kickoff,adr,privacy}/    # ADR, politique de confidentialité, mentions
├── .github/workflows/ci.yml
├── .swiftlint.yml
├── .gitignore                     # xcuserdata, DerivedData, *.xcconfig locaux, .build
├── CLAUDE.md                      # réécrit pour la V1
└── README.md
```

**À supprimer de la V0** (après `git tag v0-archive` pour garder l'historique) : `iOS/`, `supabase/`, `backoffice/` (dont `.next/` versionné), `supabase_migration.sql`, `package.json` + `package-lock.json` racine, `.github/workflows/deploy-*.yml`, `.github/workflows/ci.yml` (réécrit), `.claude/commands/*` (ajouter-recette, deployer, nouvelle-migration, nouvelle-feature-ios → à réécrire pour la V1), `privacy-policy.html` (réécrite dans `docs/privacy/`). **Hors repo** : supprimer le projet Supabase V0 (la clé anon est dans l'historique git), le projet Vercel et Sentry, et les secrets GitHub associés.

À **réutiliser** comme matière : les 19 recettes de `supabase/seed.sql` (à convertir en JSON et relire), la palette de `DesignSystem.swift`, le texte du disclaimer.

---

## 5. Conformité & sécurité

- **RGPD art. 9** : aucune donnée de santé collectée par le porteur au MVP → base légale non requise côté serveur. Rester rigoureux quand même : écran d'information à l'onboarding (ce qui est stocké, où, comment supprimer), politique de confidentialité publique (exigée par l'App Store), mentions « pas un dispositif médical ».
- **HDS** : non applicable tant qu'aucun serveur ne stocke de données de santé. **Tout futur serveur (sync propriétaire, compte, IA distante) ⇒ hébergeur HDS + AIPD + consentement explicite.** À acter dans une ADR.
- **Stockage chiffré** : fichier SwiftData placé avec `FileProtectionType.complete` (illisible appareil verrouillé). Les notifications sont planifiées à l'avance et ne lisent pas la base en arrière-plan. Le widget (M4) lit un **snapshot minimal** écrit dans l'App Group, opt-in, sans libellé médical explicite. Option verrou Face ID + flou de l'écran dans le sélecteur d'apps.
- **Pas de tracking tiers** : aucun SDK analytics/pub/crash. `PrivacyInfo.xcprivacy` déclaré (APIs `UserDefaults`, date fichier). App Privacy « Data Not Collected » sur l'App Store. Aucun appel réseau au MVP (vérifiable : un test/lint interdit `URLSession` hors module autorisé).
- **Notifications** : textes neutres (« Petit moment pour toi » plutôt que « Tes règles arrivent »), car visibles sur l'écran verrouillé.
- **Droits des utilisatrices** : Réglages → *Exporter mes données* (JSON lisible + CSV, via `ShareLink`/`fileExporter`), *Importer* (restauration / changement d'iPhone), *Tout supprimer* (efface le store SwiftData + App Group + préférences + notifications planifiées, double confirmation).
- **Non-dispositif médical** (règlement UE 2017/745) : pas de diagnostic, pas de prédiction de fertilité, pas de recommandation posologique ; formulations « peut aider », fiches sourcées et datées ; incitation à consulter. Disclaimer à l'onboarding et accessible dans Réglages.
- **Mineures** : âge minimum 15 ans (consentement numérique en France) ou 18 ans → D6.

---

## 6. Roadmap technique MVP

| Jalon | Contenu | Critère de sortie |
|---|---|---|
| **M0 — Setup** (≈ 1 sem.) | Tag `v0-archive`, nettoyage, projet Xcode + package `SOPKKit`, SwiftLint, CI, `CLAUDE.md` V1, ADR-001 (local-first), décommission Supabase/Vercel | CI verte sur une app « Hello » + 1 test |
| **M1 — Fondations** | `SchemaV1` + MigrationPlan, Data Protection, DesignSystem, onboarding (disclaimer, info vie privée, profil), TabView squelette | Profil persisté, test de persistance en mémoire |
| **M2 — Journal & cycle** | Écran Aujourd'hui, `DayLog` + symptômes, calendrier, `CycleEngine` (cycles irréguliers), graphiques Swift Charts | Tests `CycleEngine` couvrant cycles 21–90 j, absence de règles, saisies rétroactives |
| **M3 — Contenu** | Recettes / exercices / fiches en JSON, filtres (repas, tags, exclusions du profil), favoris, `MealLog` / `ActivityLog` | Tests de validation du contenu en CI ; ≥ 20 recettes relues |
| **M4 — Rappels & confidentialité** | Notifications locales, export/import/suppression, verrou Face ID, widget opt-in | Parcours export → suppression → import testé (UI test) |
| **M5 — Beta** | Planning repas + liste de courses (optionnel), accessibilité (Dynamic Type, VoiceOver), politique de confidentialité, TestFlight avec l'utilisatrice principale | Utilisée 2 semaines sans perte de données |
| *Post-MVP* | HealthKit, sync CloudKit (si D3 validé), insights corrélations symptômes/alimentation, EN | — |

**CI (`.github/workflows/ci.yml`)**, sur push et PR :
1. `lint` (ubuntu, rapide) : SwiftLint en `--strict` (image Docker `ghcr.io/realm/swiftlint`).
2. `kit-tests` (ubuntu) : `swift test --package-path Packages/SOPKKit` (logique + validation contenu, coût quasi nul).
3. `app-build-test` (macos-15 / Xcode 26) : `xcodebuild test -scheme SOPK -destination 'platform=iOS Simulator,name=iPhone 16'`, cache DerivedData/SPM, `concurrency` qui annule les runs obsolètes.

Budget : les minutes macOS comptent ×10 sur un repo privé (2 000 min gratuites ≈ 200 min macOS/mois) → déclencher le job macOS uniquement sur PR et sur `main`, ou rendre le repo public (minutes illimitées). Distribution TestFlight manuelle depuis Xcode au début (Xcode Cloud, 25 h/mois incluses, possible plus tard).

---

## 7. Risques & décisions ouvertes (à valider par le porteur)

**Décisions à trancher**

- **D1 — iOS minimum** : 17 (brief) vs **18 (recommandé)** — SwiftData nettement plus stable en 18 (`#Index`, historique, moins de bugs). Quelle version a l'iPhone de l'utilisatrice principale ?
- **D2 — Valider le 100 % local sans compte** : implique pas de partage avec un proche ni avec un soignant autrement que par export (PDF/CSV à prévoir post-MVP).
- **D3 — Sync CloudKit** : utile en cas de changement d'iPhone, mais risque App Review 5.1.3(ii). Proposition : non au MVP, export/import + sauvegarde iCloud de l'appareil suffisent.
- **D4 — Nom et périmètre** : SOPK seul (brief) ; l'endométriose de la V0 est retirée du MVP ?
- **D5 — Backoffice** : non tant que le contenu est rédigé par le porteur via PR ; à réévaluer si une diététicienne contribue.
- **D6 — Âge minimum** et **données de poids** : le poids est utile mais sensible (troubles alimentaires) → opt-in masqué par défaut ?
- **D7 — Repo public ou privé** (coût CI, mais aussi exposition du contenu).

**Risques**

| Risque | Impact | Mitigation |
|---|---|---|
| Perte de données (pas de serveur) | Élevé | Sauvegarde iCloud de l'appareil, export manuel, rappel d'export ; migrations SwiftData testées |
| Bugs/limitations SwiftData (iOS 17) | Moyen | Logique métier hors SwiftData (`SOPKKit`), modèles simples, D1 |
| Qualité/exactitude du contenu santé | Élevé (réputation, juridique) | Fiches sourcées, relecture par une diététicienne/sage-femme si possible, wording non médical |
| Requalification en dispositif médical | Élevé | Aucune prédiction de fertilité, aucun diagnostic, disclaimer |
| Courbe d'apprentissage iOS du porteur | Moyen | Stack Apple standard, zéro dépendance, architecture simple, jalons courts |
| Ouverture future à d'autres utilisatrices nécessitant un serveur (IA, communauté) | Moyen | ADR dédiée ; HDS + AIPD obligatoires à ce moment-là |
