Crée une nouvelle migration SQL Supabase pour le projet SOPK Food.

**Convention de nommage obligatoire :**
`supabase/migrations/YYYYMMDD000000_nom_descriptif.sql`

Le timestamp doit être supérieur au dernier fichier existant dans `supabase/migrations/`.
Vérifie avec `ls supabase/migrations/` avant de créer.

**Structure du fichier :**
```sql
-- Description courte de ce que fait la migration

ALTER TABLE ...;
CREATE INDEX ...;
-- etc.
```

**Règles :**
- Toujours utiliser `IF NOT EXISTS` / `IF EXISTS` pour l'idempotence
- Les nouvelles politiques RLS qui filtrent par famille doivent utiliser `get_my_family_id()` (déjà défini)
- Les nouvelles politiques qui vérifient le rôle doivent utiliser `get_my_role()` (déjà défini)
- Ajouter un index GIN pour tout nouveau champ `TEXT[]`
- Ne jamais modifier les migrations existantes — toujours créer une nouvelle

**Après la création :** commite avec `chore(db): [description]` et pousse sur la branche courante.
