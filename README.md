# SOPK — App iOS Recettes Anti-Inflammatoires

Application iOS native + back office web pour visualiser des recettes anti-inflammatoires adaptées au SOPK et à l'endométriose.

## Structure du projet

```
SOPK/
├── iOS/SOPK/               # App iOS SwiftUI
├── backoffice/             # Back office Next.js
└── supabase_migration.sql  # Script de création de la base de données
```

---

## 1. Configurer Supabase

1. Créer un projet sur [supabase.com](https://supabase.com)
2. **SQL Editor** → coller et exécuter `supabase_migration.sql`
3. **Storage** → créer un bucket `recipe-images` (public)
4. **Database > Replication** → activer Realtime sur `shopping_items`

---

## 2. Back office (Next.js)

```bash
cd backoffice
cp .env.local.example .env.local
# Remplir les 3 variables Supabase dans .env.local
npm install
npm run dev
# → http://localhost:3000
```

### Créer le premier admin

1. S'inscrire via l'app iOS ou Supabase Auth dashboard
2. Dans Supabase SQL Editor :
   ```sql
   UPDATE profiles SET role = 'admin' WHERE id = 'VOTRE-USER-UUID';
   ```
3. Se connecter sur le back office → `/login`

---

## 3. App iOS (SwiftUI)

1. Ouvrir Xcode → **Open a project** → sélectionner `iOS/SOPK/`
2. **File > Add Package Dependencies** → ajouter :
   - `https://github.com/supabase-community/supabase-swift`
3. Créer `iOS/SOPK/Config/Secrets.xcconfig` (exclus du git) :
   ```
   SUPABASE_URL = https://VOTRE-PROJET.supabase.co
   SUPABASE_ANON_KEY = VOTRE-ANON-KEY
   ```
4. Dans le Build Settings du target, référencer `Secrets.xcconfig`
5. Build & Run (iOS 17+)

---

## Fonctionnalités

| Feature | iOS | Back office |
|---|---|---|
| Catalogue de recettes | ✅ | — |
| Filtres SOPK / Endométriose | ✅ | ✅ |
| Détail recette | ✅ | — |
| Favoris (personnels) | ✅ | — |
| Planificateur hebdomadaire (famille) | ✅ | — |
| Liste de courses synchronisée temps réel | ✅ | — |
| Authentification | ✅ | ✅ |
| Familles (code d'invitation) | ✅ | — |
| CRUD recettes + upload images | — | ✅ |

---

## Stack technique

- **iOS** : SwiftUI · MVVM · Async/Await · iOS 17+
- **Back office** : Next.js 14 · TypeScript · Tailwind CSS
- **Backend** : Supabase (PostgreSQL · Auth · Storage · Realtime · RLS)
- **Déploiement back office** : Vercel
