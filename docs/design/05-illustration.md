# 05 — Mascotte & illustrations (Ovéa, V3)

> Rôle : direction artistique et illustration. Entrées : `04-benchmark.md` (diagnostic « vibe coding », prime pour la forme), `docs/kickoff/07-synthese-decisions.md` et `04-medical.md` (priment pour le fond), `01-ux.md` (écrans, check-in énergie, mode jour difficile), `03-copy.md` (ton), `02-ui.md` (V2, remplacée ici pour le visuel).
> Choix du porteur pour la V3 : **direction « Mascotte & illustrations »**, **illustrations (pas de photos) pour les recettes**.
> Livrables associés : [`illustrations/`](illustrations/) (SVG + `gen_svg.py`), [`palette.py`](palette.py) → [`tokens.json`](tokens.json), [`DesignSystem.swift`](DesignSystem.swift) (`OveaMascotView`), [`maquettes.html`](maquettes.html) (9 écrans + variante jour difficile + planches).

---

## 0. En bref

- **Mascotte : Mousse**, un petit galet couvert de mousse. Sa tige porte **1, 2 ou 3 feuilles** selon l'énergie déclarée : c'est **l'élément signature** de l'écran Aujourd'hui.
- **Base iOS native** : grands titres, `List(.insetGrouped)`, tab bar standard, SF Pro. **Une seule carte mise en avant par écran**, jamais teintée.
- **Palette repensée à partir de Mousse** : fin du lin crème + serif + terracotta. Neutres pierre, un seul accent **myrtille**, la chaleur vient des illustrations (courge, paprika, abricot).
- **Typo système uniquement** : SF Pro, et SF Pro Rounded pour les grands titres (rien à embarquer). Fraunces est abandonnée.
- **Plats illustrés** dans un style unique : vue de dessus (3/4 pour les bocaux), même trait, même table lavande grisée.
- Les SVG du dépôt sont des **prototypes de direction**. Le §10 est le brief pour une illustratrice qui fera la version définitive.

---

## 1. Ce que la V3 corrige

| Signe relevé dans `04-benchmark.md` | V2 | V3 |
|---|---|---|
| Crème + serif + terracotta | Lin `#FBF3E7`, Fraunces, accent `#A1482A` | Pierre `#F4F3F1`, SF Pro / SF Pro Rounded, accent myrtille `#3F3895` |
| Tout est une carte à ombre douce | 5 à 6 cartes par écran | Listes groupées natives, **1 carte mise en avant au plus** |
| Blob flou + icône centrée | Toutes les vignettes | **Vraies illustrations de plats** ; séances en tuiles d'icône façon Réglages iOS |
| Surtitres en capitales espacées | « POUR TOI AUJOURD'HUI » | Titres de section en casse de phrase (`title3`) |
| Cartes teintées de toutes les couleurs | Abricot, miel, sauge, prune sur un même écran | Les teintes de catégorie ne colorent plus que le **libellé et l'icône** |
| Doodles décoratifs (tasse, soleil, plaid) | Sans rôle | Supprimés. Le plaid et la tasse n'existent plus que **dans une pose de Mousse** (jour difficile), où ils disent quelque chose |

---

## 2. Trois concepts de mascotte

Contraintes : ni femme ni corps humain (aucune projection sur la silhouette), pas d'utérus ni d'ovaire stylisé, aucun code fertilité ou bébé (œuf, fleur, lune, graine qui germe), aucun animal déjà emblématique (oiseau type Finch ou Duolingo, cœur type Yorhart), pas d'emoji.

| | **A. Mousse** — galet moussu (végétal + minéral) | **B. Tiède** — bouillotte en tricot (objet) | **C. Moka** — marmotte (créature) |
|---|---|---|---|
| Personnalité | Calme, patiente, un peu têtue gentiment. Ne se presse jamais. S'assoit où elle veut. | Réconfortante, discrète, toujours prête à servir. | Gourmande, dormeuse, réveils lents. |
| Lien au sujet, sans être médical | Un galet s'arrondit avec le temps, la mousse pousse lentement et seulement quand les conditions sont bonnes : le **rythme propre**, sans performance. La tige qui porte plus ou moins de feuilles traduit l'énergie du jour sans jugement (une seule feuille, c'est une plante qui se repose, pas qui va mal). Lien direct avec la cuisine de saison et le végétal. | Objet de confort très associé aux règles douloureuses. | « Dormir comme une marmotte » : le repos est valorisé, l'énergie suit les saisons. |
| Risques | Un galet peut rappeler un œuf : il est **toujours plus large que haut** (rapport 1,6 à 1,9), jamais ovoïde vertical. | La rattacher à la douleur à chaque ouverture de l'app ; le thème « règles » devient omniprésent, ce qui contredit la discrétion. | Un animal dodu a un **ventre** : risque de projection sur le corps et le poids. Les marmottes sont aussi déjà très utilisées en illustration. |
| Faisabilité (poses cuisine, mouvement, repos) | Très bonne : de petits bras « capsule » apparaissent seulement quand elle fait quelque chose ; elle se déplace en sautillant. | Moyenne : bouger et cuisiner sont peu crédibles pour une bouillotte. | Très bonne, mais anatomie plus complexe et coûteuse à animer. |

**Choix : A, Mousse.** C'est le seul concept qui (1) ne renvoie ni au corps ni à la douleur, (2) porte en lui-même un indicateur d'énergie lisible et non culpabilisant (les feuilles), (3) relie les trois piliers de l'app : cuisine (végétal, saisons), mouvement (elle sautille), repos (un galet, c'est l'immobilité assumée), et (4) se dessine avec des formes géométriques simples, donc coûte peu à décliner et à animer. Le nom « Mousse » est doux, français, court ; il évoque la nature sans promesse de santé.

---

## 3. Fiche personnage : Mousse

### 3.1 Construction (grille 240 × 240, pas de 8)

| Élément | Règle |
|---|---|
| Silhouette | Galet à **fond plat** posé au sol (y = 200), sommet légèrement décentré vers la droite. Largeur ≈ 176 à 190, hauteur ≈ 86 à 120 : **toujours plus large que haut**. Courbes de Bézier continues, aucun angle. |
| Coussin de mousse | Une seule forme à 4 bosses posée sur le sommet, ≈ 70 × 28. Deux points d'ombre `mousseOmbre`. |
| Tige | Part du centre du coussin. **1 feuille** = énergie basse (tige penchée), **2** = moyenne (tige courbée), **3** = bonne (tige droite). Feuille en amande ≈ 22 × 10. |
| Visage | Centré à mi-hauteur du corps. Yeux : ellipses pleines 9 × 12 avec un reflet ; ou arcs (fermés, contentement). Bouche : un arc court. Joues abricot 18 × 10. Rien d'autre : pas de nez, pas de sourcils. |
| Bras | Petites capsules 16 × 26 à 38, **seulement quand elle agit** (saluer, cuisiner, s'étirer). Pas de jambes, pas de mains détaillées. |
| Matière | Corps `galet`, croissant d'ombre bas-droite `galetOmbre`, trois mouchetures. Aucune texture bruitée. |
| Proportions à l'écran | Héros 150–200 pt · intégrée à une ligne 72–90 pt · état vide 120 pt. **Jamais sous 64 pt** (le trait passe sous 1 pt). |

### 3.2 Expressions

| Expression | Yeux | Bouche | Usage |
|---|---|---|---|
| Neutre attentive | Ouverts | Arc doux | Énergie moyenne, état vide |
| Contente | Ouverts + reflet | Sourire | Accueil, bonne énergie, cuisine |
| Paisible | Fermés (arc vers le bas) | Petit arc | Énergie basse, repos, jour difficile |
| Contentement | Plissés (arc vers le haut) | Sourire | Célébration douce |
| Effort léger | Plissés | Petit « o » | Mouvement |

**Pas d'expression triste, inquiète, déçue ni surexcitée.** Une énergie basse se dessine comme du repos, jamais comme de la tristesse.

### 3.3 Poses livrées en prototype

| Fichier | Pose | Où |
|---|---|---|
| `mousse-accueil.svg` | Salue d'un bras levé | Onboarding, Aujourd'hui avant le check-in |
| `mousse-energie-basse.svg` | Plus basse, yeux fermés, 1 feuille | Aujourd'hui et check-in, après « Basse » |
| `mousse-energie-moyenne.svg` | 2 feuilles, yeux ouverts | Après « Moyenne » |
| `mousse-energie-bonne.svg` | Plus haute, 3 feuilles, sourire | Après « Bonne » |
| `mousse-jour-difficile.svg` | Sous un plaid moutarde, tasse fumante | `TODAY-GENTLE` |
| `mousse-cuisine.svg` | Cuillère en bois dans une cocotte | Mode cuisine : fin « Bon appétit » |
| `mousse-mouvement.svg` | Petit saut, bras levés | Fin de séance |
| `mousse-repos.svg` | Endormie sur un coussin | Bouger : « Le repos aussi », « Repos noté » |
| `mousse-etat-vide.svg` | À côté d'un bol vide | Pas encore de favoris, aucun résultat |
| `mousse-celebration.svg` | Nouvelle feuille plus claire, yeux plissés | Après une séance ou une recette terminée, 1×/jour max |

### 3.4 Ce que Mousse ne fait jamais

- **Elle ne parle pas.** Pas de bulle, pas de « je ». La voix de l'app reste « on » (`03-copy.md` §2) ; Mousse illustre, elle ne commente pas.
- Elle ne commente jamais **le corps, le poids, l'alimentation** (« bravo, tu as bien mangé ») **ni les règles** ; elle n'apparaît jamais à côté d'une donnée de cycle.
- Pas de **streak**, de trophée, de flamme, de confettis, de saut de joie. Pas de déception si on ne vient pas.
- Pas de **vêtement genré**, de maquillage, de nœud, de rose bonbon. Pas de fleur, d'œuf, de lune, de cœur.
- Elle n'est jamais **utilisée pour pousser à agir** (« Mousse t'attend ! » en notification) : elle n'apparaît pas dans les notifications.
- Elle ne change jamais de forme de corps (plus « mince » ou plus « ronde ») selon un résultat : seules la tige, les yeux et la posture varient.

---

## 4. Système d'illustration

| Paramètre | Règle |
|---|---|
| Grille | viewBox **240 × 240** pour tout (mascotte et plats), pas de 8. Marge de sécurité 16. |
| Trait | **Un seul trait : 4 u, couleur `encre` `#2A2438`, bouts et angles ronds.** Il entoure les objets principaux (contenants, protéines, gros légumes, Mousse). Les sauces et filets peuvent utiliser la même épaisseur dans une autre couleur (ex. lait de coco en `porcelaine`). |
| Petits éléments | Graines, herbes, dés, épices : **aplats sans contour**. C'est ce qui évite l'effet « clipart » chargé. |
| Palette | 8 teintes, chacune avec au plus une ombre (§8.3). Couleurs **fixes**, identiques en clair et en sombre, comme une photo. |
| Ombres | Une ombre **à plat**, sans flou : décalée de (5, 7) en `tableOmbre` sous les contenants, ellipse `encre` à 12 % sous Mousse. Sur les volumes, un seul croissant d'ombre d'un ton plus foncé. |
| Lumière | Venue d'en haut à gauche. Un reflet `porcelaine` au plus par objet rond. |
| Textures | Aucune texture bruitée ni grain (la V2 en abusait). La matière vient de 2–3 mouchetures ou veinages en aplat. |
| Interdits techniques | Pas de filtre, de dégradé, de `clipPath`, de masque ni de texte dans les SVG (compatibilité Asset Catalog et poids). |
| Niveau de détail | Lisible à **60 pt** (vignette de liste) : un plat = 1 contenant + 3 à 5 ingrédients reconnaissables + au plus 1 accessoire. |
| Cadrages | Mascotte : en pied, centrée, posée au sol, fond transparent. Plats : carré plein cadre sur la table, contenant principal légèrement décentré, recadrable en 16:9 (bandeau) sans perdre le plat. |
| Poids | ≤ 6 Ko par SVG (prototypes : 2,5 à 6 Ko). |

---

## 5. Illustrations de plats (12 recettes)

**Règles communes.** Vue de dessus à 90° pour les assiettes, bols et planches ; **trois quarts face** pour les bocaux et verrines (vus de dessus, ils seraient illisibles). Fond = table `table` `#E5E3EF` (lavande grisée, complémentaire des plats chauds : les oranges ressortent sans saturer). Contenants en `porcelaine` ou planche en `bois`. **Portion réaliste et généreuse, jamais d'assiette vide ou « minceur »**, pas de mesure, pas de chiffre. Le nom de fichier est **l'identifiant de la recette** (`recipes.json`), ce qui permet `Image(recipe.id)` sans table de correspondance. Le texte `image.alt` du JSON sert de description VoiceOver.

| Recette (`id`) | Vue | Composition | Accessoire | Prototype |
|---|---|---|---|---|
| `petit-dejeuner-overnight-oats-pomme-cannelle-noix` | 3/4 | Bocal : flocons crème, couche de pomme en dés, noix et cannelle sur le dessus | Une pomme | oui |
| `petit-dejeuner-oeufs-brouilles-epinards-feta-seigle` | dessus | Tartine de seigle sur assiette, œufs brouillés jaunes, épinards, feta en dés | — | à faire |
| `petit-dejeuner-pudding-chia-coco-framboises` | 3/4 | Deux verrines, pudding blanc, framboises, amandes effilées | — | à faire |
| `dejeuner-salade-tiede-lentilles-betterave-chevre-noix` | dessus | Assiette : lentilles, dés de betterave, mâche, chèvre, noix | — | à faire |
| `dejeuner-bowl-quinoa-pois-chiches-cumin-tahini` | dessus | Bol en 4 zones : quinoa, chou rouge, carottes, pois chiches ; filet de tahini | — | oui |
| `dejeuner-boulgour-maquereau-fenouil-yaourt-aneth` | dessus | Assiette : boulgour, morceaux de maquereau, fenouil émincé, sauce yaourt-aneth | Quartier de citron | à faire |
| `diner-dahl-lentilles-corail-butternut` | dessus | Grand bol de dahl orangé, dés de butternut, spirale de coco, coriandre | Petit bol de riz | oui |
| `diner-saumon-poireaux-fondants-ecrase-haricots-blancs` | dessus | Assiette : pavé de saumon sur poireaux, écrasé de haricots, thym | Quartier de citron | oui |
| `diner-plaque-poulet-chou-fleur-pois-chiches-paprika` | dessus | Plaque de four : poulet doré, chou-fleur, pois chiches, oignons rouges | Bol de yaourt | à faire |
| `collation-houmous-betterave-crudites` | dessus | Bol de houmous rose, filet d'huile ; carottes et endives sur planche | Planche | oui |
| `collation-pois-chiches-croustillants-paprika` | dessus | Petit bol de pois chiches dorés, paprika | — | à faire |
| `collation-bouchees-cacao-amandes-sans-cuisson` | dessus | Boules cacao et coco sur planche, quelques amandes | Planche | oui |

En sombre, les illustrations gardent leur table claire (elles se lisent comme des photos). L'illustratrice livrera en option une variante `-dark` avec la table `#2A2838` pour les grands bandeaux (fiche recette), si le contraste paraît trop fort en usage réel.

---

## 6. Règles d'usage de la mascotte

| Écran | Mousse ? | Taille | Pose |
|---|---|---|---|
| Onboarding ONB-01 Bienvenue, ONB-06 C'est prêt | Oui | 190 pt | accueil, celebration |
| ONB-02 Avertissement santé, ONB-03 Données | **Non** | — | Texte sobre, à lire en entier |
| Aujourd'hui (TODAY-01) | **Oui : élément signature** | 140–150 pt | accueil → état d'énergie après le check-in |
| Aujourd'hui, jour difficile (TODAY-GENTLE) | Oui | 200 pt | jour-difficile |
| Check-in (sheet) | Oui, petite | 72 pt | reflète l'énergie cochée |
| Cuisine liste, fiche recette | Non (les plats illustrés suffisent) | — | — |
| Mode cuisine, fin | Oui | 150 pt | cuisine |
| Bouger liste | Oui, petite, en bas | 84 pt | repos (« Le repos aussi ») |
| Lecteur de séance | **Non** (concentration, consignes de sécurité) | — | — |
| Fin de séance | Oui | 150 pt | mouvement, ou celebration (1×/jour) |
| États vides (favoris, recherche) | Oui | 120 pt | etat-vide |
| **Mon cycle, alerte 90 jours, signaux d'arrêt, « Je ne me sens pas bien », douleur forte (INFO-CONSULT), suppression des données, verrou** | **Jamais** | — | Ton sobre : une mascotte y minimiserait le message |
| Notifications, widgets, icône d'app | Non au MVP | — | L'icône pourra reprendre la tige à 3 feuilles, sans visage, à étudier |

Fréquence : **au plus une Mousse par écran**, et la célébration douce au plus une fois par jour. Si « Réduire les animations » est actif, elle reste fixe.

---

## 7. Animations

| Moment | Animation | Outil | Durée |
|---|---|---|---|
| Présence (Aujourd'hui) | « Respiration » : échelle 1 → 1,015 depuis la base | SwiftUI (`OveaMascotView`) | 2,8 s, boucle |
| Changement d'énergie | Fondu entre deux poses (la tige change de feuilles) | SwiftUI `.transition(.opacity)` | 0,35 s |
| Célébration douce | Une feuille se déplie sur la tige | **Rive** (state machine, un seul fichier, ≈ 30–60 Ko) ou Lottie | 1,2 s, une fois |
| Jour difficile | Vapeur de la tasse qui monte lentement | Rive / Lottie | 3 s, boucle lente |
| Mouvement | Petit saut + ombre qui rétrécit | Rive / Lottie | 0,8 s, une fois |

Recommandation : **SwiftUI seul au MVP** (aucune dépendance, conforme à `07`). Rive ou Lottie demanderaient un SDK tiers : à n'envisager qu'après le MVP, en le justifiant dans un ADR. Les poses fixes suffisent pour que le système fonctionne. Avec « Réduire les animations » : aucune boucle, changement de pose instantané.

---

## 8. Palette V3

### 8.1 Avant / après (clés principales)

| Rôle | V2 clair | **V3 clair** | V2 sombre | **V3 sombre** | Pourquoi |
|---|---|---|---|---|---|
| Fond | `#FBF3E7` lin | **`#F4F3F1` pierre** | `#1C1512` chocolat | **`#121117` nuit myrtille** | Neutre proche des fonds groupés iOS ; la chaleur ne vient plus du fond |
| Carte / cellule | `#FFFAF2` | **`#FFFFFF`** | `#271E1A` | **`#1D1B23`** | Cellules natives ; une seule carte mise en avant |
| Texte | `#2F221B` espresso | **`#1D1B22` encre** | `#F6EBDD` | **`#F3F1F6`** | Même couleur que le trait des illustrations |
| Accent (action) | `#A1482A` terracotta | **`#3F3895` myrtille** | `#F0A27D` | **`#B4AEF6`** | Tiré de l'ombre lilas du galet ; sort du combo crème + terracotta |
| Nature / confidentialité | `#556A2C` sauge dorée | **`#456E1B` mousse** | `#BFD08F` | **`#B3D57A`** | La couleur de la mousse de la mascotte |
| Mise en avant | `#855810` miel | **`#8A5300` courge** (rare) | `#EDC47C` | **`#F2C46B`** | Réservée au petit mot du jour, en texte |
| Règles | `#86345F` prune | **`#A83A62` framboise** | `#E8A5C5` | **`#EFA6C8`** | Plus claire que la myrtille : distinctes en luminance (≈ 1,6:1), pas seulement en teinte (daltonisme) |
| Rayons | 8 → 32, capsules | **6 → 22**, boutons 14 | | | Proches d'iOS ; la rondeur vient de Mousse |
| Ombres | Brunes, partout | **Une seule**, neutre, sur la carte mise en avant ; aucune en sombre | | | |
| Titres | Fraunces (serif) | **SF Pro Rounded** (système) | | | Une seule voix d'affichage, ronde comme Mousse, rien à embarquer |

### 8.2 Contrastes (vérifiés par `python3 palette.py`, échec bloquant)

Tous les couples passent : texte ≥ 4,5:1, éléments d'interface ≥ 3:1, en clair et en sombre. Les plus serrés : `leaf` sur `surfaceMuted` 4,90, `period` sur `periodSoft` 4,95, `miel` sur `surfaceMuted` 4,84, `border` sur `accentSoft` 3,40. Le tableau complet se régénère avec `python3 docs/design/palette.py --md`.

Nouveau contrôle V3 : la **silhouette de Mousse** reste lisible (≥ 3:1, WCAG 1.4.11) sur tous les fonds. En clair, c'est le trait encre qui porte le contraste (13,45:1 sur `background`) ; en sombre, c'est le corps galet (11,46:1). Le script vérifie aussi que le trait encre se détache de chaque aplat d'illustration.

### 8.3 Palette d'illustration (fixe)

| Teinte | Hex | Ombre | Rôle |
|---|---|---|---|
| encre | `#2A2438` | — | Trait, yeux, bouche |
| galet | `#CEC7DB` | `#B2A8C4` | Corps de Mousse |
| mousse | `#8DB34A` | `#6F9736` (+ claire `#C2DB86`) | Coussin, feuilles, herbes |
| abricot | `#F4B49A` | `#E3957A` | Joues, coussin |
| courge | `#F2A23A` | `#DA8228` | Dahl, carottes, plaid |
| paprika | `#D9573B` | — | Cocotte, pomme, épices |
| betterave | `#A63A6B` | claire `#D2709B` | Plats uniquement (jamais sur Mousse : trop proche de la couleur des règles) |
| porcelaine / crème / bois | `#FAF8F5` / `#EFE6D3` / `#CC9563` | bois `#AE7546` | Contenants, féculents, planches |
| table | `#E5E3EF` | `#D2CFE1` | Fond des plats |

---

## 9. Ce qui change dans l'interface (résumé pour `02-ui.md`)

- **Aujourd'hui** : Mousse (150 pt) à côté de « Comment est ton énergie ? », trois options avec un glyphe « tige » (1/2/3 feuilles) au lieu des barres ; « Journée difficile » passe dans la barre du haut ; suggestions en liste groupée avec vignette de plat ; le petit mot du jour devient une ligne de texte, sans carte.
- **Énergie** : glyphe tige `EnergyGlyph`, mono-teinte mousse, sélection en myrtille pleine.
- **Cuisine** : une carte « Pour toi aujourd'hui » avec bandeau illustré ; le reste en liste avec vignettes 60 pt.
- **Bouger** : séances en tuiles d'icône (style Réglages iOS), une carte « Doux pour aujourd'hui ».
- **Mon cycle, Réglages, lecteur** : natifs et sobres, sans mascotte.
- Composants : `OveaCard` (teintée) → `OveaFeatureCard` (jamais teintée) ; `OveaDailyNoteCard`, `OveaPlaid`, `OveaTeaCupDoodle` supprimés ; `oveaOverline()` → `oveaSectionHeader()` ; nouveaux `OveaMascotView(state:)`, `OveaDishThumbnail`, `OveaTintedButtonStyle`.

---

## 10. Brief pour une illustratrice freelance (prêt à envoyer)

> **Projet** : Ovéa, app iOS de bien-être pour les personnes vivant avec un SOPK (syndrome des ovaires polykystiques) : recettes simples, séances courtes, journal personnel. App bienveillante, sans culpabilisation, 100 % locale, **qui n'est pas un dispositif médical**.
>
> **Ce qu'on cherche** : finaliser une mascotte, Mousse (un petit galet couvert de mousse, dont la tige porte 1 à 3 feuilles selon l'énergie du jour), et un système d'illustrations de plats cohérent. Ton : doux, calme, adulte (cible 18 ans et plus), jamais infantilisant. Références d'esprit : Gentler Streak, Headspace, How We Feel, Finch (pour la qualité de la mascotte, pas pour son style).
>
> **Point de départ** : nos prototypes (`docs/design/illustrations/*.svg`) et ce document (§3 fiche personnage, §4 système, §5 plats). Tu peux remettre en cause les proportions, le visage et la palette d'illustration ; **pas** les interdits du §3.4 ni ceux-ci : pas de corps humain, pas de codes fertilité (œuf, fleur, lune, graine qui germe), pas de rose bonbon, pas d'expression triste, pas de texte dans les images.
>
> **Livrables**
> 1. Exploration : 3 pistes de Mousse sur une planche (une proche du prototype, deux plus libres), 1 tour de retours. Puis personnage final : fiche de construction (vues, proportions, palette).
> 2. **12 poses** de Mousse : les 10 du §3.3 + « réveil » (onboarding ONB-06) + « lit un carnet » (état vide de l'historique, hors écran Mon cycle).
> 3. **12 illustrations de plats** (§5), carré 240 u, recadrables en 16:9.
> 4. 1 icône d'app (exploration : la tige à 3 feuilles, sans visage), 2 propositions.
> 5. En option : 3 animations Rive (célébration, vapeur, saut) avec state machine, après le MVP.
>
> **Formats** : pour chaque visuel, **SVG** (aplats + traits, sans filtre ni dégradé ni masque, contours vectorisés, ≤ 8 Ko) **et PDF vectoriel** (pour l'Asset Catalog Xcode, « Preserve Vector Data » coché, rendu unique 1x), fond transparent pour Mousse. Noms de fichiers imposés : `mousse-<etat>.svg` et `<id-de-recette>.svg`. Fichiers sources (Figma, Illustrator ou Affinity) avec calques nommés. Planche récapitulative PNG.
>
> **Contraintes techniques** : lisible à 60 pt et à 200 pt ; trait unique ; palette ≤ 10 teintes ; doit fonctionner sur fond clair `#F4F3F1` **et** sombre `#121117` (silhouette ≥ 3:1 sur les deux).
>
> **Droits** : cession des droits patrimoniaux d'auteur pour l'app, sa fiche App Store, le site et les supports de communication, monde, durée légale, avec mention exhaustive des droits cédés (exigée par l'art. L131-3 du Code de la propriété intellectuelle). Crédit dans l'écran « À propos ».
>
> **Budget indicatif (France, freelance confirmée, HT, cession incluse)**
>
> | Poste | Fourchette |
> |---|---|
> | Recherche et design du personnage (3 pistes, 2 tours) | 1 200 – 2 500 € |
> | 12 poses de la mascotte (120 – 250 € la pose) | 1 400 – 3 000 € |
> | 12 illustrations de plats (100 – 220 € pièce) | 1 200 – 2 600 € |
> | Icône d'app | 400 – 900 € |
> | Option : 3 animations Rive | 900 – 2 400 € |
> | **Total sans option** | **≈ 4 200 – 9 000 €** |
>
> Ordres de grandeur à confirmer par devis : les tarifs varient fortement selon l'expérience et l'étendue de la cession.
>
> **Planning (≈ 7 semaines)** : S1 brief et devis · S2–S3 pistes de personnage puis choix · S4 personnage final + 4 poses clés (énergies, jour difficile) · S5 8 poses restantes · S6 12 plats · S7 icône, livraison des fichiers, intégration testée dans Xcode avec nous. Points d'étape hebdomadaires de 30 min.
>
> **Relecture** : les illustrations de plats seront aussi relues par une diététicienne (portions réalistes, pas d'aliment « interdit » mis en scène).

---

## 11. Limites honnêtes des prototypes

Les SVG du dépôt ont été **générés par script** (`illustrations/gen_svg.py`, régénérables avec `python3 docs/design/illustrations/gen_svg.py docs/design/illustrations`). Ils fixent une direction (formes, trait, palette, poses, cadrages) mais restent des prototypes :

- **Le personnage n'a pas de vraie personnalité graphique** : courbes « parfaites », visage générique de type kawaii, aucune intention dans la ligne. Une illustratrice apporterait un trait qui vit (légères variations, attaques de courbe), un regard plus expressif, des silhouettes de pose vraiment travaillées (poids, équilibre, anticipation).
- **Les poses sont rigides** : le corps ne se déforme presque pas. Une illustratrice ferait « s'écraser » et « s'étirer » le galet, ce qui rend la mascotte attachante et prépare l'animation.
- **Les plats sont schématiques** : appétissants de loin, mais sans gourmandise (brillance d'une sauce, irrégularités naturelles, choix de cadrage plus audacieux). Six plats sur douze seulement sont prototypés.
- **La cohérence a été vérifiée à l'œil sur des captures**, pas testée auprès de l'utilisatrice principale : le ressenti « bienveillant, pas infantilisant » reste à valider (protocole de `01-ux.md` §6).
- **L'intégration Xcode n'est pas testée** : rendu des SVG dans l'Asset Catalog, poids réels, accessibilité VoiceOver de `OveaMascotView` sur appareil. Le code Swift n'a pas été compilé dans cet environnement (pas de toolchain Swift ici).
