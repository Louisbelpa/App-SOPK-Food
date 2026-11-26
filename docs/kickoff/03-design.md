# 03 — Design UX/UI (kickoff)

> Rôle : Designer UX/UI. Point de départ : `00-brief.md`. On repart de zéro, la V0 n'est pas une référence visuelle.
> L'app **informe et accompagne**, elle ne diagnostique pas. Tout le design en découle.

---

## 1. Personas

### P1 — Léa, 29 ans, « la fatigue d'abord » (phénotype insulinorésistant)
- Cheffe de projet, diagnostiquée il y a 2 ans. Cycles de 35 à 60 jours, fringales sucrées, coups de barre à 15 h, prise de poids qu'elle vit mal. Métformine envisagée par son médecin.
- **Jobs-to-be-done**
  - « Quand je rentre crevée à 19 h, je veux une recette IG bas prête en 25 min avec ce que j'ai, pour ne pas craquer sur des pâtes blanches. »
  - « Quand j'ai un pic de fatigue, je veux comprendre si c'est lié à ce que j'ai mangé ou à mon cycle. »
- **Frustrations** : apps de régime qui comptent les calories et la font culpabiliser ; apps de cycle qui « prédisent » des règles qui n'arrivent jamais et affichent « retard » en rouge ; conseils génériques « mangez équilibré ».

### P2 — Inès, 34 ans, « on essaie d'avoir un bébé » (phénotype ovulatoire / désir de grossesse)
- Infirmière en horaires décalés, en parcours PMA débutant (stimulation). IMC « normal » : on lui a longtemps dit qu'elle « n'avait pas le profil SOPK ».
- **Jobs-to-be-done**
  - « Quand j'ai rendez-vous chez la gynéco, je veux un résumé clair de mes 3 derniers cycles et symptômes, pour ne pas tout oublier. »
  - « Je veux une activité physique qui m'aide sans m'épuiser après une garde de nuit. »
- **Frustrations** : apps fertilité centrées « fenêtre de fertilité » et compte à rebours, anxiogènes quand ça ne marche pas ; notifications « C'est le moment ! » ; univers rose-bébé qui fait mal certains jours. Elle veut pouvoir **masquer** tout le contenu fertilité quand elle n'en peut plus.

### P3 — Camille, 22 ans, « mon corps me gêne » (phénotype hyperandrogénique + anxiété)
- Étudiante, acné, hirsutisme, chute de cheveux. Pilule prescrite, qu'elle questionne. Anxiété sociale, rapport compliqué à l'alimentation (antécédent de restriction).
- **Jobs-to-be-done**
  - « Je veux noter rapidement mes symptômes de peau et d'humeur pour voir si ça bouge quand je change mon alimentation. »
  - « Je veux des infos fiables et sourcées sans tomber sur des forums qui me font peur. »
- **Frustrations** : vocabulaire stigmatisant (« pilosité excessive », « surpoids ») ; apps qui proposent un objectif de perte de poids dès l'onboarding (dangereux pour elle) ; trop de champs à remplir, elle abandonne au bout d'une semaine.

**Point commun** : fatigue décisionnelle, besoin de se sentir **comprise sans être jugée**, et données ultra-sensibles (fertilité, poids, contraception).

---

## 2. Principes UX

| # | Principe | Règle concrète (testable) |
|---|----------|---------------------------|
| 1 | **Bienveillance, zéro culpabilisation** | Aucun rouge/score « mauvais » sur une donnée corporelle. Pas de streaks punitifs (on ne « perd » rien si on saute un jour). Jamais de « vous auriez dû ». |
| 2 | **Pas de poids ni de calories par défaut** | Poids, IMC, calories : **désactivés**, activables dans Réglages > Suivis optionnels, avec avertissement doux. Les recettes affichent IG/charge glycémique qualitative (« IG bas ») et satiété, jamais de kcal par défaut. |
| 3 | **Charge cognitive adaptée à l'énergie** | Le check-in demande d'abord « Comment ça va ? » (3 niveaux). Si « difficile » → mode **Doux** : 1 seule suggestion par écran (recette ≤ 15 min, séance ≤ 10 min, respiration), texte réduit, pas de nouvelles infos. |
| 4 | **Saisie < 10 s** | Check-in minimal = 2 taps (humeur + énergie) + « Valider ». Le reste est optionnel, en chips pré-remplies avec les symptômes les plus fréquents de l'utilisatrice. Widget + Raccourci Siri pour noter les règles en 1 tap. |
| 5 | **Pas de fausses prédictions** | Cycles irréguliers = normaux ici. On affiche « jour 23 du cycle » et des **fourchettes** (« règles possibles entre le 4 et le 18 déc. ») uniquement après 3 cycles saisis. Jamais « en retard ». |
| 6 | **Vocabulaire choisi** | Voir lexique ci-dessous. Toute mention fertilité est **masquable** (Réglages > Mes objectifs). |
| 7 | **Confidentialité visible** | Données en local par défaut, badge « Stocké sur cet iPhone » dans les réglages, Face ID optionnel à l'ouverture, aucune donnée sensible dans les notifications (« Petit check-in ? » et non « Vos règles arrivent »). |
| 8 | **Informer, pas diagnostiquer** | Toute info santé porte une source et un lien « En parler à mon médecin ». Les tendances disent « on observe », jamais « vous avez ». |

**Lexique (à appliquer partout)**

| Éviter | Utiliser |
|--------|----------|
| Pilosité excessive / hirsutisme (UI) | Poils (visage, corps) |
| Surpoids, perdre du poids | (rien par défaut) / « Mon poids » si suivi activé |
| Infertilité, échec | Projet bébé, essai en cours |
| Retard de règles | Cycle en cours (jour X) |
| Craquage, écart, tricher | (aucun jugement) « Repas noté » |
| Patiente, maladie | Toi / tu (tutoiement), « le SOPK » |
| « Il faut » | « Tu peux essayer », « Une idée » |

---

## 3. Architecture d'information

### Tab bar (4 onglets + action centrale)

| Onglet | SF Symbol | Contenu |
|--------|-----------|---------|
| **Aujourd'hui** | `sun.horizon` | Check-in, phase/jour du cycle, 1 recette + 1 mouvement suggérés, conseil du jour |
| **Cuisine** | `fork.knife` | Recettes (filtres IG bas, temps, phase, allergies), favoris, planning semaine, liste de courses |
| **Bouger** | `figure.walk` | Séances courtes filtrées par énergie (doux / modéré / tonique), historique simple |
| **Mon cycle** | `circle.dotted.circle` | Calendrier, symptômes, tendances, export PDF médecin |

- **Profil/Réglages** : avatar en haut à droite de « Aujourd'hui » (pas un onglet).
- **Check-in** : bouton principal sur « Aujourd'hui » + widget + Raccourci. Pas de bouton « + » flottant (non HIG).

### Parcours clés

1. **Onboarding (≤ 6 écrans, tout est passable)**
   Bienvenue + promesse → Disclaimer non médical (1 écran, bouton « J'ai compris ») → « Qu'est-ce qui t'aiderait le plus ? » (multi-choix : énergie, cycle, peau, humeur, projet bébé, digestion) → Date des dernières règles (option « Je ne sais pas / pas de règles en ce moment ») → Allergies/régimes (chips) → Confidentialité (local, Face ID optionnel) + autorisation notifications **demandée plus tard**, au 3ᵉ check-in.
   *Pas de question sur le poids.*
2. **Check-in quotidien (< 10 s)**
   Aujourd'hui → « Comment ça va ? » (3 visages) → Énergie (3 niveaux) → [optionnel] symptômes en chips, règles (oui/spotting/non), note → Valider → message bienveillant + suggestion adaptée.
3. **Trouver une recette**
   Cuisine → suggestions « Pour toi aujourd'hui » (phase + énergie) → filtres en chips (≤ 20 min, IG bas, sans lactose…) → fiche recette → « Ajouter au planning » / « Ajouter aux courses ».
4. **Faire une séance**
   Bouger → « J'ai combien d'énergie ? » (pré-rempli par le check-in) → 3 séances proposées (durée, intensité) → lecteur pas-à-pas (minuteur, consignes texte + audio VoiceOver-friendly) → fin : « Bravo d'avoir pris ce temps » (pas de calories brûlées).
5. **Voir ses tendances**
   Mon cycle → Tendances → période (3 cycles / 3 mois) → graphiques simples (fréquence des symptômes par phase, énergie moyenne) → « Exporter pour mon médecin » (PDF, partage via feuille iOS).

---

## 4. Direction artistique

### Intention
Calme, chaleureux, « cuisine de saison » plutôt que « clinique » ou « rose fertilité ». Vert sauge + terracotta sur fond crème. Beaucoup d'air, coins arrondis (continuous, 16 pt cartes / 12 pt boutons).

### Palette — tokens (contrastes calculés, formule WCAG 2.x)

**Light**

| Token | Hex | Usage | Contraste sur `bg` / `surface` / `surfaceAlt` |
|-------|-----|-------|------|
| `bg` | `#FBF8F3` | Fond d'écran | — |
| `surface` | `#FFFFFF` | Cartes | — |
| `surfaceAlt` | `#F2EDE4` | Chips, champs | — |
| `textPrimary` | `#1F2A24` | Texte | 14.0 / 14.8 / 12.7 ✅ AAA |
| `textSecondary` | `#545E58` | Légendes | 6.4 / 6.7 / 5.8 ✅ AA |
| `primary` | `#3D6A53` | Boutons, liens, sélection | 5.9 / 6.2 / 5.3 ✅ AA |
| `onPrimary` | `#FFFFFF` | Texte sur `primary` | 6.2 ✅ AA |
| `accent` | `#A94E2C` | Mise en avant ponctuelle | 5.2 / 5.5 / 4.7 ✅ AA |
| `onAccent` | `#FFFFFF` | Texte sur `accent` | 5.5 ✅ AA |
| `border` | `#8C8478` | Contours de champs/contrôles | 3.5 / 3.7 / 3.2 ✅ (≥ 3:1 non-texte) |
| `danger` | `#B3261E` | Erreurs techniques uniquement (jamais données corporelles) | 6.2 / 6.5 / 5.6 ✅ AA |
| `phaseMenstrual` | `#A3413D` | Phase menstruelle | 5.9 / 6.2 / 5.3 ✅ |
| `phaseFollicular` | `#2C6475` | Phase folliculaire | 6.2 / — / 5.7 ✅ |
| `phaseOvulatory` | `#7E621B` | Phase ovulatoire | 5.4 / 5.8 / 4.9 ✅ |
| `phaseLuteal` | `#6B4C94` | Phase lutéale | 6.4 / 6.8 / 5.8 ✅ |

**Dark**

| Token | Hex | Contraste sur `bg` / `surface` / `surfaceAlt` |
|-------|-----|------|
| `bg` | `#121613` | — |
| `surface` | `#1B211D` | — |
| `surfaceAlt` | `#252D28` | — |
| `textPrimary` | `#F1EEE8` | 15.8 / 14.2 / 12.2 ✅ AAA |
| `textSecondary` | `#B4BBB5` | 9.3 / 8.4 / 7.2 ✅ AAA |
| `primary` | `#8FC4A6` | 9.2 / 8.3 / 7.2 ✅ |
| `onPrimary` | `#0F2419` | 8.2 sur `primary` ✅ |
| `accent` | `#EE9D7B` | 8.5 / 7.6 / 6.6 ✅ |
| `onAccent` | `#2B1206` | 8.2 sur `accent` ✅ |
| `border` | `#7A837D` | 4.7 / 4.2 / 3.6 ✅ |
| `danger` | `#FFB4AB` | 10.8 / 9.7 / 8.3 ✅ |
| `phaseMenstrual` | `#F09A92` | 8.5 / 7.6 / 6.6 ✅ |
| `phaseFollicular` | `#8CC5D6` | 9.6 / — / 7.5 ✅ |
| `phaseOvulatory` | `#E3C26E` | 10.6 / 9.5 / 8.2 ✅ |
| `phaseLuteal` | `#C3A8EB` | 8.8 / 7.9 / 6.8 ✅ |

Règles : couleurs déclarées dans l'Asset Catalog (Any/Dark + variante *High Contrast*) ; les phases ne sont **jamais** portées par la seule couleur (toujours libellé + icône) ; respecter le mode Augmenter le contraste.

### Typographie
- **Corps / UI** : SF Pro (système), **uniquement via Dynamic Type** (`.body`, `.headline`, `.caption`…), jamais de tailles fixes.
- **Titres éditoriaux** (titres d'écran large, nom de recette, message du jour) : **New York** (serif système Apple, `.fontDesign(.serif)`) → chaleur sans police à embarquer ni licence.
- Chiffres (minuteurs, jour du cycle) : `.monospacedDigit()`.

### Iconographie
- SF Symbols exclusivement, rendu *hierarchical* teinté `primary`, poids aligné sur le texte.
- Exemples : `drop` (règles), `bolt.heart` (énergie), `face.smiling` (humeur), `leaf` (IG bas), `timer` (durée), `figure.yoga` / `figure.walk` / `figure.strengthtraining.functional`, `lock.shield` (confidentialité), `doc.text` (export médecin).
- Illustrations : formes organiques simples (feuilles, galets) en aplats, pas de corps féminins stéréotypés.

### Ton éditorial
Tutoiement, phrases courtes, chaleureux mais pas mièvre, jamais d'injonction. Exemples :

| Contexte | Micro-copy |
|----------|-----------|
| Accueil matin | « Bonjour Léa. On prend 10 secondes pour toi ? » |
| Check-in « difficile » | « Merci de l'avoir noté. Aujourd'hui, on fait simple. » |
| Jour sans check-in | (rien, aucun rappel culpabilisant) / au retour : « Contente de te revoir. » |
| Cycle long | « Jour 47. Les cycles longs sont fréquents avec le SOPK. Tu peux en parler à ton médecin si ça t'inquiète. » |
| Fin de séance | « 8 minutes rien que pour toi. C'est noté. » |
| Recette | « Prête en 20 min · IG bas · rassasiante » |
| Tendance | « On observe plus de fatigue en fin de cycle sur tes 3 derniers cycles. » |
| Erreur réseau | « Pas de connexion. Tes données restent sur ton iPhone, rien n'est perdu. » |
| Disclaimer | « Cette app t'accompagne au quotidien. Elle ne remplace pas l'avis de ton médecin. » |

### Nom d'app — 5 propositions
1. **Ovéa** — doux, évoque l'ovaire sans le dire, prononçable partout.
2. **Saison** — cycle, alimentation de saison, rythme ; très français.
3. **Équilibre** (ou **Équi**) — promesse claire, non médicale.
4. **Sauge** — la plante, la couleur de l'app, la sagesse ; mémorable.
5. **Myrtille** — fruit IG bas emblématique, ludique, non stigmatisant.

> Recommandation : **Saison** ou **Sauge** (vérifier disponibilité App Store + INPI).

---

## 5. Wireframes textuels (MVP)

### É1 — Aujourd'hui
```
┌──────────────────────────────────────┐
│ jeu. 26 nov.                    (👤) │  ← avatar = Profil/Réglages
│ Bonjour Léa                          │  ← New York, Large Title
│                                      │
│ ┌──────────────────────────────────┐ │
│ │ ◌ Jour 23 · Phase lutéale         │ │  ← libellé + icône + couleur phase
│ │ Énergie souvent plus basse ici.  │ │
│ └──────────────────────────────────┘ │
│ ┌──────────────────────────────────┐ │
│ │ Comment ça va aujourd'hui ?       │ │
│ │ [ 😌 Bien ] [ 😐 Bof ] [ 😣 Dur ]  │ │  ← 1 tap ouvre le check-in pré-rempli
│ └──────────────────────────────────┘ │
│ Pour toi aujourd'hui                 │
│ ┌───────────────┐ ┌────────────────┐ │
│ │ [photo]       │ │ figure.yoga    │ │
│ │ Dahl lentilles│ │ Étirements     │ │
│ │ 20 min · IG ↓ │ │ 10 min · doux  │ │
│ └───────────────┘ └────────────────┘ │
│ 💡 Le bon réflexe : protéines au      │
│    petit-déj pour lisser l'énergie.  │
│    Source ›                          │
├──────────────────────────────────────┤
│ Aujourd'hui  Cuisine  Bouger  Cycle  │
└──────────────────────────────────────┘
```
Mode Doux (check-in « Dur ») : la carte phase et le conseil disparaissent, une seule suggestion pleine largeur + « Respirer 2 min ».

### É2 — Check-in (sheet, detents medium/large)
```
┌──────────────────────────────────────┐
│ ───                          Fermer  │
│ Humeur      ( 😌 ) ( 😐 ) ( 😣 )       │
│ Énergie     ( ▁ ) ( ▃ ) ( ▅ )        │
│ ───────── optionnel ─────────        │
│ Règles      [Non] [Spotting] [Oui]   │
│ Symptômes   [Ballonnements] [Peau]   │  ← chips triées par fréquence perso
│             [Fringales] [Douleurs]   │
│             [+ Autre]                │
│ Note        [ Écrire…              ] │
│                                      │
│ [        Valider (primary)         ] │  ← actif dès humeur + énergie
└──────────────────────────────────────┘
```
Après validation : toast « Merci, c'est noté. » + haptique légère, retour à Aujourd'hui avec suggestions mises à jour.

### É3 — Cuisine (liste) → fiche recette
```
┌──────────────────────────────────────┐
│ Cuisine                         [♡]  │
│ [🔍 Rechercher une recette        ]  │
│ [≤20 min] [IG bas] [Sans lactose] ›  │  ← chips filtres, scroll horizontal
│ Recettes · Planning · Courses        │  ← segmented control
│ ┌──────────────────────────────────┐ │
│ │ [photo 16:9]                     │ │
│ │ Bowl quinoa, saumon, avocat      │ │
│ │ leaf IG bas · timer 25 min · ♡   │ │
│ └──────────────────────────────────┘ │
│ …                                    │
└──────────────────────────────────────┘
Fiche : photo · titre (New York) · badges (IG bas, temps, portions ±)
· « Pourquoi c'est bien pour toi » (2 lignes) · Ingrédients (cochables)
· Étapes numérotées · [Ajouter au planning] [Ajouter aux courses]
```

### É4 — Bouger (choix + lecteur)
```
┌──────────────────────────────────────┐
│ Bouger                               │
│ Ton énergie : ( ▁ Doux ) ▃  ▅         │  ← pré-rempli depuis le check-in
│ ┌──────────────────────────────────┐ │
│ │ figure.yoga  Yoga du soir         │ │
│ │ 10 min · doux · sans matériel    │ │
│ └──────────────────────────────────┘ │
│ ┌──────────────────────────────────┐ │
│ │ figure.walk  Marche après repas   │ │
│ │ 15 min · aide la glycémie         │ │
│ └──────────────────────────────────┘ │
│ ┌──────────────────────────────────┐ │
│ │ figure.strengthtraining  Renfo    │ │
│ │ 12 min · modéré                   │ │
│ └──────────────────────────────────┘ │
└──────────────────────────────────────┘
Lecteur : nom de l'exercice (Title) · minuteur géant (monospacedDigit)
· consigne 1 ligne · [⏸] [Passer ›] · « Arrêter » toujours visible, sans pénalité
```

### É5 — Mon cycle (calendrier + tendances)
```
┌──────────────────────────────────────┐
│ Mon cycle                  [Exporter]│
│ Calendrier · Tendances               │  ← segmented
│      novembre 2026                   │
│  L  M  M  J  V  S  D                 │
│  ●  ●  ●  ·  ·  ·  ·    ● = règles    │  ← drop.fill + couleur
│  ·  ·  ◦  ·  ·  ·  ·    ◦ = symptôme  │
│ Jour 23 · cycle actuel               │
│ Cycles récents : 41 j · 52 j · 38 j  │  ← neutre, aucun « anormal »
│ ─────────── Tendances ───────────    │
│ Fatigue    ▁▂▃▅▆  plus fréquente      │
│            en fin de cycle           │
│ Peau       ▂▂▃▃▂                      │
│ « On observe… » · En parler au médecin › │
└──────────────────────────────────────┘
Exporter → PDF (3 derniers cycles, symptômes, notes) via feuille de partage iOS.
```

---

## 6. Accessibilité & Human Interface Guidelines

**Accessibilité (cible WCAG 2.2 AA)**
- Contrastes : tous les tokens texte ≥ 4.5:1, non-texte ≥ 3:1 (tableaux §4). Variantes High Contrast dans l'Asset Catalog.
- **Dynamic Type** jusqu'à AX5 : layouts qui passent en vertical (`ViewThatFits` / `dynamicTypeSize`), pas de texte tronqué sur les infos clés.
- **VoiceOver** : labels explicites (« Humeur : difficile, bouton »), emojis jamais lus seuls (`accessibilityLabel`), graphiques avec `accessibilityChartDescriptor` (Swift Charts) + résumé textuel.
- Cibles tactiles ≥ 44×44 pt ; chips espacées de ≥ 8 pt.
- Couleur jamais seule porteuse de sens (phases, règles : icône + texte).
- **Réduire les animations** : transitions en fondu, pas de confettis ; **Réduire la transparence** respecté.
- Haptiques légères et désactivables ; pas de son par défaut.
- Langage simple (niveau B1), pas de jargon sans explication (« IG = index glycémique » au premier usage).

**Human Interface Guidelines**
- Navigation : `TabView` (4 onglets), `NavigationStack` avec Large Titles, sheets avec detents pour les saisies rapides, pas de menu hamburger.
- Composants natifs : `Picker(.segmented)`, `DatePicker`, `List`/`Form` pour les réglages, `ShareLink` pour l'export, `ContentUnavailableView` pour les états vides (ex. « Pas encore de tendance. Elles apparaîtront après quelques check-ins. »).
- Light/Dark automatiques, respect des Safe Areas et de la Dynamic Island.
- Intégrations système (post-MVP) : widget check-in (WidgetKit), App Intents / Siri (« Noter mes règles »), HealthKit (lecture/écriture cycle menstruel) **opt-in** et expliqué.
- Permissions demandées **en contexte** (notifications au 3ᵉ check-in, HealthKit à l'activation), avec écran explicatif avant l'alerte système.
- Face ID optionnel (LocalAuthentication) + masquage du contenu dans le sélecteur d'apps.

---

### Checklist de revue design (à chaque écran)
- [ ] Faisable en mode Doux ? (1 action principale, texte court)
- [ ] Aucun poids/calorie/rouge sur données corporelles ?
- [ ] Vocabulaire conforme au lexique ?
- [ ] Testé en Dynamic Type AX3, VoiceOver, Dark, Augmenter le contraste ?
- [ ] Contenu fertilité masquable si présent ?
