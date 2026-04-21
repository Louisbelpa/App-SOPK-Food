Ajoute une nouvelle recette anti-inflammatoire dans le projet SOPK Food.

**Fichiers à modifier :**
1. `supabase/seed.sql` — ajouter la variable UUID, l'INSERT dans recipes, les ingrédients et les étapes
2. Ne pas toucher aux Edge Functions ni aux migrations

**Format UUID à suivre :**
- Prochaine variable disponible après r19 : `r20 UUID := 'a1000000-0000-0000-0000-000000000020'`
- Incrémente selon le nombre de recettes existantes

**Colonnes INSERT recipes :**
`(id, title, description, prep_time, cook_time, servings, conditions, meal_type, tags, allergens)`

**Valeurs conditions :** `ARRAY['sopk']`, `ARRAY['endometriose']` ou `ARRAY['sopk','endometriose']`

**Valeurs meal_type :** `breakfast`, `lunch`, `dinner`, `snack`

**Tags nutritionnels disponibles** (utilise ceux qui correspondent) :
`Anti-inflammatoire`, `Riche en oméga-3`, `Vitamine D`, `Riche en magnésium`, `Vitamine B6`,
`Riche en fer`, `Riche en B12`, `Folates`, `Antioxydant`, `IG bas`, `Riche en fibres`,
`Détox hormonale`, `Lignanes`, `Zinc`, `Collagène`, `Protéines`, `Riche en protéines végétales`,
`Soutien hépatique`, `Choline`, `Anti-douleur`, `Calcium`, `Boost énergie`, `Réconfortant`,
`Sans gluten`, `Sans lactose`, `Vegan`, `Végétarien`, `Sans sucre ajouté`, `Cru`

**Allergènes disponibles :**
`gluten`, `oeufs`, `fruits_de_mer`, `arachides`, `soja`, `lait`, `fruits_a_coque`, `sesame`, `poisson`

**Après l'ajout :** commite avec le message `feat(seed): ajouter recette "[titre]"` et pousse sur la branche courante.
