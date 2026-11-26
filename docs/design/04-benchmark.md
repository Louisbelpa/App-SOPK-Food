# Benchmark : apps de référence et pourquoi nos maquettes « font vibe coding »

Recherche du 26/11/2026, menée à la suite du retour du porteur sur la V2 : « c'est mieux, mais ça fait encore trop vibe coding ».

## 1. Diagnostic : ce qui trahit un design généré dans nos maquettes V2

Les articles sur les signes d'une interface générée par IA relèvent toujours les mêmes motifs : dégradés, cartes à ombre douce partout, icônes génériques en guise d'illustration, bordure colorée sur les cartes, grilles de cartes identiques, et des choix par défaut jamais remis en question (couleur principale, rayons, police). Les modèles reproduisent les motifs les plus fréquents de leurs données. La conclusion des articles : ils visent la compétence, pas le savoir-faire.

Dans la V2, plusieurs de ces signes sont présents :

| Signe | Où on le voit chez nous |
|---|---|
| **Fond crème + titre serif + accent terracotta** | Toute la V2. C'est aujourd'hui *le* look par défaut des pages générées par IA. En « réchauffant » la V1, on est tombés pile dessus. |
| Tout est une carte arrondie avec ombre | Aujourd'hui, Bouger, Réglages : 5 à 6 cartes empilées par écran |
| Fausse illustration : blob flou + icône centrée | Toutes les vignettes de recettes et de séances |
| Surtitres en petites capitales espacées | « POUR TOI AUJOURD'HUI », « CHECK-IN DU JOUR »… |
| Cartes « soft » teintées de toutes les couleurs | abricot, miel, sauge, prune sur un même écran |
| Doodles décoratifs (tasse, soleil, plaid) | Ajoutés pour faire « cosy », sans rôle fonctionnel |

## 2. Ce que font les apps reconnues pour leur design

| App | Ce qui la rend unique | À retenir pour Ovéa |
|---|---|---|
| **Gentler Streak** (Apple Design Award 2024, Impact social) | Elle se voit comme une app de style de vie plutôt que de fitness et privilégie les mots aux chiffres bruts. Une mascotte (Yorhart) et des illustrations maison installent un ton chaleureux, sur une base de composants iOS familiers. Son élément central est un visuel signature, l'« Activity Path ». Elle est passée de 4 à 3 onglets lors de sa refonte. | Le plus proche de notre posture : bienveillante, sans pression, très native iOS, **un seul élément signature**. |
| **How We Feel** (App Store Award 2022, finaliste ADA 2024) | Le « Mood Meter » est devenu un paysage émotionnel géométrique et tactile, avec un code couleur. La direction de création vient d'un studio (Strand & Form), avec une illustratrice dédiée. | Une **métaphore visuelle propre** au sujet, pas un empilement de cartes. |
| **Headspace** | Des illustrations faites en interne selon des règles strictes. Palette orange, corail, bleu doux et sauge, blancs cassés chauds et ombres colorées plutôt que grises. | La chaleur vient d'un **système d'illustration cohérent**, pas de la couleur des fonds. |
| **Clue** | Un design épuré et inclusif, au vocabulaire neutre. Relance avec un système de couleurs refait et un calendrier repensé pour les personnes malvoyantes. Critique d'utilisatrice : l'écran est parfois trop chargé. | La sobriété et l'accessibilité comme marque de sérieux. |
| **Apps PCOS récentes** (WAVS, Astraea, Cycle Clarity…) | WAVS (100 % hors ligne, sans compte) revendique un Red Dot Design Award. Astraea met en avant une « calm twilight design ». Cycle Clarity vise une interface « simple, low-stress », avec les données sur l'appareil. | Le créneau local-first + calme est déjà occupé : il faut se distinguer par la **qualité d'exécution** et le contenu (recettes, séances). |

## 3. Ce qu'on en retient

1. **Natif d'abord.** Les références (Gentler Streak, Santé d'Apple) partent des composants iOS standard : listes groupées, grands titres, matériaux système. Le « fait main » ne vient qu'ensuite. Nos maquettes HTML réinventent chaque composant, d'où l'effet template.
2. **Un seul élément signature**, propre au sujet : pour Ovéa, ce serait une représentation de l'énergie du jour ou du journal du cycle.
3. **De vraies images.** Des photos de plats (même faites maison, au téléphone, en lumière naturelle) ou des illustrations commandées à une vraie illustratrice. Jamais d'icônes sur des blobs.
4. **Moins de cartes, plus de typographie et d'espace.** Une seule carte mise en avant par écran.
5. **Les mots plutôt que les chiffres** (repris de Gentler Streak) : c'est déjà notre ton, il faut que le visuel suive.

## Sources

- [Sketch — How Gentler Streak brings kindness to fitness](https://sketch.com/blog/gentler-streak)
- [Apple Developer — Behind the Design: Gentler Streak](https://developer.apple.com/jp/news/?id=3m0ht22s) · [BGR — Gentler Streak redesign](https://bgr.com/tech/gentler-streak-gets-a-major-redesign-focused-on-your-wellbeing/)
- [Apple Design Awards 2024](https://developer.apple.com/design/awards/2024) · [2025](https://developer.apple.com/design/awards/2025/)
- [How We Feel — Substack](https://howwefeel.substack.com/p/we-feelgrateful) · [Behance, Strand & Form](https://www.behance.net/gallery/145365127/How-We-Feel) · [Yale Medicine](https://medicine.yale.edu/news-article/the-how-we-feel-app-helping-emotions-work-for-us-not-against-us/) · [App Store Awards 2022](https://apps.apple.com/us/story/id1647059928)
- [Analyse du design de Headspace](https://blakecrosley.com/guides/design/headspace) · [Blush — illustrations Headspace](https://blush.design/blog/post/headspace-mindfulness-app)
- [Clue — relance et nouveau design](https://helloclue.com/fr/articles/how-to-use-clue/clue-conceive-relaunched-and-newly-designed) · [Avis Clue](https://krill-kazoo-ck9x.squarespace.com/app-reviews/clue-app-review)
- App Store : [WAVS](https://apps.apple.com/us/app/id6505085162) · [Astraea](https://apps.apple.com/app/id6757676352) · [Cycle Clarity](https://apps.apple.com/us/app/id6752903946)
- Signes d'une interface générée : [The Fountain Institute](https://www.thefountaininstitute.com/blog/signs-vibe-coded-ui) · [UX Collective — How to de-slopify your designs](https://uxdesign.cc/how-to-de-slopify-your-designs-4c40c57c1dc9) · [Robots on Payroll](https://robotsonpayroll.substack.com/p/how-to-avoid-that-vibe-coded-look)
- [Mémoire Tilburg (Kukreja) — apps de suivi menstruel et SOPK](https://arno.uvt.nl/show.cgi?fid=183009)
