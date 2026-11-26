# 02 — Plan technique iOS (Lead dev)

> Cible : iOS 17+, SwiftUI, Swift 6, local-first (SwiftData, aucune donnée de santé sur un serveur pour le MVP).
> Lecteur : dev web à l'aise, intermédiaire en iOS. Chaque concept clé a une analogie web en §7.

---

## 0. Leçons tirées de la V0 (`iOS/`)

| Constat V0 | Décision V2 |
|---|---|
| `ObservableObject` + 6 `.environmentObject(...)` en cascade, `import Combine` partout | `@Observable` + `.environment(_:)`, pas de Combine |
| Données de santé (cycle) dans `UserDefaults` (non chiffré, sauvegardé en clair dans les backups non chiffrés) | SwiftData avec Data Protection `Complete` ; `UserDefaults`/`@AppStorage` réservé aux préférences non sensibles |
| Phases du cycle typées `String` (`"Menstruelle"`) et logique mélangée à la persistance | `enum CyclePhase` dans un package domaine pur, testé à part |
| Calcul de phase basé sur une durée de cycle fixe (`jour % cycleLength`) | **SOPK = cycles souvent irréguliers** : prédiction calculée sur l'historique réel, avec un niveau de confiance affiché ; jamais d'ovulation présentée comme un fait |
| `save()` local puis `Task { await persistRemote() }` sans gestion d'erreur | Local-first : une seule source de vérité (SwiftData). Sync éventuelle plus tard (CloudKit) |
| Vues de 400-500 lignes, préfixe `Nourri*` incohérent | Vues < 200 lignes, sous-composants dans `Components/`, nommage par feature |
| Chaînes FR en dur (`Text("...")`), pas de String Catalog | `Localizable.xcstrings`, FR langue de développement dès J1 |
| CI : `swiftlint ... \|\| true` (jamais bloquant), aucun test iOS lancé en CI | Lint `--strict` bloquant + `xcodebuild test` + tests domaine sur Linux |
| Arborescence `iOS/SOPK/SOPK/SOPK/` (triple imbrication) | `ios/` plat, un seul niveau |

**Avant de commencer** : taguer la V0 (`git tag v0-final`), puis supprimer `iOS/`, `backoffice/`, `supabase/` dans une PR dédiée. Attention : macOS a un système de fichiers **insensible à la casse** — `iOS/` et `ios/` ne peuvent pas coexister. Supprimer l'ancien dossier d'abord.

---

## 1. Conventions de code

### 1.1 État : Observation framework (`@Observable`)

```swift
import Observation

@Observable
final class TodayModel {
    var selectedDay: LocalDate = .today
    private(set) var isSaving = false
    @ObservationIgnored private let store: DayLogStore   // pas observé

    init(store: DayLogStore) { self.store = store }

    func logFlow(_ level: FlowLevel) async { ... }
}
```

Règles :
- **Qui possède l'objet le déclare en `@State`** : `@State private var model = TodayModel(store: ...)`. Ceux qui le reçoivent le déclarent en `let`, ou en `@Bindable var` s'ils ont besoin de bindings (`$model.selectedDay`).
- Partagé dans toute l'app → `.environment(objet)` à la racine, puis `@Environment(DayLogStore.self) private var store`.
- Valeurs locales à une vue (toggle, texte d'un champ) → `@State private var`.
- Préférences non sensibles (onboarding vu, thème) → `@AppStorage`.
- Jamais `ObservableObject`, `@Published`, `@StateObject`, `@EnvironmentObject` dans le nouveau code.
- **Pas de ViewModel par défaut.** Un écran qui affiche une `@Query` et appelle 2 méthodes d'un store n'en a pas besoin. On crée un `XxxModel` `@Observable` quand l'écran a de la logique (calculs, états de chargement, validation).

### 1.2 Persistance : SwiftData

- Modèles `@Model` dans `Data/Models/`, déclarés dans un `VersionedSchema` (`SchemaV1`) **dès le premier jour** + un `SchemaMigrationPlan`. Migrer plus tard sans ça est pénible.
- **Concevoir compatible CloudKit dès maintenant** (sync iCloud possible en V2 sans backend) : toutes les propriétés optionnelles ou avec valeur par défaut, pas de `@Attribute(.unique)`, relations optionnelles. L'unicité (« un seul `DayLog` par jour ») est garantie par le code (`fetchOrCreate(day:)`).
- Enums stockés en `String` brut + propriété calculée typée (les `#Predicate` sur enums Codable sont fragiles) :
  ```swift
  @Model final class DayLog {
      var dayKey: String = ""          // "2026-11-26", clé de jour locale
      var flowRaw: String?             // FlowLevel.rawValue
      var symptomCodes: [String] = []
      var flow: FlowLevel? { flowRaw.flatMap(FlowLevel.init(rawValue:)) }
  }
  ```
- **Dates** : un jour de cycle n'est pas un instant. On manipule un type `LocalDate` (année/mois/jour) dans le domaine ; on ne stocke jamais un `Date` à minuit (bugs de fuseau horaire en voyage).
- Lecture dans les vues : `@Query(filter:sort:)`. Écriture : via des stores `@MainActor` (`DayLogStore`, `ActivityStore`) qui encapsulent le `ModelContext`.
- Traitements lourds (export) : `@ModelActor` ; on fait transiter des **DTO `Sendable`** (structs), jamais des objets `@Model` entre acteurs.
- Contenu éditorial (recettes, séances d'activité, fiches conseils) : **JSON embarqué dans le bundle**, décodé en `struct Codable, Sendable`. Ce n'est pas de la donnée utilisateur → pas dans SwiftData.

### 1.3 Concurrence : async/await et Swift 6 strict — **OUI**

Décision : **Swift 6 language mode (strict concurrency complète) dès le départ**, avec l'isolation par défaut sur `MainActor` pour la cible app.

Argumentaire :
- Projet neuf, sans dette : le coût de Swift 6 vient surtout de la migration de vieux code ; ici on n'a rien à migrer.
- L'app fait très peu de concurrence (DB locale, un export, des notifications). Avec `Default Actor Isolation = MainActor` (Xcode 26, réglage par défaut des nouveaux projets) et `Approachable Concurrency = YES`, presque tout le code est implicitement sur le main thread → quasiment aucune annotation à écrire.
- Le compilateur détecte les data races à la compilation au lieu de crashs aléatoires en prod. Pour un dev seul, c'est un filet de sécurité gratuit.
- Les erreurs Swift 6 sont devenues lisibles et les APIs Apple (SwiftData, UserNotifications) sont annotées.

Règles :
- Cible app : `SWIFT_VERSION = 6`, `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, `SWIFT_APPROACHABLE_CONCURRENCY = YES`.
- Package domaine : Swift 6, **pas** d'isolation par défaut ; uniquement des `struct`/`enum` `Sendable` et des fonctions pures.
- Travail lourd hors main thread : fonction `@concurrent` ou `@ModelActor`. Pas de `DispatchQueue`, pas de `Task.detached` sauf justification.
- Lancer de l'async depuis une vue : `.task { }` / `.task(id:)` (annulé automatiquement quand la vue disparaît). `Task { }` uniquement dans les actions de bouton.
- Interdit sans commentaire justificatif : `@unchecked Sendable`, `nonisolated(unsafe)`, `@preconcurrency`.
- Plan B si un blocage dure plus d'une heure : passer **ce fichier** en `@MainActor` explicite, pas tout le projet en Swift 5.

### 1.4 Navigation : `TabView` + `NavigationStack` + routes typées

- 5 onglets : Aujourd'hui, Cycle, Alimentation, Activité, Profil. Chaque onglet a **sa propre** `NavigationStack` et son propre chemin.
- Routes = `enum` `Hashable` par onglet ; un `Router` `@Observable` détient les chemins (testable, permet les deep links depuis une notification).

```swift
enum NutritionRoute: Hashable { case recipe(id: Recipe.ID), category(MealType) }

@Observable final class Router {
    var tab: AppTab = .today
    var nutritionPath: [NutritionRoute] = []
    var sheet: AppSheet?                       // modales : enum Identifiable

    func open(_ deepLink: DeepLink) { ... }    // ex. notif "log du jour" → tab .today + sheet .dayLog
}

NavigationStack(path: $router.nutritionPath) {
    RecipeListView()
        .navigationDestination(for: NutritionRoute.self) { route in
            switch route {
            case .recipe(let id): RecipeDetailView(recipeID: id)
            case .category(let type): RecipeListView(mealType: type)
            }
        }
}
```
- Les routes portent des **identifiants**, pas des objets `@Model`.
- Modales : `.sheet(item: $router.sheet)` avec un `enum AppSheet: Identifiable`. Pas de 5 booléens `isShowingX`.
- `NavigationLink(value:)` uniquement (pas l'ancien `NavigationLink(destination:)`).

### 1.5 DI légère : `Environment`, sans framework

- Un `AppDependencies` assemblé **une seule fois** dans `SOPKApp`, injecté par `.environment(...)` et `.modelContainer(...)`.
- Protocoles uniquement pour ce qui a vraiment besoin d'un double en test/preview : `NotificationScheduling`, `BiometricAuthenticating`, horloge (`now: () -> Date`). Pas de protocole « au cas où » sur les stores SwiftData : en test, on utilise un `ModelContainer` **en mémoire**.
- Valeurs simples injectables avec la macro `@Entry` :
  ```swift
  extension EnvironmentValues { @Entry var now: () -> Date = Date.init }
  ```
- Pas de singleton `.shared` dans le code applicatif (hors APIs Apple).

### 1.6 Style

- Une vue = un fichier ; < 200 lignes ; sous-vues privées ou dans `Components/`.
- `// MARK: -` pour structurer ; `private` par défaut.
- Erreurs : `throws` typés par domaine (`enum ExportError: LocalizedError`) ; l'UI affiche via `.alert(item:)`. Jamais de `try!` hors tests, jamais de `print` (utiliser `Logger` d'`os`, et **jamais de donnée de santé dans les logs**).
- Couleurs et espacements uniquement via le design system (`Color.brandPrimary`, `Spacing.m`), polices uniquement via les styles système (`.font(.headline)`).

---

## 2. Architecture et projet

### 2.1 Choix de l'outil projet

| Option | Verdict |
|---|---|
| **Projet Xcode classique + dossiers synchronisés (Xcode 16+) + 1 Swift Package local** | **Retenu.** Zéro outil en plus ; les « buildable folders » font que le `.pbxproj` ne bouge presque plus quand on ajoute des fichiers (fini les conflits de merge) |
| XcodeGen | Bonne option si les conflits `.pbxproj` reviennent. Ajoute un `project.yml` et une étape `xcodegen generate`. À garder en réserve |
| Tuist | Trop lourd pour un projet solo (cache, manifestes en Swift, outil à maintenir) |
| Tout en packages SPM modulaires (1 package par feature) | Prématuré : surcoût de `public`, compilation, previews plus lentes |

Le **package local `SOPKDomain`** (Foundation uniquement, aucun import SwiftUI/SwiftData) contient la logique métier critique : calculs de cycle, prédictions, règles de suggestion. Intérêt principal : il se teste avec `swift test` **sur un runner Linux** (rapide, et 10 fois moins cher en minutes GitHub qu'un runner macOS), et même sans Mac.

> Un Mac reste indispensable pour développer l'app elle-même (Xcode, simulateur, signature). La CI macOS sert à valider, pas à remplacer le poste de dev.

### 2.2 Arborescence

```
ios/
├── SOPK.xcodeproj
├── SOPK.xctestplan
├── .swiftlint.yml
├── Config/
│   ├── Shared.xcconfig          # bundle id de base, version, réglages Swift 6
│   ├── Debug.xcconfig           # suffixe .debug, nom "SOPK β"
│   └── Release.xcconfig
├── SOPK/                        # cible app (dossier synchronisé)
│   ├── App/
│   │   ├── SOPKApp.swift        # @main, ModelContainer, AppDependencies
│   │   ├── RootView.swift       # onboarding vs TabView, verrou
│   │   ├── AppTab.swift
│   │   ├── Router.swift         # routes, sheets, deep links
│   │   └── AppDependencies.swift
│   ├── Features/
│   │   ├── Onboarding/
│   │   ├── Today/
│   │   ├── Cycle/               # CycleView, DayLogSheet, Components/CalendarMonthView…
│   │   ├── Nutrition/
│   │   ├── Activity/
│   │   └── Profile/             # réglages, export, suppression, à propos
│   ├── Data/
│   │   ├── Models/              # @Model : DayLog, ActivityLog, FavoriteRecipe, UserSettings
│   │   ├── Schema/              # SchemaV1, MigrationPlan
│   │   ├── Stores/              # DayLogStore, ActivityStore… (@MainActor, ModelContext)
│   │   ├── Content/             # ContentRepository : décode recipes.json, activities.json
│   │   └── Export/              # ExportService (@ModelActor), DTO Codable
│   ├── Services/                # NotificationScheduler, BiometricLock
│   ├── DesignSystem/            # Colors, Spacing, Typography, Card, Chip, EmptyState…
│   ├── Preview/                 # PreviewData, .previewContainer()
│   └── Resources/
│       ├── Assets.xcassets      # couleurs (Any/Dark), icônes
│       ├── Localizable.xcstrings
│       ├── recipes.json, activities.json, tips.json
│       └── PrivacyInfo.xcprivacy
├── SOPKTests/                   # Swift Testing : stores, export, router
├── SOPKUITests/                 # XCTest UI : smoke + audit accessibilité
└── Packages/
    └── SOPKDomain/
        ├── Package.swift
        ├── Sources/SOPKDomain/  # LocalDate, CyclePhase, CycleCalculator, Symptom, FlowLevel…
        └── Tests/SOPKDomainTests/
```

`Package.swift` :
```swift
// swift-tools-version: 6.0
import PackageDescription
let package = Package(
    name: "SOPKDomain",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [.library(name: "SOPKDomain", targets: ["SOPKDomain"])],
    targets: [
        .target(name: "SOPKDomain"),
        .testTarget(name: "SOPKDomainTests", dependencies: ["SOPKDomain"]),
    ]
)
```

---

## 3. Écrans du MVP

Principe transverse : chaque écran qui affiche une info santé porte la mention « information, pas avis médical » de façon discrète (lien vers une fiche « À propos / limites »), et aucune prédiction n'est affichée sans son niveau de confiance.

### 3.1 Onboarding (4-5 pages, une seule fois)
- **Responsabilités** : présenter l'app ; faire accepter l'avertissement non-médical (case explicite) ; expliquer la confidentialité (« vos données restent sur votre iPhone ») ; saisie optionnelle : date des dernières règles, durée habituelle ou « irrégulière / je ne sais pas » ; objectifs (alimentation, activité, symptômes) ; demande de permission notifications **à la fin**, avec explication préalable.
- **Composants** : `OnboardingFlow` (TabView `.page` ou pile de pages avec état local), `DisclaimerPage`, `PrivacyPage`, `CycleSetupPage` (`DatePicker`, `Stepper`, toggle « irrégulier »), `GoalsPage` (chips multi-sélection), `NotificationPermissionPage`.
- **Sortie** : crée `UserSettings` + éventuel premier `DayLog`, `@AppStorage("onboardingDone") = true`.

### 3.2 Aujourd'hui (dashboard)
- **Responsabilités** : répondre en 3 secondes à « où j'en suis et que puis-je faire aujourd'hui ? ». Jour du cycle et phase estimée (avec confiance : « estimation fiable / peu fiable, cycles irréguliers ») ; saisie rapide du jour ; suggestion de repas et d'activité adaptées (phase, énergie déclarée) ; conseil du jour.
- **Composants** : `CycleStatusCard`, `QuickLogRow` (boutons règles / symptômes / humeur / énergie → ouvre `DayLogSheet`), `SuggestedRecipeCard`, `SuggestedActivityCard`, `TipCard`, `EmptyState` si aucune donnée.
- **Logique** : `TodayModel` (@Observable) qui combine les `DayLog` et le `CycleCalculator` du domaine.

### 3.3 Cycle & symptômes
- **Responsabilités** : calendrier mensuel (jours de règles saisis, jours estimés en pointillé, jours avec symptômes) ; saisie/édition d'un jour (flux, symptômes SOPK : acné, pilosité, fatigue, ballonnements, fringales, douleurs, humeur, sommeil ; note libre) ; historique des cycles (durées, moyenne, variabilité).
- **Composants** : `CalendarMonthView` (grille `LazyVGrid`, navigation mois précédent/suivant), `DayCell`, `DayLogSheet` (formulaire : `FlowPicker`, `SymptomGrid` de chips, `MoodPicker`, `EnergySlider`, `TextField` note), `CycleHistoryList`, `CycleStatsCard`.
- **Domaine** : `CycleCalculator` (débuts de cycle déduits des jours avec flux, durée moyenne, écart-type, prochaine fenêtre estimée, confiance).

### 3.4 Alimentation / recettes
- **Responsabilités** : catalogue de recettes anti-inflammatoires / IG bas embarqué ; filtres (type de repas, temps, tags « IG bas », « riche en fibres », allergènes à éviter) ; recherche ; détail recette (ingrédients avec ajustement des portions, étapes, pourquoi c'est adapté) ; favoris.
- **Composants** : `RecipeListView` (`.searchable`, filtres en `Menu`/chips), `RecipeRow`/`RecipeCard`, `RecipeDetailView`, `ServingsStepper`, `IngredientList`, `StepList`, `FavoriteButton`, `RecipeFilterSheet`.
- **Données** : `ContentRepository` (JSON du bundle) + `FavoriteRecipe` (@Model, stocke uniquement l'id).
- Hors MVP : planning de repas, liste de courses.

### 3.5 Activité
- **Responsabilités** : bibliothèque de séances adaptées (marche, renforcement, yoga, mobilité, cardio doux) avec durée/intensité ; suggestion selon énergie déclarée ; journal des activités (type, durée, ressenti) ; total hebdo simple.
- **Composants** : `ActivityLibraryView`, `ActivityCard`, `ActivityDetailView` (étapes, conseils), `LogActivitySheet`, `WeeklySummaryCard` (Swift Charts `BarMark`, avec description VoiceOver).
- Hors MVP : HealthKit (lecture pas/entraînements), minuteur guidé.

### 3.6 Profil / réglages / export
- **Responsabilités** : modifier les infos de cycle et objectifs ; rappels (heure du rappel de saisie quotidienne) ; verrou Face ID/code ; **export des données** (JSON complet + CSV des journaux) via la feuille de partage ; **suppression totale** des données (double confirmation) ; à propos, limites médicales, politique de confidentialité, contact.
- **Composants** : `ProfileView` (`Form` avec sections), `CycleSettingsView`, `RemindersSettingsView`, `PrivacySettingsView`, `ExportView` (`ShareLink` d'un fichier généré par `ExportService`), `DeleteAllDataButton`, `AboutView`.

### 3.7 Transverse
- `RootView` : onboarding si non fait ; écran de verrou si activé ; masquage du contenu quand l'app passe en arrière-plan (`scenePhase != .active` → flou), pour que l'aperçu du sélecteur d'apps ne montre pas de données de santé.

---

## 4. Qualité : tests, previews, accessibilité, localisation

### 4.1 Tests (Swift Testing)

| Couche | Outil | Exemples |
|---|---|---|
| Domaine (`SOPKDomain`) | Swift Testing, `swift test` (Linux + Mac) | phases, durées moyennes, cycles irréguliers, bascule d'heure, années bissextiles |
| Stores / export / router | Swift Testing dans `SOPKTests`, `ModelContainer` en mémoire | `fetchOrCreate` ne crée pas de doublon, export → JSON relisible, suppression totale vide la base |
| UI | XCTest UI (Swift Testing ne gère pas les tests UI) | 1 parcours smoke (onboarding → saisie du jour) + `performAccessibilityAudit()` |

```swift
import Testing
@testable import SOPKDomain

@Suite("CycleCalculator")
struct CycleCalculatorTests {
    @Test("Phase estimée selon la durée de cycle", arguments: [
        (day: 1,  length: 28, expected: CyclePhase.menstrual),
        (day: 14, length: 28, expected: .ovulatory),
        (day: 20, length: 35, expected: .ovulatory),
    ])
    func phase(day: Int, length: Int, expected: CyclePhase) {
        #expect(CycleCalculator.phase(day: day, cycleLength: length) == expected)
    }

    @Test func confianceFaibleSiCyclesIrreguliers() {
        let starts: [LocalDate] = [...]   // 26, 41, 33 jours
        #expect(CycleCalculator.prediction(from: starts).confidence == .low)
    }
}
```
Helper de test SwiftData :
```swift
@MainActor func makeTestContainer() throws -> ModelContainer {
    try ModelContainer(for: Schema(versionedSchema: SchemaV1.self),
                       configurations: ModelConfiguration(isStoredInMemoryOnly: true))
}
```
Règles : l'horloge est injectée (jamais `Date()` dans la logique testée) ; cible de couverture **domaine ≥ 90 %**, le reste au jugé ; un bug corrigé = un test.

### 4.2 Previews
- Chaque vue a au moins un `#Preview`, idéalement deux (avec données / vide) + une en Dynamic Type XXL et une en mode sombre pour les écrans principaux.
- `Preview/PreviewData.swift` fournit un container en mémoire pré-rempli ; modificateur `.previewContainer()` à appliquer.
- `@Previewable @State` pour les vues qui prennent un `Binding`.
- Une preview qui crashe = un bug à corriger (signe d'une dépendance non injectée).

### 4.3 Accessibilité (non négociable, dès le premier écran)
- **Dynamic Type** : uniquement des styles de texte (`.body`, `.headline`…) ; `@ScaledMetric` pour les tailles d'icônes/espacements ; `ViewThatFits` ou bascule `HStack`→`VStack` quand `dynamicTypeSize.isAccessibilitySize`. Pas de `frame(height:)` fixe sur du texte.
- **VoiceOver** : `accessibilityLabel` sur tout bouton icône ; cellules du calendrier lues « 12 novembre, règles abondantes, 2 symptômes » (`accessibilityElement(children: .combine)` + label construit) ; graphiques avec `accessibilityChartDescriptor` ou résumé textuel ; ordre de lecture vérifié sur Aujourd'hui.
- **Autres** : contraste ≥ 4.5:1 (vérifier les couleurs de phases, en clair et sombre) ; ne jamais coder une info uniquement par la couleur (icône ou texte en plus) ; respecter `accessibilityReduceMotion` ; cibles tactiles ≥ 44 pt.
- **Vérification** : Accessibility Inspector à chaque écran + `try app.performAccessibilityAudit()` dans le test UI smoke (bloquant en CI).

### 4.4 Localisation
- Langue de développement du projet : **Français** (Project → Info → Localizations : ajouter French, le définir comme Development Language, retirer English pour l'instant ; ou `developmentRegion = fr`).
- `Localizable.xcstrings` (String Catalog) : Xcode extrait automatiquement les littéraux de `Text("…")`, `Button("…")`, `String(localized: "…")`. Activer `SWIFT_EMIT_LOC_STRINGS = YES` (défaut).
- Pièges : `Text(maVariableString)` n'est **pas** traduit (utiliser `LocalizedStringKey`/`LocalizedStringResource`) ; pluriels gérés dans le catalogue (« Vary by plural »), pas avec des `if count > 1` ; dates/nombres toujours via `.formatted(...)` (jamais de format manuel `dd/MM`).
- Les clés sont le texte FR ; on ajoutera l'anglais quand l'app s'ouvrira, sans toucher au code.
- Le contenu JSON (recettes) est en FR ; prévoir un champ `locale` ou un fichier par langue plus tard.

---

## 5. Setup pas-à-pas

**Prérequis** : Mac avec la dernière version stable d'Xcode (26.x), Homebrew, compte Apple. Simulateur iOS 17 installé (Xcode → Settings → Components) pour tester la version minimale.

1. **Nettoyer le repo** : `git tag v0-final && git push --tags`, puis PR qui supprime `iOS/`, `backoffice/`, `supabase/`, les workflows V0 et met à jour `CLAUDE.md`.
2. **Créer le projet** : Xcode → New Project → iOS App. Product Name `SOPK`, Interface SwiftUI, Storage **None** (on configure SwiftData à la main pour le versioning), cocher *Include Tests*. Emplacement : `ios/` à la racine du repo, **décocher** « Create Git repository ».
3. **Réglages cible** (Build Settings, ou mieux dans `Config/Shared.xcconfig`) :
   ```
   IPHONEOS_DEPLOYMENT_TARGET = 17.0
   SWIFT_VERSION = 6
   SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor
   SWIFT_APPROACHABLE_CONCURRENCY = YES
   PRODUCT_BUNDLE_IDENTIFIER = com.<toi>.sopk
   TARGETED_DEVICE_FAMILY = 1          // iPhone uniquement pour le MVP
   ```
   `Debug.xcconfig` : `#include "Shared.xcconfig"`, `PRODUCT_BUNDLE_IDENTIFIER = $(inherited).debug`, `INFOPLIST_KEY_CFBundleDisplayName = SOPK β` (les deux apps cohabitent sur l'iPhone). Assigner les xcconfig : Project → Info → Configurations.
4. **Dossiers** : créer l'arborescence §2.2 en *folders* (icône bleue = synchronisé), pas en *groups*.
5. **Package domaine** : File → New → Package → `ios/Packages/SOPKDomain`, l'ajouter au projet, puis cible SOPK → General → Frameworks → `+` SOPKDomain. Vérifier `swift test --package-path ios/Packages/SOPKDomain` en terminal.
6. **Signing** : Signing & Capabilities → *Automatically manage signing*, Team = ton compte. Compte gratuit : installation sur iPhone possible (profil valable 7 jours). **Apple Developer Program (99 €/an) nécessaire pour TestFlight** et pour le partager à ta compagne durablement — à prendre avant le ticket 19.
7. **Capability Data Protection** : ajouter *Data Protection* → *Complete Protection* (entitlement `com.apple.developer.default-data-protection = NSFileProtectionComplete`) : la base est chiffrée quand l'iPhone est verrouillé.
8. **Schémas** : Product → Scheme → Manage Schemes → cocher **Shared** pour `SOPK` (sinon la CI ne voit pas le schéma). Run = Debug, Archive = Release. Créer un Test Plan `SOPK.xctestplan` (tests unitaires + UI, langue FR, région FR) ; ajouter les tests de `SOPKDomain` au plan.
9. **SwiftLint** : `brew install swiftlint`, puis `ios/.swiftlint.yml` :
   ```yaml
   included: [SOPK, SOPKTests, SOPKUITests, Packages/SOPKDomain/Sources]
   opt_in_rules: [empty_count, explicit_init, first_where, force_unwrapping, sorted_imports, vertical_whitespace_closing_braces]
   line_length: { warning: 140, error: 200 }
   file_length: { warning: 300, error: 500 }
   type_body_length: { warning: 250 }
   ```
   En local : build phase *Run Script* `if which swiftlint >/dev/null; then swiftlint; fi` (mettre `ENABLE_USER_SCRIPT_SANDBOXING = NO` pour la cible, ou utiliser le plugin SPM `SimplyDanny/SwiftLintPlugins`). En CI : étape dédiée `--strict`.
10. **GitHub Actions** : `.github/workflows/ios.yml`
    ```yaml
    name: iOS
    on:
      push: { branches: [main] }
      pull_request:
    concurrency: { group: ios-${{ github.ref }}, cancel-in-progress: true }

    jobs:
      domain:                       # rapide et bon marché
        runs-on: ubuntu-latest
        container: swift:6.2
        steps:
          - uses: actions/checkout@v4
          - run: swift test --package-path ios/Packages/SOPKDomain

      app:
        needs: domain
        runs-on: macos-15             # ou macos-26 : vérifier les images dans actions/runner-images
        timeout-minutes: 30
        defaults: { run: { working-directory: ios } }
        steps:
          - uses: actions/checkout@v4
          - name: Choisir Xcode
            run: sudo xcode-select -s /Applications/Xcode_26.1.app   # adapter à la version installée sur l'image
          - name: SwiftLint
            run: brew install swiftlint && swiftlint lint --strict --reporter github-actions-logging
          - name: Build & tests
            run: |
              set -o pipefail
              xcodebuild test \
                -project SOPK.xcodeproj -scheme SOPK -testPlan SOPK \
                -destination "platform=iOS Simulator,name=iPhone 16,OS=latest" \
                -skipPackagePluginValidation -skipMacroValidation \
                CODE_SIGNING_ALLOWED=NO | xcbeautify
    ```
    Notes : `CODE_SIGNING_ALLOWED=NO` → aucun certificat nécessaire en CI pour le simulateur. Lister les simulateurs disponibles avec `xcrun simctl list devices available` si la destination échoue. Sur repo privé, une minute macOS compte ×10 dans le quota gratuit : d'où le job Linux en premier et `paths`/`concurrency` pour limiter. La publication TestFlight depuis la CI (fastlane/App Store Connect API) est **hors MVP** : archive manuelle depuis Xcode (Product → Archive → Distribute).
11. **Protection de branche** : `main` protégée, les deux jobs requis pour merger.

---

## 6. Backlog des 20 premiers tickets

| # | Ticket | Critère de done |
|---|---|---|
| 1 | Nettoyage V0 + tag `v0-final` | Tag poussé ; `iOS/`, `backoffice/`, `supabase/`, workflows V0 supprimés ; `CLAUDE.md` réécrit pour la V2 |
| 2 | Création projet Xcode + arborescence + xcconfig | L'app « Hello » se lance sur simulateur iOS 17 et récent ; Debug et Release ont des bundle ids distincts ; Swift 6 + MainActor par défaut actifs |
| 3 | Package `SOPKDomain` + premier test | `swift test` passe en local ; le package est lié à l'app et importable |
| 4 | CI GitHub Actions (Linux + macOS) + SwiftLint strict | PR de test : les 2 jobs verts ; une violation lint ou un test rouge fait échouer la PR ; branche `main` protégée |
| 5 | Design system v1 | Couleurs dans Assets (clair/sombre, contrastes vérifiés), `Spacing`, composants `Card`, `Chip`, `PrimaryButton`, `EmptyState` avec previews clair/sombre/XXL |
| 6 | Localisation FR | Langue de dev = FR ; `Localizable.xcstrings` présent ; règle documentée ; aucune chaîne en dur détectée (test UI lancé en FR) |
| 7 | Domaine : `LocalDate`, `FlowLevel`, `Symptom`, `CyclePhase` | Types `Sendable`, `Codable`, `CaseIterable` ; tests de conversion `Date ↔ LocalDate` incluant changement d'heure et fuseau |
| 8 | Domaine : `CycleCalculator` | Débuts de cycle déduits des jours de flux ; moyenne, variabilité, prédiction + confiance ; ≥ 15 cas paramétrés dont cycles irréguliers SOPK ; couverture ≥ 90 % |
| 9 | SwiftData `SchemaV1` + `MigrationPlan` + container + Data Protection | Modèles `DayLog`, `ActivityLog`, `FavoriteRecipe`, `UserSettings` compatibles CloudKit ; `PreviewData` en mémoire ; entitlement Data Protection actif |
| 10 | Stores `DayLogStore` / `ActivityStore` | `fetchOrCreate(day:)` sans doublon, save, delete ; tests Swift Testing sur container en mémoire |
| 11 | Shell de navigation : `TabView`, `Router`, `AppSheet`, `DeepLink` | 5 onglets avec piles indépendantes ; tests unitaires du `Router` (deep link → bon onglet + sheet) |
| 12 | Onboarding complet + avertissement non-médical | Parcours de bout en bout ; consentement obligatoire pour continuer ; ne réapparaît pas ; test UI smoke qui le traverse |
| 13 | Saisie du jour (`DayLogSheet`) | Flux, symptômes, humeur, énergie, note enregistrés et réédités ; utilisable entièrement avec VoiceOver |
| 14 | Écran Cycle : calendrier + historique | Mois navigables ; jours saisis vs estimés distingués autrement que par la couleur ; stats de cycle affichées avec confiance |
| 15 | Écran Aujourd'hui | Carte de statut avec confiance, saisie rapide, suggestions recette/activité, état vide propre ; previews données/vide |
| 16 | Contenu embarqué + écran Alimentation | `recipes.json` (≥ 20 recettes relues) décodé avec test de validité ; liste, recherche, filtres, détail, portions, favoris persistés |
| 17 | Écran Activité | Bibliothèque `activities.json`, détail, journal d'activité, résumé hebdo avec graphique accessible |
| 18 | Profil, réglages, rappels | Édition cycle/objectifs ; rappel quotidien local programmable/annulable (`NotificationScheduling` mockable, testé) ; tap sur la notif → saisie du jour |
| 19 | Confidentialité : export, suppression, verrou, masquage | Export JSON (+ CSV) via feuille de partage, relu par un test ; suppression totale testée ; verrou Face ID optionnel ; contenu flouté dans le sélecteur d'apps ; `PrivacyInfo.xcprivacy` rempli |
| 20 | Passe accessibilité + première build TestFlight | `performAccessibilityAudit()` vert sur les 5 onglets ; tous les écrans vérifiés en XXL ; build Release archivée et installée via TestFlight sur l'iPhone de la testeuse |

Ordre conseillé : 1 → 4 en semaine 1 (fondations, ne pas les sauter), puis 7-10 (cœur métier testé), puis les écrans. Tickets 5-6 peuvent avancer en parallèle de 7-8.

---

## 7. Mémo pour dev web : analogies

| Concept SwiftUI / Swift | Équivalent web | À retenir |
|---|---|---|
| `struct MaVue: View { var body }` | Composant fonction React | `body` est recalculé souvent, il doit rester pur et rapide. Pas d'effet de bord dedans |
| `@State` | `useState` | Propriété de la vue, survit aux re-renders. Toujours `private` |
| `@Binding` / `$valeur` | Passer `value` + `setValue` en props | `$` crée le binding ; l'enfant modifie l'état du parent |
| `@Observable` class | Store MobX / `reactive()` de Vue | Suivi fin : seule une vue qui **lit** une propriété est re-rendue quand elle change. Pas de sélecteurs à écrire |
| `@Environment` / `.environment()` | React Context (Provider/useContext) | Injection descendante, idéal pour la DI |
| `.task { await … }` | `useEffect` + fonction async + `AbortController` | Démarre à l'apparition, **annulé automatiquement** à la disparition |
| `.task(id: x)` | `useEffect(…, [x])` | Relancé quand `x` change |
| `NavigationStack(path:)` | react-router avec l'historique dans un tableau | Le tableau `path` **est** la navigation : push = `append`, retour = `removeLast` |
| `enum Route` avec valeurs associées | Union discriminée TypeScript | `switch` exhaustif vérifié par le compilateur |
| Optionnel `T?`, `if let`, `guard let` | `T \| undefined` en TS strict, `?.`, `??` | Pas de `!` (force unwrap) = pas de crash |
| `protocol` | `interface` TS | Mais on n'en crée que pour les doubles de test réellement utiles |
| SwiftData `@Model` + `ModelContext` | ORM (Prisma/TypeORM) sur IndexedDB locale | `ModelContext` ≈ unit of work ; sauvegarde auto, `try context.save()` pour forcer |
| `@Query` | `useLiveQuery` (Dexie) / React Query sur DB locale | La vue se met à jour seule quand les données changent |
| `@MainActor` | Le thread principal JS (event loop) | Tout ce qui touche l'UI y vit ; par défaut ici, tout le code app y est |
| `actor` | Un Web Worker avec sa propre file de messages | Accès sérialisé, on lui parle avec `await` |
| `Sendable` | Données transférables à un Worker (`structuredClone`) | Les `struct` simples le sont ; les classes mutables non |
| Swift Package (SPM) | Package npm d'un workspace / monorepo | `Package.swift` ≈ `package.json` |
| `.xcconfig` | `.env` (non secret) par environnement | Debug/Release ≈ dev/prod |
| `#Preview` | Storybook | Plusieurs états par composant, sans lancer l'app |
| Swift Testing (`@Test`, `#expect`) | Vitest/Jest (`test`, `expect`) | `arguments:` ≈ `test.each` |
| `ViewModifier` / `.modifier()` | Classe utilitaire CSS / HOC | Ordre des modificateurs = important (comme des wrappers imbriqués) |
| String Catalog `.xcstrings` | Fichiers i18next JSON, extraits automatiquement | La clé est le texte FR |
| Signing / provisioning | Certificat HTTPS + nom de domaine, version Apple | Laisser Xcode gérer (« Automatically manage signing ») |

**Trois pièges classiques venant du web**
1. Vouloir un store global unique : préférer plusieurs petits objets `@Observable` + `@Query` dans les vues.
2. Mettre de la logique dans `body` : la sortir dans des propriétés calculées, le modèle ou le domaine.
3. Réinventer le design : les composants système (`Form`, `List`, `DatePicker`, `.searchable`, `.sheet`) apportent gratuitement accessibilité, mode sombre et Dynamic Type. On les personnalise, on ne les remplace pas.
