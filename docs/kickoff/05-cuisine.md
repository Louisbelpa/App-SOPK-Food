# 05 — Cuisine : principes, tags, schéma de recette, semaine type

> Rédigé par le chef cuisinier (nutrition), en binôme avec la diététicienne.
> Fichier compagnon : [`recipes.json`](../../Packages/SOPKKit/Sources/SOPKKit/Resources/Content/recipes.json) (12 recettes respectant le schéma ci-dessous).
>
> Rappel : l'app informe et accompagne, elle ne remplace pas un suivi médical ni diététique. Aucune recette n'est un
> traitement du SOPK. Le ton est toujours bienveillant : pas d'aliments « interdits », pas de « triche », pas de calories
> affichées par défaut.

---

## 1. Principes culinaires

### 1.1 L'assiette équilibrée (repère visuel, pas une règle)

Pour un déjeuner ou un dîner, on vise une assiette qui ressemble à ça :

| Part de l'assiette | Famille | Exemples du quotidien |
|---|---|---|
| **~ 1/2** | **Légumes** (crus et/ou cuits, variés en couleurs) | carottes, poireaux, chou, épinards, courgettes, tomates, salade, betterave |
| **~ 1/4** | **Protéines** (animales ou végétales) | œufs, poisson, volaille, tofu, légumineuses, yaourt/fromage blanc |
| **~ 1/4** | **Féculents complets ou légumineuses** | riz complet ou semi-complet, quinoa, boulgour, sarrasin, pâtes complètes, pain au levain, lentilles, pois chiches, pommes de terre avec la peau |
| **+ 1 à 2 c. à soupe** | **Bons gras** | huile d'olive, huile de colza ou de noix (crue), noix, amandes, graines (lin, chia, courge), avocat, poissons gras |

Ces proportions sont un **repère** affiché dans la fiche recette (« composition de l'assiette ») et jamais un objectif
chiffré à atteindre. Une assiette « incomplète » n'est pas un échec : on complète avec ce qu'on a (un fruit, un yaourt,
une poignée de noix).

### 1.2 Associations qui limitent les pics glycémiques

Le SOPK s'accompagne souvent d'une résistance à l'insuline. En cuisine, on agit surtout par **les associations** et
**la préparation**, plutôt que par l'exclusion :

1. **Jamais un glucide seul** : on l'accompagne de fibres, de protéines et/ou de gras (ex. : pomme + quelques amandes,
   pain + œuf, riz + lentilles + légumes).
2. **Fibres d'abord** : commencer le repas par les crudités ou une soupe de légumes est une astuce simple, à proposer
   sans en faire une obligation.
3. **Choisir des féculents peu raffinés** : céréales complètes, légumineuses, flocons d'avoine plutôt que céréales
   soufflées sucrées ; pain au levain / de seigle plutôt que pain de mie blanc.
4. **Cuisson « al dente »** : pâtes et céréales moins cuites = absorption plus lente. Éviter les purées très lisses
   de pommes de terre ; préférer les écrasés avec la peau.
5. **Le froid aide** : riz, pâtes ou pommes de terre cuits puis refroidis (salades, batch cooking) forment de l'amidon
   résistant → réponse glycémique plus douce, même réchauffés.
6. **Un peu d'acidité** : vinaigre, citron, yaourt, choucroute dans le repas modèrent légèrement la réponse glycémique.
7. **Le sucré, de préférence en fin de repas** plutôt qu'isolé ; fruits entiers plutôt qu'en jus ; sucre ajouté
   limité (miel, sirop d'érable : même logique que le sucre, en petite quantité pour le goût).
8. **Petit-déjeuner protéiné** : œufs, yaourt grec/skyr, fromage blanc, tofu, beurre d'oléagineux → satiété durable et
   matinée plus stable.

### 1.3 Anti-inflammatoire, concrètement

- **Oméga-3** : poissons gras (sardine, maquereau, hareng, saumon) 1 à 2 fois par semaine ; huiles de colza et de noix
  en assaisonnement ; noix, graines de lin moulues, chia.
- **Végétaux colorés et variés** : polyphénols et fibres (légumes de saison, fruits rouges, herbes fraîches, épices :
  curcuma + poivre, gingembre, cannelle, cumin, paprika).
- **Légumineuses 3 fois par semaine ou plus** : protéines, fibres, budget.
- **Limiter sans interdire** : produits ultra-transformés, charcuteries, fritures, boissons sucrées.
- **Huile d'olive** comme matière grasse de cuisson par défaut ; colza/noix à cru (ne pas les chauffer).

### 1.4 Une cuisine du quotidien réaliste

- **≤ 30 minutes** de temps total pour la majorité des recettes (préparation + cuisson active). Les recettes plus longues
  sont signalées et doivent être majoritairement « sans surveillance » (four, mijotage).
- **Liste d'ingrédients courte** : 10 ingrédients maximum hors sel/poivre/huile/épices courantes.
- **Budget** : base de légumineuses sèches ou en conserve, œufs, céréales en vrac, légumes de saison, surgelés nature
  (épinards, haricots verts, fruits rouges), poissons en conserve (sardines, maquereau). Le saumon frais reste
  occasionnel. Tag `petit_budget` si coût estimé ≤ 2,50 €/portion.
- **Batch cooking** : chaque recette indique si elle se prépare à l'avance, se conserve et/ou se congèle. On cuisine
  « 1 base → 2 repas » (ex. : une grosse casserole de lentilles = salade le midi + dahl le soir).
- **Produits de saison (France métropolitaine)** : chaque recette déclare ses saisons ; l'app met en avant les recettes
  de saison et propose des substitutions (ex. : courgette → butternut en hiver).
- **Matériel de base** : une poêle, une casserole, une plaque de four, un mixeur plongeant au maximum.
- **Pas de super-aliments obligatoires** : pas de poudre exotique introuvable ; toute « graine de chia » a une
  alternative (graines de lin moulues).

Calendrier de saison simplifié (sert à remplir le champ `saisons`) :

| Saison | Légumes phares | Fruits phares |
|---|---|---|
| Hiver (déc.–fév.) | poireau, chou, carotte, butternut, potimarron, endive, céleri, betterave, épinard | pomme, poire, kiwi, agrumes |
| Printemps (mars–mai) | asperge, petits pois, radis, épinard, blette, oignon nouveau, artichaut | rhubarbe, fraise (fin), pomme de conservation |
| Été (juin–août) | courgette, tomate, aubergine, poivron, concombre, haricot vert, fenouil | fruits rouges, abricot, pêche, melon |
| Automne (sept.–nov.) | courge, champignons, chou-fleur, brocoli, betterave, poireau, patate douce | pomme, poire, raisin, figue, coing |

---

## 2. Système de tags et catégories

Tous les tags sont des **identifiants techniques stables** (snake_case, sans accents) + un libellé affiché en français.
Ils sont regroupés par famille ; chaque famille a une règle de cardinalité.

### 2.1 Type de repas — `types_repas` (1 à n)

| id | Libellé |
|---|---|
| `petit_dejeuner` | Petit-déjeuner |
| `dejeuner` | Déjeuner |
| `diner` | Dîner |
| `collation` | Collation |

Une recette peut avoir plusieurs types (une salade complète = `dejeuner` + `diner`).

### 2.2 Temps — `tags.temps` (exactement 1, **calculé** depuis `temps.total_min`)

| id | Règle |
|---|---|
| `express` | total ≤ 15 min |
| `rapide` | 16 à 30 min |
| `mijote` | > 30 min (la part active doit rester ≤ 20 min) |

### 2.3 Index glycémique estimé — `tags.ig_estime` (exactement 1)

| id | Libellé affiché | Signification |
|---|---|---|
| `bas` | IG bas | Recette dont les glucides viennent surtout de légumes, légumineuses, céréales complètes, fruits entiers, avec protéines/fibres/gras associés. |
| `modere` | IG modéré | Contient une source de glucides plus rapide (fruits secs, miel, riz blanc, pain…) mais équilibrée par l'association. |

Règles :
- C'est une **estimation qualitative** validée par la diététicienne, pas une mesure (l'IG d'un plat dépend de la
  cuisson, des portions, de la personne). Le libellé dit toujours « estimé » dans la fiche.
- **Pas de tag « IG élevé »** dans le catalogue : on n'en publie pas, et on ne stigmatise pas d'aliments.
- Une recette `modere` affiche une astuce d'association (« à déguster avec… »).

### 2.4 Régimes et préférences — `tags.regimes` (0 à n, filtres optionnels)

| id | Libellé | Règle de calcul / validation |
|---|---|---|
| `vegetarien` | Végétarien | aucun ingrédient de rayon `boucherie_volaille` ni `poissonnerie` |
| `vegan` | Végétalien | `vegetarien` + ni œufs, ni lait, ni miel |
| `sans_lactose` | Sans lactose | aucun ingrédient avec l'allergène `lait` (le beurre et les fromages affinés comptent) |
| `sans_gluten` | Sans gluten | aucun ingrédient avec l'allergène `gluten` (attention avoine : non certifiée = gluten) |

**Important — ton et positionnement** : `sans_gluten` et `sans_lactose` sont des **filtres de préférence ou de
tolérance**, pas des recommandations. Il n'existe pas de preuve qu'éviter le gluten ou les produits laitiers soit
nécessaire dans le SOPK en l'absence de maladie cœliaque, d'allergie ou d'intolérance diagnostiquée. L'app ne doit
jamais les présenter comme « meilleurs pour le SOPK ». Le texte d'aide du filtre :
« Utile si vous avez une intolérance, une allergie ou une préférence. Ce n'est pas nécessaire pour le SOPK en
général : parlez-en à votre médecin ou à votre diététicien·ne en cas de doute. »

### 2.5 Caractéristiques — `tags.caracteristiques` (0 à n)

| id | Libellé | Règle |
|---|---|---|
| `riche_en_proteines` | Riche en protéines | ≥ 20 g de protéines / portion (estimation) |
| `riche_en_fibres` | Riche en fibres | ≥ 6 g de fibres / portion (estimation) |
| `source_omega3` | Source d'oméga-3 | poisson gras, noix, lin, chia ou colza en quantité significative |
| `legumineuses` | Légumineuses | contient lentilles, pois chiches, haricots secs, pois cassés… |
| `batch_cooking` | Batch cooking | se prépare à l'avance et se conserve ≥ 3 jours au frigo |
| `congelable` | Se congèle | `conservation.congelation = true` |
| `petit_budget` | Petit budget | coût estimé ≤ 2,50 € / portion |
| `sans_cuisson` | Sans cuisson | `temps.cuisson_min = 0` |
| `a_emporter` | À emporter | se mange froid ou se réchauffe facilement (lunchbox) |
| `reconfortant` | Réconfortant | plat chaud, doux — utile les jours de fatigue ou de règles |

Les tags marqués « calculé » ou dont la règle est vérifiable (`vegetarien`, `vegan`, `sans_lactose`, `sans_gluten`,
`sans_cuisson`, `congelable`, `temps`) sont **dérivés automatiquement** par un script de validation à partir des
ingrédients et des champs : la saisie manuelle doit concorder, sinon la recette est rejetée.

### 2.6 Allergènes — `allergenes` (0 à n) : les 14 allergènes réglementaires UE

Règlement (UE) n° 1169/2011, annexe II. Identifiants fixes :

| id | Libellé | Pièges fréquents dans nos recettes |
|---|---|---|
| `gluten` | Céréales contenant du gluten (blé, seigle, orge, avoine, épeautre, kamut) | avoine non certifiée, boulgour, pain, sauce soja classique |
| `crustaces` | Crustacés | crevettes, bouillons de fruits de mer |
| `oeufs` | Œufs | pâtes fraîches, mayonnaise |
| `poissons` | Poissons | sauce nuoc-mâm, anchois |
| `arachides` | Arachides | beurre de cacahuète, huile d'arachide non raffinée |
| `soja` | Soja | tofu, tamari, sauce soja, edamame |
| `lait` | Lait (y compris lactose) | beurre, fromages, yaourt, crème |
| `fruits_a_coque` | Fruits à coque (amande, noisette, noix, cajou, pécan, Brésil, pistache, macadamia) | purée d'amande, lait d'amande, pesto |
| `celeri` | Céleri | bouillons cubes, céleri-rave, mélanges d'épices |
| `moutarde` | Moutarde | vinaigrettes, mélanges d'épices |
| `sesame` | Graines de sésame | tahini (houmous), gomasio |
| `sulfites` | Anhydride sulfureux et sulfites (> 10 mg/kg) | vinaigre de vin, fruits secs non bio, vin |
| `lupin` | Lupin | certaines farines sans gluten |
| `mollusques` | Mollusques | moules, calamars, sauce d'huître |

Règles :
- Chaque ingrédient porte ses allergènes ; ceux de la recette = **union** des allergènes de ses ingrédients
  (vérifié par script). Un ingrédient optionnel compte quand même (affiché « selon option »).
- `traces` n'est pas géré au niveau recette (cela dépend des produits achetés) : la fiche affiche toujours
  « Vérifiez les étiquettes des produits que vous achetez. »
- La noix de coco n'est **pas** un fruit à coque réglementaire UE (pas d'allergène, mais mention possible en astuce).

---

## 3. Schéma de données d'une recette

Format d'échange : JSON (seed embarqué dans l'app, local-first ; peut être servi plus tard par une API).
Version du schéma : `schema_version: 1`. Les clés sont en snake_case français pour rester lisibles par l'équipe.

### 3.1 Vue d'ensemble

```jsonc
{
  "schema_version": 1,
  "id": "diner-dahl-lentilles-corail-butternut",   // slug unique et stable (kebab-case), jamais réutilisé
  "titre": "Dahl de lentilles corail et butternut",
  "description": "Phrase d'accroche courte (≤ 200 caractères), ton chaleureux, sans promesse santé.",
  "types_repas": ["diner", "dejeuner"],
  "portions": 4,                                    // nombre de portions de base ; quantités exprimées pour ce nombre
  "temps": {
    "preparation_min": 10,
    "cuisson_min": 20,
    "repos_min": 0,                                 // trempage, marinade, nuit au frigo… (non compté dans total)
    "total_min": 30                                 // = preparation_min + cuisson_min
  },
  "difficulte": "facile",                           // "facile" | "moyen"
  "ingredients": [ /* voir 3.2 */ ],
  "etapes": [ /* voir 3.3 */ ],
  "tags": {
    "temps": "rapide",                              // express | rapide | mijote (calculé)
    "ig_estime": "bas",                             // bas | modere
    "regimes": ["vegetarien", "vegan", "sans_lactose", "sans_gluten"],
    "caracteristiques": ["legumineuses", "batch_cooking", "congelable", "petit_budget"]
  },
  "allergenes": [],                                 // union des allergènes des ingrédients (ids UE §2.6)
  "saisons": ["automne", "hiver"],                  // printemps | ete | automne | hiver (1 à 4)
  "composition_assiette": {                         // repère visuel §1.1 (booléens)
    "legumes": true, "proteines": true, "feculents": true, "bons_gras": true
  },
  "astuces": [                                      // 0 à n ; chaque astuce est typée pour l'UI
    { "type": "glycemie",     "texte": "…" },       // glycemie | batch | substitution | saison | budget | anti_gaspi | gout
    { "type": "substitution", "texte": "…" }
  ],
  "conservation": {
    "refrigerateur_jours": 4,                       // 0 = à consommer tout de suite
    "congelation": true,
    "note": "Boîte hermétique ; réchauffer avec un trait d'eau."
  },
  "image": {
    "url": null,                                    // null tant que la photo n'est pas faite ; asset local "recettes/<id>.jpg"
    "alt": "Description de la photo pour VoiceOver",
    "credit": null
  },
  "nutrition": null,                                // optionnel, JAMAIS affiché par défaut (cf. brief) ; réservé à un mode avancé opt-in
  "source": "originale",                            // "originale" | "adaptee:<référence>"
  "validation": { "chef": true, "dieteticienne": false, "date": "2026-11-26" }
}
```

### 3.2 Ingrédient structuré (pensé pour la liste de courses)

```jsonc
{
  "cle": "lentille_corail",          // identifiant canonique de l'ingrédient (référentiel partagé) → fusion dans la liste de courses
  "nom": "lentilles corail",         // libellé affiché dans la recette
  "quantite": 200,                   // nombre (décimal autorisé) ou null pour "selon le goût"
  "unite": "g",                      // voir unités ci-dessous
  "rayon": "epicerie_seche",         // voir rayons ci-dessous → regroupement de la liste de courses
  "preparation": "rincées",          // optionnel : "émincé", "en dés"… (affiché, ignoré par la liste de courses)
  "optionnel": false,
  "placard": false,                  // true = basique supposé en stock (sel, poivre, huile, épices) → décoché par défaut dans la liste
  "groupe": null,                    // optionnel : sous-titre ("Pour la sauce")
  "allergenes": []                   // ids UE §2.6
}
```

**Unités autorisées** (`unite`) — limitées pour permettre l'addition et la mise à l'échelle des portions :

| id | Affichage | Remarque |
|---|---|---|
| `g`, `kg` | g, kg | converties en g pour l'agrégation |
| `ml`, `cl`, `l` | ml, cl, L | converties en ml |
| `piece` | (rien) / « pièce » | œufs, oignons, citrons, pommes… |
| `gousse` | gousse(s) | ail |
| `botte` | botte(s) | herbes, radis |
| `tranche` | tranche(s) | pain |
| `boite` | boîte(s) | conserve ; préciser le poids égoutté dans `nom` |
| `cas` | c. à soupe | ≈ 15 ml — pas converti dans la liste de courses (affiché « ✓ en stock ? ») |
| `cac` | c. à café | ≈ 5 ml — idem |
| `pincee` | pincée | idem |
| `au_gout` | selon le goût | `quantite = null` |

**Rayons** (`rayon`) — ordre d'affichage dans la liste de courses (parcours type d'un supermarché) :

1. `fruits_legumes` — Fruits & légumes (frais, herbes fraîches)
2. `boulangerie` — Boulangerie
3. `boucherie_volaille` — Boucherie & volaille
4. `poissonnerie` — Poissonnerie (frais)
5. `cremerie_oeufs` — Crèmerie & œufs (yaourts, fromages, beurre, œufs)
6. `frais_vegetal` — Frais végétal (tofu, tempeh, houmous, laits végétaux frais)
7. `epicerie_seche` — Épicerie sèche (céréales, légumineuses sèches, flocons, farines)
8. `conserves` — Conserves & bocaux (légumineuses, poissons, tomates, lait de coco)
9. `fruits_secs_graines` — Fruits secs, oléagineux & graines
10. `huiles_condiments` — Huiles, vinaigres, condiments, épices
11. `epicerie_sucree` — Épicerie sucrée (chocolat, miel, cacao)
12. `surgeles` — Surgelés

**Règles liste de courses** :
- Agrégation par `cle` + unité normalisée (g, ml, pièce…). Deux unités incompatibles pour une même `cle`
  (ex. `piece` et `g`) restent sur deux lignes.
- Mise à l'échelle : `quantite × portions_voulues / portions`, arrondie intelligemment (œufs, gousses, pièces :
  à l'unité supérieure ; g : à 5 g près ; ml : à 10 ml près).
- Les ingrédients `placard: true` et les unités `cas` / `cac` / `pincee` / `au_gout` sont regroupés dans une section
  « À vérifier dans le placard » non cochée par défaut.
- Un référentiel `ingredients-ref.json` (à créer) liste toutes les `cle` avec rayon par défaut, allergènes par défaut et
  saisons : il sert de source de vérité et le script de validation vérifie la cohérence recette ↔ référentiel.

### 3.3 Étape

```jsonc
{
  "ordre": 1,
  "texte": "Faire revenir l'oignon 3 min dans l'huile d'olive.",  // une action principale par étape, verbe à l'infinitif
  "duree_min": 3,                 // optionnel : alimente un minuteur dans l'app
  "minuteur": true                // optionnel : propose un bouton minuteur
}
```

### 3.4 Règles de validation (script CI à écrire)

- `id` unique, kebab-case ; `titre` ≤ 60 caractères ; `description` ≤ 200 caractères.
- `temps.total_min == preparation_min + cuisson_min` ; `tags.temps` cohérent.
- `allergenes` == union des `ingredients[].allergenes`.
- `regimes` cohérents avec ingrédients (cf. §2.4) ; `sans_cuisson` ⇔ `cuisson_min == 0` ; `congelable` ⇔ `congelation`.
- Toute `unite` et tout `rayon` appartiennent aux listes fermées ; `quantite == null` ⇔ `unite == "au_gout"`.
- Pas plus de 10 ingrédients non `placard`.
- Vocabulaire interdit dans les textes (liste à maintenir) : « minceur », « brûle-graisse », « détox », « sans
  culpabilité », « triche », « guérir », « soigner », « calories ».

---

## 4. Plan type d'une semaine de repas

Exemple de semaine d'**automne–hiver** construite avec les 12 recettes du seed, pour 2 personnes, avec une session de
**batch cooking le dimanche (≈ 1 h 15)**. C'est un exemple d'organisation, pas un programme à suivre : l'app proposera
de l'adapter librement (glisser-déposer, « je mange dehors », restes).

### 4.1 Batch cooking du dimanche

| Ordre | Tâche | Sert pour |
|---|---|---|
| 1 | Lancer le dahl (×1, 4 portions) | dîner lundi + déjeuner mardi |
| 2 | Cuire 300 g de quinoa et 250 g de lentilles vertes (sèches) | bowl quinoa lundi/jeudi, salade lentilles mercredi |
| 3 | Rôtir les pois chiches croustillants (four) | collations + topping des bowls |
| 4 | Mixer le houmous de betterave | collations lun–jeu |
| 5 | Préparer la sauce tahini-citron et la vinaigrette moutarde (bocaux) | bowls et salades |
| 6 | Former les bouchées cacao-amandes | collations de la semaine (congeler la moitié) |
| 7 | Laver/couper crudités (carottes, concombre) en boîtes | collations, salades |

### 4.2 La semaine

| Jour | Petit-déjeuner | Déjeuner | Collation (si faim) | Dîner |
|---|---|---|---|---|
| **Lundi** | Overnight oats pomme-cannelle (préparés dim. soir) | Bowl quinoa, pois chiches rôtis, sauce tahini | Houmous de betterave + crudités | Dahl corail-butternut + riz complet |
| **Mardi** | Œufs brouillés épinards-feta sur seigle | **Reste** de dahl (lunchbox) | Pomme + 1 poignée de pois chiches croustillants | Saumon, poireaux fondants et haricots blancs |
| **Mercredi** | Pudding chia coco-framboises (préparé mardi soir) | Salade tiède lentilles, betterave, chèvre, noix | Bouchées cacao-amandes (2) + un yaourt | Plaque poulet, chou-fleur, pois chiches, sauce yaourt |
| **Jeudi** | Overnight oats pomme-cannelle | **Reste** de plaque poulet (froid en salade) | Houmous de betterave + crudités | Bowl quinoa, pois chiches, sauce tahini (variante légumes rôtis) |
| **Vendredi** | Œufs brouillés épinards-feta sur seigle | Boulgour, maquereau et légumes, sauce yaourt-aneth | Fromage blanc + poire | Repas libre / restaurant / plat plaisir |
| **Samedi** | Brunch : œufs + pain au levain + fruits | Salade tiède lentilles (variante sans chèvre, avec œuf mollet) | Bouchées cacao-amandes | Soupe maison + tartines (hors seed) |
| **Dimanche** | Pudding chia coco-framboises | Repas en famille | — | Restes / batch cooking de la semaine suivante |

### 4.3 Ce que cette semaine illustre

- **Poisson gras 2 fois** (saumon, maquereau) ; **légumineuses 6 à 7 fois** (dahl, pois chiches, lentilles, haricots
  blancs, houmous).
- **Petits-déjeuners protéinés** en rotation de 3 recettes, dont 2 préparables la veille.
- **Restes planifiés** : 2 déjeuners sur 5 sont des restes du dîner → moins de cuisine en semaine.
- **Collations facultatives** (« si faim ») : elles ne sont jamais imposées ; elles associent toujours un glucide à
  une protéine ou un gras.
- **Un repas libre** assumé, sans vocabulaire de « triche ».
- Liste de courses générée automatiquement par agrégation des `ingredients[].cle` des recettes planifiées, mise à
  l'échelle sur le nombre de portions réel et regroupée par `rayon`.
