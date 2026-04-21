Crée une nouvelle fonctionnalité dans l'app iOS SOPK Food.

**Architecture à respecter :**

1. **Si la feature nécessite des données Supabase** → créer dans `Core/Repositories/` :
   - Un protocol `XxxRepository` avec les méthodes async throws
   - Une classe `SupabaseXxxRepository: XxxRepository` qui appelle `client.request()` ou `client.callFunction()`
   - Enregistrer dans `Core/DI/AppContainer.swift` comme `lazy var`

2. **Store ObservableObject** → créer dans `Core/Store/XxxStore.swift` :
   - `@MainActor final class XxxStore: ObservableObject`
   - `@Published private(set) var items: [X] = []`
   - `@Published var error: AppError?`
   - `init(repository: any XxxRepository = SupabaseXxxRepository())`

3. **Vue SwiftUI** → créer dans `Features/NomFeature/` :
   - Recevoir le store via `@EnvironmentObject`
   - Palette de couleurs : utiliser `palette.ink`, `palette.sageDeep`, `palette.bg`, `palette.card`, `palette.cardAlt`, `palette.line`, `palette.inkSoft`, `palette.inkMuted`
   - Police titre : `.font(.custom("Fraunces", size: XX))`

4. **Enregistrer dans** `App/SOPKApp.swift` → ajouter `.environmentObject(container.xxxStore)` si nouveau store

5. **Enregistrer dans** `App/MainTabView.swift` si nouvel onglet

**Conventions :**
- Pas de singletons directs dans les vues — tout passe par le DI container
- `try?` interdit — toujours `do/catch` avec publication dans `store.error`
- Les erreurs Supabase se mappent via `AppError(from: error)` (`Core/Error/AppError.swift`)
