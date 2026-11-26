# 03 — Copy & UX writing (Ovéa)

> Rôle : copywriter / UX writer senior, santé et bien-être féminin.
> Sources respectées : `docs/kickoff/07-synthese-decisions.md` (décisions), `04-medical.md` (formulations interdites, disclaimers, signaux d'alerte : **ce document prime en cas de conflit**), `03-design.md` (ton et lexique de départ), `05-cuisine.md`, `06-sport.md`.
> Livrable associé : `docs/design/strings.fr.json` (toutes les micro-copies du MVP, clés stables).
> Les textes de santé (disclaimer, alertes, signaux d'arrêt) reprennent **sans en changer le fond** les formulations de `04-medical.md`. Seule la forme change (tutoiement, nom « Ovéa »). Ils doivent être **relus par le médecin** avant la bêta (voir §10).

---

## 1. Plateforme de marque

### Mission
Aider les personnes qui vivent avec un SOPK à prendre soin d'elles au quotidien (cuisiner, bouger, noter ce qu'elles vivent) sans pression, sans jugement, et sans que leurs données quittent leur iPhone.

### Promesse
**« Un quotidien plus doux avec le SOPK. »**
Des recettes simples, des séances courtes et un journal personnel qui s'adaptent à ton énergie du jour. Tout reste sur ton iPhone.

Ce que la promesse **ne dit pas** (et ne dira jamais) : guérir, traiter, réduire les symptômes, réguler les hormones, prédire, faire maigrir.

### Positionnement
Une app de **bien-être et d'information générale**, hors dispositif médical. Elle accompagne entre deux rendez-vous médicaux, elle ne les remplace pas. Déclaration de destination (à reprendre telle quelle dans l'App Store et les Réglages) :
> « Application de bien-être proposant des recettes, des séances d'activité physique et un journal personnel, à visée d'information générale. N'est pas un dispositif médical. »

### Personnalité en 4 traits

| Trait | C'est | Ce n'est pas |
|---|---|---|
| **Bienveillante** | Accueillir chaque journée telle qu'elle est. Valoriser le repos autant que l'effort. « Merci de l'avoir noté. » | Mièvre, infantilisante, ni dans la fausse positivité (« Tout va bien se passer ! »). Pas de « bravo » pour une restriction. |
| **Honnête** | Dire ce qu'on sait et ce qu'on ne sait pas. Parler d'estimation quand c'en est une. Orienter vers un médecin sans dramatiser. | Promettre, prédire, interpréter des symptômes, vendre une solution miracle. Pas de « cliniquement prouvé ». |
| **Simple** | Phrases courtes, un message par écran, des verbes d'action clairs. Lisible un jour de grande fatigue. | Jargon médical non expliqué, longs paragraphes, listes de règles à suivre. |
| **Discrète** | Respecter l'intimité : rien de sensible sur l'écran verrouillé, données locales, aucune relance insistante. | Bavarde, intrusive, culpabilisante quand on ne vient pas. Pas de compte à rebours, pas de série à « perdre ». |

---

## 2. Tutoiement ou vouvoiement : on tutoie

**Décision : tutoiement partout dans l'app**, y compris dans les messages de santé et les alertes. Le vouvoiement est réservé à la **fiche App Store** (voir §8) et aux documents légaux.

Pourquoi :
1. **Cohérence avec l'existant** : les séances (`06-sport.md`), le questionnaire de sécurité et le lexique de `03-design.md` tutoient déjà. Mélanger les deux dans une même app crée une rupture de ton.
2. **Proximité sans familiarité** : le sujet (règles, poils, humeur) est intime. Le « tu » de l'app ressemble à celui d'une amie qui s'y connaît, pas à celui d'un formulaire administratif. C'est l'usage dominant des apps de bien-être francophones grand public.
3. **Phrases plus courtes** : « Tu peux » au lieu de « Vous pouvez », « ton médecin » au lieu de « votre médecin ». Gain réel à Dynamic Type AX5.
4. **Une cible adulte (18 ans et plus) qui choisit l'app** : pas de relation hiérarchique à respecter.

Garde-fous du tutoiement :
- Le « tu » n'autorise **ni familiarité ni argot** (pas de « t'inquiète », « trop bien », « grave »).
- Les messages de santé restent **sobres** : tutoyer n'est pas minimiser. « Plus de 3 mois sans règles enregistrées : il est recommandé d'en parler à ton médecin. »
- Les textes repris de `04-medical.md`, `05-cuisine.md` et `06-sport.md` écrits au « vous » sont **convertis au « tu »** dans `strings.fr.json`, sans changer le fond.
- La voix de l'app dit **« on »** quand elle parle d'elle-même (« On fait simple aujourd'hui »), jamais « je » (pas de faux personnage) et jamais « nous » (trop institutionnel).

---

## 3. Voix et ton selon les contextes

La **voix** ne change pas (bienveillante, honnête, simple, discrète). Le **ton** s'ajuste.

| Contexte | Ton | Règles | Exemples |
|---|---|---|---|
| **Jour difficile** (check-in « Dur », énergie basse, douleurs) | Très doux, très court | 1 seule proposition. Phrases ≤ 8 mots. Le repos est une option valable, présentée en premier ou à égalité. Aucune info nouvelle, aucun chiffre. | « Merci de l'avoir noté. Aujourd'hui, on fait simple. » · « Le repos compte aussi. » |
| **Réussite** (séance finie, recette cuisinée, check-in) | Chaleureux, sobre | On reconnaît le **temps pris pour soi**, pas la performance. Pas de superlatifs, pas de confettis, pas de comparaison. | « 10 minutes rien que pour toi. C'est noté. » · « Belle assiette. Bon appétit. » |
| **Retour après absence** | Accueillant, neutre | Jamais de décompte des jours manqués ni de « tu nous as manqué ». **« Te revoilà. On reprend en douceur ? »** (et non « Contente de te revoir », accordé et qui parle de l'absence) |
| **Alerte santé** (90 jours, saignement inhabituel, signaux d'arrêt) | Calme, factuel, clair | Constat factuel (« enregistrées ») → recommandation simple → action. Pas de rouge, pas de point d'exclamation, pas de mot anxiogène (« grave », « danger », « anormal »). Les numéros d'urgence sont écrits en entier et cliquables. | « Aucune règle enregistrée depuis 92 jours. Plus de 3 mois sans règles : il est recommandé d'en parler à ton médecin ou à ton gynécologue. » |
| **Urgence** (douleur thoracique, idées noires) | Direct, impératif autorisé | Seul cas où l'impératif est permis. Une phrase, un numéro, un bouton d'appel. | « Arrête la séance. Si la douleur est dans la poitrine ou si tu as du mal à respirer, appelle le 15 ou le 112. » |
| **Erreur technique** | Rassurant, concret | Dire ce qui s'est passé, que les données sont en sécurité, quoi faire. Ne jamais accuser l'utilisatrice. Pas de code d'erreur à l'écran. | « L'export n'a pas abouti. Tes données sont intactes. Réessaie dans un instant. » |
| **État vide** | Invitant, sans pression | Expliquer ce qui apparaîtra ici et comment, en 1 phrase. Un bouton au plus. | « Ton historique apparaîtra ici après tes premières règles notées. » |
| **Confirmation destructive** | Clair, sans dramatiser | Dire exactement ce qui sera perdu et que c'est définitif. Le bouton répète le verbe (« Supprimer »), jamais « OK ». | « Toutes tes données seront effacées de cet iPhone. C'est définitif. » |

---

## 4. Lexique

### 4.1 Mots à bannir et remplacements

| ❌ À bannir | Pourquoi | ✅ À la place |
|---|---|---|
| **retard** (de règles), « en retard », « règles attendues » | Suppose un cycle « dû », anxiogène, faux avec le SOPK | « Jour 47 du cycle », « Cycle en cours » |
| **triche**, tricher, écart, craquage, craquer, « repas plaisir », « sans culpabilité » | Moralise l'alimentation, risque TCA | (rien) · « Repas noté » · « Il n'y a pas d'aliments interdits. » |
| **calories**, kcal, « brûler », brûle-graisse, minceur, maigrir, perte de poids, silhouette, « corps d'été » | Centre sur le poids, interdit par défaut | Rien. On parle de satiété, de fibres, de temps pour soi |
| **normal / anormal** (pour un corps, un cycle, un symptôme) | Juge, crée une norme qui exclut | « fréquent », « courant avec le SOPK », « habituel pour toi », « inhabituel » |
| **lutter contre**, combattre, vaincre, « anti-SOPK » | Langage guerrier contre son propre corps | « vivre avec », « prendre soin de toi » |
| **guérir**, soigner, traiter, inverser, « réguler tes hormones », « équilibre hormonal », détox | Allégation médicale, interdit (04 §4.2) | « mieux vivre avec », « une approche raisonnable » |
| **régime** (SOPK), aliment interdit, « à éviter absolument » | Aucun régime n'est supérieur (04 §2.1) | « alimentation variée », « inspirée des recommandations pour une alimentation équilibrée » |
| **anti-inflammatoire** comme promesse | Terme marketing, pas d'effet démontré | « riche en végétaux, fibres, légumineuses » |
| **ovulation**, fenêtre fertile, jours fertiles, « jours sûrs », **phase** folliculaire / lutéale / ovulatoire, prédiction | Interdit (dispositif médical, 04 §3.3 et §5.2) | « Historique de tes cycles », « estimation indicative » (option) |
| **kystes** | Faux (follicules) | Ne pas en parler dans l'UI |
| **hirsutisme**, pilosité excessive | Stigmatisant | « poils (visage, corps) » |
| **surpoids**, obésité, IMC | Stigmatisant, hors sujet par défaut | (rien) |
| infertilité, stérile, **échec**, raté, manqué | Faux et blessant | « projet bébé » (seulement si l'utilisatrice active l'option) ; sinon on ne commente pas |
| patiente, malade, **souffrir de**, « atteinte de » (dans l'UI) | Réduit la personne à une maladie | « tu », « vivre avec un SOPK » |
| **il faut**, tu dois, obligatoire, n'oublie pas, « tu as oublié » | Injonction, culpabilité | « Tu peux essayer », « Une idée : », « Si tu en as envie » |
| **série**, streak, record, « ne casse pas ta série », « encore X minutes » | Gamification punitive | « 9 jours sur les 14 derniers », « 95 minutes de mouvement cette semaine » |
| parfait, idéal, « le bon poids », « bien manger » | Norme inatteignable | « une idée qui marche bien », « équilibrée » |
| booster, boost, « super-aliment », naturel (comme gage de sécurité) | Marketing vide | Description factuelle |
| « Tu nous as manqué », « Ça fait longtemps ! » | Culpabilise l'absence | « Te revoilà. » |

### 4.2 Mots à utiliser

| Mot / tournure | Usage |
|---|---|
| **le SOPK** | Toujours avec l'article, en majuscules. Jamais « ton SOPK » (possessif qui enferme), sauf dans « avec le SOPK ». À l'écran, utilisé avec parcimonie : l'app sait de quoi elle parle. |
| **règles** | Mot simple, assumé. Pas « menstruations » ni « périodes ». |
| **jour X du cycle**, « cycle en cours » | Constat factuel. |
| **noté**, « c'est noté », « enregistré » | Accusé de réception neutre. |
| **énergie** basse / moyenne / bonne | Échelle du check-in (jamais « faible », qui juge). |
| **doux**, en douceur, tranquille | Intensité basse, sans connotation d'échec. |
| **prendre soin de toi**, du temps pour toi | Valorise l'acte, pas le résultat. |
| **une idée**, tu peux essayer, si tu en as envie | Propositions. |
| **IG bas (estimé)** | Toujours « estimé » dans la fiche. « IG = index glycémique » expliqué au premier usage. |
| **rassasiant·e** → « qui tient au corps » | Satiété, sans chiffre. |
| **en parler à ton médecin** | Orientation, formule unique et répétable. |
| **informations générales** | Rappel du statut non médical. |
| **sur cet iPhone** | Confidentialité. |

### 4.3 Vocabulaire fixe (à ne pas varier)
« Check-in » (pas « bilan », « journal du jour »), « Aujourd'hui », « Cuisine », « Bouger », « Mon cycle », « Réglages », « Mode cuisine », « Mode doux », « Mode sans chiffres », « Petit mot du jour », « Résumé pour mon médecin ».

---

## 5. Écriture inclusive et lisible

### 5.1 Inclusion
- **L'app s'adresse à « toi »**, pas à « une femme ». Le SOPK concerne aussi des personnes qui ne se disent pas femmes : on ne présuppose rien.
- **Formulations épicènes d'abord** : « Bienvenue », « Te revoilà », « On y va ? » plutôt que « Prête ? », « Contente de te revoir ». Règle testable : **aucun adjectif ou participe accordé à l'utilisatrice** dans l'UI. Si impossible, reformuler.
- **Pas de point médian dans l'interface** (VoiceOver le lit mal, lisibilité dégradée en grande taille). Pour les professions : terme épicène quand il existe (« ton médecin », « un ou une gynécologue ») ; sinon tournure neutre (« un professionnel de santé » est accepté comme terme générique, comme dans 04) ou doublet complet (« un diététicien ou une diététicienne »). Le point médian reste toléré dans les docs internes.
- **Tous les corps, tous les IMC, toutes les situations** : pas de corps représentés en texte, pas d'hypothèse sur le couple, la sexualité, le désir d'enfant ou la contraception.
- Le projet bébé, la grossesse et l'allaitement ne sont évoqués **que si l'utilisatrice active l'option** correspondante.

### 5.2 Lisibilité
- **Niveau B1** (CECRL) : vocabulaire courant, une idée par phrase. Tout terme technique est expliqué au premier usage (« IG : index glycémique, la vitesse à laquelle un aliment fait monter le sucre dans le sang »).
- **Longueurs cibles** (vérifiables) :

| Élément | Limite |
|---|---|
| Titre d'écran | ≤ 25 caractères |
| Bouton | ≤ 20 caractères, 1 à 3 mots, verbe à l'infinitif ou impératif doux (« Valider », « Commencer ») |
| Chip / filtre | ≤ 18 caractères |
| Corps de texte | phrases ≤ 20 mots, blocs ≤ 3 phrases |
| Mode doux | phrases ≤ 8 mots |
| État vide | 1 titre + 1 phrase |
| Notification | titre ≤ 30 car., corps ≤ 60 car. |
| Petit mot du jour | ≤ 90 caractères |

- **Voix active**, sujets clairs. Pas de double négation.
- **Chiffres en chiffres** (« 3 mois », « 10 min ») ; unités abrégées avec espace insécable (« 20 min »).
- **Typographie française** : apostrophe typographique ’, guillemets « » avec espaces insécables, espace fine insécable avant ; ! ?, espace insécable avant :, points de suspension en un caractère (…). Le JSON est déjà normalisé.
- **Points d'exclamation** : un au maximum par écran, jamais dans un message de santé ou d'erreur.
- **Emojis** : aucun dans les chaînes. Les visages du check-in sont des illustrations ou SF Symbols avec `accessibilityLabel`.
- **Accessibilité** : chaque élément visuel porteur de sens a un label VoiceOver (clés `*.a11y.*`). Les labels décrivent l'état (« Énergie : basse, sélectionnée ») et non l'apparence (« visage triste »).

### 5.3 Variables
Les chaînes utilisent des variables nommées entre accolades : `{name}`, `{day}`, `{count}`, `{minutes}`, `{date}`. Les pluriels sont des clés `.one` / `.other` (à porter dans un String Catalog Xcode avec variations de pluriel). Si `{name}` est vide, utiliser la variante `*.noName`.

---

## 6. Notifications

Principe : **une notification peut être lue par n'importe qui** (écran verrouillé, montre, voiture, partage d'écran). Personne ne doit pouvoir deviner qu'il s'agit du SOPK, de règles, de santé ou d'un cycle.

Règles testables :
1. **Mots interdits** dans le titre et le corps : SOPK, règles, cycle, ovulation, fertilité, symptôme, douleur, saignement, santé, médecin, traitement, pilule, hormone, poids, humeur, anxiété, ventre, peau, poils, grossesse, bébé. Un script CI peut vérifier les clés `notifications.*`.
2. **Aucune donnée personnelle** : ni prénom, ni chiffre (jours, minutes), ni date, ni contenu d'un check-in.
3. **Aucune alerte santé par notification.** L'alerte 90 jours et les messages « consulte » s'affichent **uniquement dans l'app**, à l'ouverture.
4. **Aucune relance** : un rappel ignoré n'est jamais suivi d'un second (« Tu n'as pas fait ton check-in »). Pas de décompte d'absence.
5. **Opt-in, en contexte** : la permission est demandée au 3ᵉ check-in, après un écran explicatif. Chaque rappel est choisi et horodaté par l'utilisatrice (check-in, idée recette, mouvement). Fréquence maximale : 1 par type et par jour.
6. **Ton** : une question ou une proposition, jamais un ordre. Pas d'emoji, pas de « ! ».
7. **Titre** : vide ou « Ovéa » (le nom de l'app est neutre). Les textes tournent parmi les 10 variantes de `notifications.reminders` pour ne pas lasser.
8. **Aperçu** : réglage recommandé « Masquer l'aperçu » proposé dans Réglages → Rappels (lien vers les réglages iOS).

---

## 7. Disclaimer et mentions santé

- **Première ouverture** (validation active, bouton « J'ai compris », pas de case pré-cochée) : texte de `04-medical.md §4.3` repris intégralement, adapté au tutoiement et au nom de l'app → `onboarding.disclaimer.*`. Tous les éléments sont conservés : bien-être et information générale ; pas de diagnostic ; ne prédit ni ovulation ni fertilité ; ne remplace pas une consultation ; pas de contraception ; consulter en cas de doute ; 15 ou 112 en cas d'urgence.
- **Permanent** : Réglages → À propos et limites (sources, date de dernière relecture, qualité du relecteur).
- **Contextuel** : sous chaque contenu santé, `common.healthFootnote` : « Informations générales, ne remplace pas un avis médical. »
- **Signaux d'alerte** (04 §4.1) : repris dans `cycle.alert.*`, `checkin.safety.*`, `move.player.unwell.*` et la page `settings.whenToConsult.*`. Numéros : 15, 112, 3114 ; ligne TCA FFAB 09 69 325 900 **à vérifier avant publication** (04 §4.1).

---

## 8. App Store

> Vouvoiement sur la fiche App Store (inconnues qui ne connaissent pas encore l'app, usage du store). Catégorie : Santé et forme (secondaire : Cuisine). Aucune allégation thérapeutique (guideline Apple 1.4.1, MDR).

### 8.1 Slogan (5 propositions)
1. **« Un quotidien plus doux avec le SOPK. »** (recommandé : reprend la promesse)
2. « Cuisiner, bouger, noter. À votre rythme. »
3. « Prendre soin de soi, sans pression. »
4. « Le SOPK, au quotidien, en douceur. »
5. « Votre énergie du jour d'abord. »

### 8.2 Sous-titre (≤ 30 caractères)
**« Mieux vivre avec le SOPK »** (24 caractères, formule autorisée par 04 §4.2).
Alternatives : « Cuisine, mouvement et journal » (29) · « Recettes, séances et journal » (28).

### 8.3 Description complète

> **Ovéa vous accompagne au quotidien avec le SOPK : des recettes simples, des séances courtes et un journal personnel, à votre rythme et sans jugement.**
>
> Les jours où tout va bien comme les jours difficiles, Ovéa s'adapte à l'énergie que vous indiquez. Pas de calories, pas de pesée, pas de série à tenir : juste des idées pour prendre soin de vous.
>
> **CUISINER SIMPLEMENT**
> • Des recettes à index glycémique bas (estimé), riches en légumes, en fibres et en légumineuses, inspirées des recommandations pour une alimentation équilibrée.
> • Des filtres par temps de préparation, type de repas, préférences (végétarien, sans lactose, sans gluten) et allergènes.
> • Un mode cuisine pas à pas, avec minuteurs et écran qui reste allumé.
> • Il n'y a pas d'aliments interdits. Les filtres sans gluten et sans lactose sont des préférences, pas une obligation.
>
> **BOUGER À VOTRE FAÇON**
> • Des séances de 10 à 30 minutes à la maison, sans sauts obligatoires et avec une variante plus facile pour chaque exercice.
> • Une proposition selon votre énergie du jour, du yoga doux au renforcement.
> • Les jours de repos comptent aussi : rien ne se « perd » si vous faites une pause.
>
> **NOTER CE QUE VOUS VIVEZ**
> • Un check-in en quelques secondes : humeur, énergie, et si vous le souhaitez règles, sommeil, douleurs et symptômes.
> • Un calendrier et l'historique factuel de vos cycles (durée, cycle le plus court et le plus long), sans prédiction d'ovulation.
> • Un résumé à partager avec votre médecin, pour préparer vos rendez-vous.
>
> **VOS DONNÉES RESTENT CHEZ VOUS**
> • Pas de compte, pas de serveur, pas de publicité, aucun outil de mesure d'audience.
> • Tout est enregistré sur votre iPhone. Verrouillage Face ID en option.
> • Notifications discrètes : rien sur l'écran verrouillé ne laisse deviner leur sujet.
> • Exportez vos données ou supprimez-les entièrement à tout moment.
>
> **IMPORTANT**
> Ovéa est une application de bien-être proposant des recettes, des séances d'activité physique et un journal personnel, à visée d'information générale. Ce n'est pas un dispositif médical. Elle ne pose pas de diagnostic, ne prédit pas l'ovulation ni la fertilité, ne remplace pas une consultation médicale et ne doit pas servir de contraception. En cas de doute ou de symptôme inhabituel, consultez un professionnel de santé. En cas d'urgence, appelez le 15 ou le 112.
>
> Contenus inspirés des recommandations internationales 2023 sur le SOPK. Réservé aux adultes (18 ans et plus).

Texte promotionnel (170 car. max) : « Recettes simples, séances courtes et journal personnel, à votre rythme. Sans calories, sans compte, vos données restent sur votre iPhone. »

Mots-clés (100 car. max, sans répéter le nom ni le sous-titre) : `syndrome ovaires polykystiques,recettes,IG bas,yoga,journal,cycle,bien-être,sport doux,cuisine`

À ne jamais écrire sur la fiche : « réduit les symptômes », « régule », « traite », « cliniquement prouvé », « anti-SOPK », « perdre du poids », « prédit », « fertilité » (autrement que dans la négation du disclaimer).

---

## 9. Checklist de relecture copy (à chaque écran)
- [ ] Tutoiement, voix « on », aucune familiarité.
- [ ] Aucun mot de la liste §4.1 (script : grep sur `strings.fr.json`).
- [ ] Aucun accord au féminin ou au masculin visant l'utilisatrice.
- [ ] Aucun chiffre de poids ou de calories ; aucun chiffre du tout en mode sans chiffres.
- [ ] Aucune phase, ovulation, fertilité, prédiction.
- [ ] Contenu santé : source + `common.healthFootnote`.
- [ ] Longueurs §5.2 respectées, mode doux ≤ 8 mots par phrase.
- [ ] Notifications : aucun mot de la liste §6.1.
- [ ] Labels VoiceOver présents pour les icônes, visages, graphiques, états.

## 10. À valider avant la bêta
1. **Médecin** : relire `onboarding.disclaimer.*`, `cycle.alert.*`, `checkin.safety.*`, `move.player.unwell.*`, `settings.whenToConsult.*`, `settings.pregnancy.*` (conversion vouvoiement → tutoiement, nom « Ovéa » à la place de « SOPK Food »).
2. **Numéros** : 15, 112, 3114 et ligne TCA FFAB (09 69 325 900, signalé « à vérifier » en 04 §4.1).
3. **Nom** « Ovéa » : disponibilité App Store et INPI (07, décision porteur).
4. **Diététicien ou diététicienne** : `cooking.*` (aide des filtres, IG estimé).
