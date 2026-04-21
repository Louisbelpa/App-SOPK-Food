-- Ajout colonne allergènes sur les recettes
-- Valeurs possibles : gluten, oeufs, fruits_de_mer, arachides, soja, lait, fruits_a_coque, sesame
ALTER TABLE recipes
  ADD COLUMN IF NOT EXISTS allergens TEXT[] NOT NULL DEFAULT '{}';

CREATE INDEX IF NOT EXISTS idx_recipes_allergens ON recipes USING GIN (allergens);
