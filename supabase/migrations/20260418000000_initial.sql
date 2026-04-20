-- ============================================================
-- SOPK App — Migration Supabase
-- Coller ce script dans l'éditeur SQL de votre projet Supabase
-- (Dashboard > SQL Editor > New query)
-- ============================================================

-- 1. Familles
CREATE TABLE IF NOT EXISTS families (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT NOT NULL,
  invite_code TEXT UNIQUE NOT NULL,
  created_by  UUID REFERENCES auth.users(id),
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Profils utilisateurs
CREATE TABLE IF NOT EXISTS profiles (
  id           UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT,
  condition    TEXT CHECK (condition IN ('sopk', 'endometriose', 'both')),
  family_id    UUID REFERENCES families(id),
  role         TEXT DEFAULT 'member' CHECK (role IN ('admin', 'member')),
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

-- Auto-créer un profil à l'inscription
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO profiles (id) VALUES (NEW.id) ON CONFLICT DO NOTHING;
  RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- 3. Recettes
CREATE TABLE IF NOT EXISTS recipes (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title       TEXT NOT NULL,
  description TEXT,
  image_url   TEXT,
  prep_time   INT CHECK (prep_time >= 0),
  cook_time   INT CHECK (cook_time >= 0),
  servings    INT CHECK (servings > 0),
  conditions  TEXT[] NOT NULL DEFAULT '{}',
  meal_type   TEXT NOT NULL CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack')),
  tags        TEXT[] DEFAULT '{}',
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Ingrédients
CREATE TABLE IF NOT EXISTS ingredients (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  recipe_id   UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
  name        TEXT NOT NULL,
  quantity    FLOAT CHECK (quantity > 0),
  unit        TEXT,
  category    TEXT DEFAULT 'autre'
);

-- 5. Étapes
CREATE TABLE IF NOT EXISTS steps (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  recipe_id   UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
  position    INT NOT NULL CHECK (position > 0),
  instruction TEXT NOT NULL
);

-- 6. Favoris
CREATE TABLE IF NOT EXISTS favorites (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  recipe_id   UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
  saved_at    TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (user_id, recipe_id)
);

-- 7. Planning de repas
CREATE TABLE IF NOT EXISTS meal_plan_entries (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  family_id   UUID NOT NULL REFERENCES families(id) ON DELETE CASCADE,
  recipe_id   UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
  date        DATE NOT NULL,
  meal_type   TEXT NOT NULL CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack')),
  added_by    UUID REFERENCES auth.users(id)
);

-- 8. Liste de courses
CREATE TABLE IF NOT EXISTS shopping_items (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  family_id   UUID NOT NULL REFERENCES families(id) ON DELETE CASCADE,
  name        TEXT NOT NULL,
  quantity    FLOAT,
  unit        TEXT,
  category    TEXT DEFAULT 'autre',
  is_checked  BOOL DEFAULT FALSE,
  added_by    UUID REFERENCES auth.users(id),
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

ALTER TABLE profiles         ENABLE ROW LEVEL SECURITY;
ALTER TABLE families         ENABLE ROW LEVEL SECURITY;
ALTER TABLE recipes          ENABLE ROW LEVEL SECURITY;
ALTER TABLE ingredients      ENABLE ROW LEVEL SECURITY;
ALTER TABLE steps            ENABLE ROW LEVEL SECURITY;
ALTER TABLE favorites        ENABLE ROW LEVEL SECURITY;
ALTER TABLE meal_plan_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE shopping_items   ENABLE ROW LEVEL SECURITY;

-- Profiles : lecture/écriture personnelle
CREATE POLICY "profiles_select_own"    ON profiles FOR SELECT USING (id = auth.uid());
CREATE POLICY "profiles_insert_own"    ON profiles FOR INSERT WITH CHECK (id = auth.uid());
CREATE POLICY "profiles_update_own"    ON profiles FOR UPDATE USING (id = auth.uid());

-- Families : accessible aux membres
CREATE POLICY "families_select_member" ON families FOR SELECT
  USING (id IN (SELECT family_id FROM profiles WHERE id = auth.uid()));
CREATE POLICY "families_insert_auth"   ON families FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- Recettes : lecture publique, écriture admin
CREATE POLICY "recipes_select_all"     ON recipes FOR SELECT USING (TRUE);
CREATE POLICY "recipes_write_admin"    ON recipes FOR ALL
  USING ((SELECT role FROM profiles WHERE id = auth.uid()) = 'admin');

-- Ingrédients & Étapes : lecture publique
CREATE POLICY "ingredients_select_all" ON ingredients FOR SELECT USING (TRUE);
CREATE POLICY "ingredients_write_admin" ON ingredients FOR ALL
  USING ((SELECT role FROM profiles WHERE id = auth.uid()) = 'admin');
CREATE POLICY "steps_select_all"       ON steps FOR SELECT USING (TRUE);
CREATE POLICY "steps_write_admin"      ON steps FOR ALL
  USING ((SELECT role FROM profiles WHERE id = auth.uid()) = 'admin');

-- Favoris : personnels
CREATE POLICY "favorites_own"          ON favorites FOR ALL USING (user_id = auth.uid());

-- Planning : famille partagée
CREATE POLICY "meal_plan_family"       ON meal_plan_entries FOR ALL
  USING (family_id = (SELECT family_id FROM profiles WHERE id = auth.uid()));

-- Liste de courses : famille partagée
CREATE POLICY "shopping_family"        ON shopping_items FOR ALL
  USING (family_id = (SELECT family_id FROM profiles WHERE id = auth.uid()));

-- ============================================================
-- REALTIME — activer pour shopping_items
-- ============================================================
-- Dans le dashboard Supabase : Database > Replication > shopping_items > activer INSERT, UPDATE, DELETE

-- ============================================================
-- STORAGE — créer le bucket recipe-images
-- ============================================================
-- Dans le dashboard Supabase : Storage > New bucket > "recipe-images" (public = true)

-- ============================================================
-- CRÉER UN COMPTE ADMIN
-- Après avoir créé votre compte via l'app ou Supabase Auth :
-- UPDATE profiles SET role = 'admin' WHERE id = 'VOTRE-USER-UUID';
-- ============================================================
