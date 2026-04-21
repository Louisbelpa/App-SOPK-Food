# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

SOPK Food is an anti-inflammatory recipe app for PCOS (SOPK) and endometriosis. It consists of three parts:
- **iOS app** — SwiftUI, iOS 17+, MVVM + Repository pattern
- **Backoffice** — Next.js 14, TypeScript, Tailwind CSS (admin CRUD for recipes)
- **Backend** — Supabase (PostgreSQL + Auth + Storage + Realtime + Edge Functions in Deno)

## Commands

### Backoffice (Next.js)
```bash
cd backoffice
npm run dev          # dev server on localhost:3000
npm run build        # production build
npm run lint         # ESLint
npx tsc --noEmit     # type-check only
```

### Supabase local
```bash
supabase start                        # start local stack (API :54321, Studio :54323)
supabase db reset                     # reset DB + run migrations + seed
supabase functions serve recipes      # serve one Edge Function locally
supabase db push                      # push migrations to linked remote project
supabase link --project-ref <ref>     # link to remote project
```

### iOS
Open `iOS/SOPK/SOPK.xcodeproj` in Xcode. No CLI build commands — use Xcode or `xcodebuild`.  
Tests live in `SOPKTests/` — run with `Cmd+U` in Xcode.

## Architecture

### iOS (`iOS/SOPK/SOPK/SOPK/`)

**Data flow**: `AppContainer` (DI) → `Repository` (protocol) → `Store` (ObservableObject) → SwiftUI View

- `Core/DI/AppContainer.swift` — singleton factory; swap repositories here for testing
- `Core/Repositories/` — protocol + Supabase implementation for recipes, meal-plan, shopping
- `Core/Store/` — `RecipeStore`, `MealPlanStore`, `ShoppingStore`, `CycleStore`
- `Models/FavoritesStore.swift` — favorites (also a store, lives in Models/)
- `Core/Network/SupabaseClient.swift` — custom REST client (no Supabase Swift SDK); handles auth tokens via Keychain, calls Edge Functions via `callFunction<T: Decodable>()`
- `Models/AppRecipe.swift` — canonical API model decoded from Edge Function response `{ data: [AppRecipe], meta: {...} }`
- `Models/SampleData.swift` — offline fallback; `SampleData.appRecipes` maps `SampleRecipe → AppRecipe`
- `Features/` — one folder per screen (Auth, Home, RecipeDetail, MealPlanner, ShoppingList, Family, Onboarding)
- `Core/Extensions/DesignSystem.swift` — `Palette` struct with all colors (`.light` / `.dark`)

**Key conventions**:
- All stores are `@MainActor final class`
- Errors propagate via `@Published var error: AppError?` on each store
- `CycleStore.phaseFor(day:length:)` uses the medically correct formula: luteal = always 14j, so `ovulationDay = cycleLength - 14`
- Disclaimer shown once at first launch via `@AppStorage("hasSeenDisclaimer")` in `RootView`

### Supabase backend

**Migrations** (apply in order):
1. `20260418000000_initial.sql` — all tables, RLS, trigger for profile auto-creation
2. `20260419000001_profile_health_fields.sql` — adds `last_period_date`, `cycle_length`, `symptoms`, `avoid_tags`
3. `20260420000002_indexes_rls_optimization.sql` — 12 indexes + `get_my_family_id()` / `get_my_role()` STABLE functions used in RLS policies
4. `20260420000003_recipe_allergens.sql` — adds `allergens TEXT[]` column + GIN index

**Edge Functions** (`supabase/functions/`):
- `recipes/` — public (ANON_KEY, no JWT required); returns paginated `{ data, meta }` with 20 recipes/page; supports `?condition=`, `?meal_type=`, `?page=`
- `meal-plan/` — requires JWT (Bearer token); GET/POST/DELETE week entries
- `shopping/` — requires JWT; GET/POST/PATCH/DELETE shopping items
- `_shared/cors.ts` — shared CORS headers, `checkRateLimit()`, `getClientIp()`; CORS origin controlled by `ALLOWED_ORIGIN` env var

**RLS summary**: profiles (own only), families (members), recipes (public read, admin write), meal_plan + shopping (family-scoped via `get_my_family_id()`).

**Seed**: `supabase/seed.sql` — 19 anti-inflammatory recipes with ingredients, steps, tags, and allergens. Runs automatically on `supabase db reset`.

### Backoffice (`backoffice/`)

Next.js App Router. All `/dashboard/*` routes protected by `middleware.ts` (Supabase SSR session check). Sentry wired in `sentry.*.config.ts` + `next.config.mjs`. Admin role required — set via SQL: `UPDATE profiles SET role = 'admin' WHERE id = '<uuid>'`.

### CI/CD (`.github/workflows/`)
- `ci.yml` — runs on every push: backoffice lint + type-check + build, Deno type-check for Edge Functions, migration order check, SwiftLint
- `deploy-edge-functions.yml` — deploys functions on push to `main` when `supabase/functions/**` changes
- `deploy-migrations.yml` — runs `supabase db push` on push to `main` when `supabase/migrations/**` changes

## Required secrets (GitHub + Vercel)
`SUPABASE_PROJECT_REF`, `SUPABASE_ACCESS_TOKEN`, `SUPABASE_DB_PASSWORD`, `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`, `ALLOWED_ORIGIN`, `NEXT_PUBLIC_SENTRY_DSN`

## iOS credentials setup
Create `iOS/SOPK/Secrets.xcconfig` (git-ignored):
```
SUPABASE_URL = https://xxx.supabase.co
SUPABASE_ANON_KEY = eyJ...
```
Assign in Xcode: Project → Info → Configurations. Add keys to `Info.plist` as `$(SUPABASE_URL)` / `$(SUPABASE_ANON_KEY)`.
