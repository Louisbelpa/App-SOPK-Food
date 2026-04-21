-- ============================================================
-- Indexes manquants + optimisation des subqueries RLS
-- ============================================================

-- recipes — chemins chauds
CREATE INDEX IF NOT EXISTS idx_recipes_meal_type   ON recipes (meal_type);
CREATE INDEX IF NOT EXISTS idx_recipes_created_at  ON recipes (created_at);
CREATE INDEX IF NOT EXISTS idx_recipes_conditions  ON recipes USING GIN (conditions);
CREATE INDEX IF NOT EXISTS idx_recipes_tags        ON recipes USING GIN (tags);

-- ingredients & steps — jointures FK
CREATE INDEX IF NOT EXISTS idx_ingredients_recipe_id ON ingredients (recipe_id);
CREATE INDEX IF NOT EXISTS idx_steps_recipe_id       ON steps (recipe_id);

-- profiles — membership lookups (utilisé dans chaque évaluation RLS)
CREATE INDEX IF NOT EXISTS idx_profiles_family_id ON profiles (family_id);

-- meal_plan_entries — requête date range + famille
CREATE INDEX IF NOT EXISTS idx_meal_plan_family_date ON meal_plan_entries (family_id, date);

-- shopping_items — famille + statut cochage
CREATE INDEX IF NOT EXISTS idx_shopping_family_id      ON shopping_items (family_id);
CREATE INDEX IF NOT EXISTS idx_shopping_family_checked ON shopping_items (family_id, is_checked);

-- favorites — lookups par utilisateur
CREATE INDEX IF NOT EXISTS idx_favorites_user_id ON favorites (user_id);

-- ============================================================
-- Fonctions helper pour éviter les subqueries répétées dans RLS
-- Chaque SELECT sur meal_plan_entries ou shopping_items réévalue
-- (SELECT family_id FROM profiles WHERE id = auth.uid()) par ligne.
-- Ces fonctions STABLE sont évaluées une seule fois par requête.
-- ============================================================

CREATE OR REPLACE FUNCTION get_my_family_id()
RETURNS UUID LANGUAGE SQL SECURITY DEFINER STABLE
SET search_path = public
AS $$
  SELECT family_id FROM profiles WHERE id = auth.uid()
$$;

CREATE OR REPLACE FUNCTION get_my_role()
RETURNS TEXT LANGUAGE SQL SECURITY DEFINER STABLE
SET search_path = public
AS $$
  SELECT role FROM profiles WHERE id = auth.uid()
$$;

-- Mettre à jour les policies RLS pour utiliser les fonctions helper

-- Planning de repas
DROP POLICY IF EXISTS "meal_plan_family" ON meal_plan_entries;
CREATE POLICY "meal_plan_family" ON meal_plan_entries FOR ALL
  USING (family_id = get_my_family_id());

-- Liste de courses
DROP POLICY IF EXISTS "shopping_family" ON shopping_items;
CREATE POLICY "shopping_family" ON shopping_items FOR ALL
  USING (family_id = get_my_family_id());

-- Familles
DROP POLICY IF EXISTS "families_select_member" ON families;
CREATE POLICY "families_select_member" ON families FOR SELECT
  USING (id = get_my_family_id());

-- Recettes admin write
DROP POLICY IF EXISTS "recipes_write_admin" ON recipes;
CREATE POLICY "recipes_write_admin" ON recipes FOR ALL
  USING (get_my_role() = 'admin');

DROP POLICY IF EXISTS "ingredients_write_admin" ON ingredients;
CREATE POLICY "ingredients_write_admin" ON ingredients FOR ALL
  USING (get_my_role() = 'admin');

DROP POLICY IF EXISTS "steps_write_admin" ON steps;
CREATE POLICY "steps_write_admin" ON steps FOR ALL
  USING (get_my_role() = 'admin');
