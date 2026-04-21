Checklist de déploiement du projet SOPK Food.

**Prérequis : secrets GitHub configurés**
`SUPABASE_PROJECT_REF`, `SUPABASE_ACCESS_TOKEN`, `SUPABASE_DB_PASSWORD`,
`NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`, `ALLOWED_ORIGIN`, `NEXT_PUBLIC_SENTRY_DSN`

---

**Déploiement manuel (si CI/CD pas encore configuré) :**

```bash
# 1. Lier le projet Supabase
supabase link --project-ref <PROJECT_REF>

# 2. Pusher les migrations
supabase db push

# 3. Seeder la base (première fois uniquement)
supabase db reset --linked

# 4. Déployer les Edge Functions
supabase functions deploy recipes --no-verify-jwt
supabase functions deploy meal-plan
supabase functions deploy shopping

# 5. Configurer le secret CORS
supabase secrets set ALLOWED_ORIGIN=https://ton-domaine.vercel.app

# 6. Activer Realtime sur shopping_items
# Dashboard > Database > Replication > shopping_items > INSERT, UPDATE, DELETE

# 7. Créer le bucket Storage
# Dashboard > Storage > New bucket > "recipe-images" (public = true)

# 8. Créer le premier admin
# UPDATE profiles SET role = 'admin' WHERE id = 'UUID';
```

**Déploiement automatique (après merge sur main) :**
- Migrations → `.github/workflows/deploy-migrations.yml` se déclenche automatiquement
- Edge Functions → `.github/workflows/deploy-edge-functions.yml` se déclenche automatiquement
- Backoffice → Vercel déploie automatiquement depuis main

**Variables Vercel à configurer :**
`NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`, `NEXT_PUBLIC_SENTRY_DSN`, `SENTRY_AUTH_TOKEN`, `SENTRY_ORG`, `SENTRY_PROJECT`
