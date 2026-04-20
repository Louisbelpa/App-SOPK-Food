-- ============================================================
-- Seed — 15 recettes anti-inflammatoires SOPK / Endométriose
-- ============================================================

DO $$
DECLARE
  r1  UUID := 'a1000000-0000-0000-0000-000000000001';
  r2  UUID := 'a1000000-0000-0000-0000-000000000002';
  r3  UUID := 'a1000000-0000-0000-0000-000000000003';
  r4  UUID := 'a1000000-0000-0000-0000-000000000004';
  r5  UUID := 'a1000000-0000-0000-0000-000000000005';
  r6  UUID := 'a1000000-0000-0000-0000-000000000006';
  r7  UUID := 'a1000000-0000-0000-0000-000000000007';
  r8  UUID := 'a1000000-0000-0000-0000-000000000008';
  r9  UUID := 'a1000000-0000-0000-0000-000000000009';
  r10 UUID := 'a1000000-0000-0000-0000-000000000010';
  r11 UUID := 'a1000000-0000-0000-0000-000000000011';
  r12 UUID := 'a1000000-0000-0000-0000-000000000012';
  r13 UUID := 'a1000000-0000-0000-0000-000000000013';
  r14 UUID := 'a1000000-0000-0000-0000-000000000014';
  r15 UUID := 'a1000000-0000-0000-0000-000000000015';
BEGIN

-- ────────────────────────────────────────────────────────────
-- RECETTES
-- ────────────────────────────────────────────────────────────
INSERT INTO recipes (id, title, description, prep_time, cook_time, servings, conditions, meal_type, tags) VALUES
(r1,  'Bowl curcuma, lentilles corail et épinards',
 'Un bowl chaleureux riche en fer et anti-inflammatoires naturels. Le curcuma et le gingembre frais agissent en synergie pour réduire l''inflammation pelvienne.',
 10, 15, 2, ARRAY['sopk','endometriose'], 'lunch',
 ARRAY['Sans gluten','Sans lactose','Vegan','Riche en fer','Anti-inflammatoire']),

(r2,  'Saumon sauvage, quinoa et brocoli rôti',
 'Le saumon sauvage est l''une des meilleures sources d''oméga-3 EPA/DHA. Associé au brocoli et son indole-3-carbinol, il soutient l''équilibre hormonal.',
 10, 20, 2, ARRAY['sopk','endometriose'], 'dinner',
 ARRAY['Sans gluten','Sans lactose','Riche en oméga-3','Détox hormonale']),

(r3,  'Porridge chia, myrtilles et cannelle',
 'Un petit-déjeuner à index glycémique bas qui stabilise l''insuline dès le matin. Idéal pour les femmes atteintes de SOPK avec résistance à l''insuline.',
 5, 0, 1, ARRAY['sopk'], 'breakfast',
 ARRAY['Sans gluten','Vegan','IG bas','Riche en oméga-3']),

(r4,  'Velouté de patate douce au gingembre',
 'Doux et réconfortant, ce velouté apaise les douleurs menstruelles grâce au gingembre. Le bêta-carotène de la patate douce soutient la production de progestérone.',
 10, 25, 3, ARRAY['endometriose','sopk'], 'dinner',
 ARRAY['Sans gluten','Sans lactose','Vegan','Réconfortant','Anti-douleur']),

(r5,  'Salade tiède pois chiches, avocat et grenade',
 'Une salade complète riche en phytoestrogènes équilibrants et en graisses saines. La grenade est l''une des rares sources alimentaires de punicalagines ultra-antioxydants.',
 15, 5, 2, ARRAY['sopk','endometriose'], 'lunch',
 ARRAY['Sans gluten','Sans lactose','Vegan','Riche en fibres']),

(r6,  'Smoothie anti-fatigue cacao et banane',
 'Le cacao cru est l''aliment le plus riche en magnésium : parfait en phase lutéale pour lutter contre la fatigue et les crampes.',
 5, 0, 1, ARRAY['sopk','endometriose'], 'breakfast',
 ARRAY['Sans gluten','Vegan','Riche en magnésium','Boost énergie']),

(r7,  'Tartines de seigle, sardines et concombre',
 'Les sardines en boîte sont une source économique et puissante d''oméga-3. Associées aux fibres du seigle, elles constituent un snack anti-inflammatoire complet.',
 10, 0, 1, ARRAY['sopk','endometriose'], 'snack',
 ARRAY['Riche en oméga-3','Calcium','Sans lactose']),

(r8,  'Curry de pois chiches au lait de coco et épinards',
 'Ce curry végétalien regorge de curcuma, cumin et coriandre — un trio anti-inflammatoire puissant. Les pois chiches apportent des protéines et des fibres prébiotiques.',
 15, 20, 3, ARRAY['sopk','endometriose'], 'dinner',
 ARRAY['Sans gluten','Sans lactose','Vegan','Riche en protéines végétales']),

(r9,  'Granola maison aux noix et graines',
 'Un granola sans sucre ajouté, riche en oméga-3 (noix), zinc (graines de courge) et magnésium (noix du Brésil). Préparez-en une grande quantité pour toute la semaine.',
 10, 20, 6, ARRAY['sopk'], 'breakfast',
 ARRAY['Sans gluten','Vegan','Sans sucre ajouté','Zinc','Magnésium']),

(r10, 'Salade de roquette, noix et poires rôties',
 'Les noix sont une des meilleures sources végétales d''oméga-3 et d''acide ellagique. Les poires rôties au miel de thym caramélisent sans sucre raffiné.',
 10, 15, 2, ARRAY['endometriose'], 'lunch',
 ARRAY['Sans gluten','Sans lactose','Végétarien','Antioxydant']),

(r11, 'Filet de truite, asperges et citron confit',
 'La truite arc-en-ciel est riche en oméga-3 tout comme le saumon, et souvent plus accessible. Les asperges sont diurétiques et riches en folates — importantes en phase folliculaire.',
 10, 15, 2, ARRAY['endometriose','sopk'], 'dinner',
 ARRAY['Sans gluten','Sans lactose','Riche en oméga-3','Folates']),

(r12, 'Bowl açaï, banane et fruits rouges',
 'L''açaï est l''un des fruits les plus riches en antioxydants. Ce bowl rafraîchissant stabilise la glycémie grâce aux fruits entiers et aux graines de chia.',
 10, 0, 1, ARRAY['sopk','endometriose'], 'breakfast',
 ARRAY['Sans gluten','Vegan','Antioxydant','IG bas']),

(r13, 'Omelette aux herbes, champignons et avocat',
 'Les œufs apportent de la choline, essentielle à la santé hépatique et à la détoxification des œstrogènes. Les champignons sont riches en vitamine D.',
 5, 10, 1, ARRAY['sopk'], 'breakfast',
 ARRAY['Sans gluten','Sans lactose','Végétarien','Protéines','Choline']),

(r14, 'Taboulé de chou-fleur au persil et menthe',
 'Le chou-fleur râpé remplace le boulgour pour un taboulé sans gluten et à IG quasi nul. Le persil frais est exceptionnellement riche en vitamine C et en fer.',
 20, 0, 3, ARRAY['sopk','endometriose'], 'lunch',
 ARRAY['Sans gluten','Sans lactose','Vegan','Cru','Riche en vitamine C']),

(r15, 'Compote pomme-cannelle et crème d''amande',
 'Une douceur saine pour combler les envies sucrées sans sucre raffiné. La cannelle de Ceylan est cliniquement reconnue pour améliorer la sensibilité à l''insuline dans le SOPK.',
 5, 15, 2, ARRAY['sopk'], 'snack',
 ARRAY['Sans gluten','Vegan','Sans sucre ajouté','IG bas','Sensibilité à l''insuline']);

-- ────────────────────────────────────────────────────────────
-- INGRÉDIENTS
-- ────────────────────────────────────────────────────────────
INSERT INTO ingredients (recipe_id, name, quantity, unit, category) VALUES
-- r1 – Bowl lentilles
(r1,'Lentilles corail',120,'g','céréales'),
(r1,'Curcuma frais râpé',1,'c. à c.','épices'),
(r1,'Épinards frais',80,'g','légumes'),
(r1,'Lait de coco',150,'ml','matières grasses'),
(r1,'Gingembre frais',2,'cm','épices'),
(r1,'Huile d''olive extra vierge',1,'c. à s.','matières grasses'),
(r1,'Graines de courge',15,'g','épices'),
-- r2 – Saumon quinoa
(r2,'Filet de saumon sauvage',140,'g','protéines'),
(r2,'Quinoa',80,'g','céréales'),
(r2,'Brocoli',200,'g','légumes'),
(r2,'Ail',2,'gousses','légumes'),
(r2,'Citron',0.5,'','fruits'),
(r2,'Huile d''olive',2,'c. à s.','matières grasses'),
-- r3 – Porridge chia
(r3,'Graines de chia',3,'c. à s.','épices'),
(r3,'Lait d''amande',250,'ml','produits laitiers'),
(r3,'Myrtilles fraîches',80,'g','fruits'),
(r3,'Cannelle de Ceylan',1,'c. à c.','épices'),
(r3,'Amandes effilées',15,'g','protéines'),
-- r4 – Velouté patate douce
(r4,'Patate douce',500,'g','légumes'),
(r4,'Gingembre frais',3,'cm','épices'),
(r4,'Lait de coco',200,'ml','matières grasses'),
(r4,'Oignon doux',1,'','légumes'),
(r4,'Bouillon de légumes',500,'ml','autre'),
-- r5 – Salade pois chiches
(r5,'Pois chiches cuits',200,'g','protéines'),
(r5,'Avocat mûr',1,'','légumes'),
(r5,'Graines de grenade',50,'g','fruits'),
(r5,'Roquette',60,'g','légumes'),
(r5,'Tahin',1,'c. à s.','matières grasses'),
(r5,'Citron',1,'','fruits'),
-- r6 – Smoothie cacao
(r6,'Banane congelée',1,'','fruits'),
(r6,'Cacao cru en poudre',2,'c. à c.','épices'),
(r6,'Beurre de cacahuète',1,'c. à s.','matières grasses'),
(r6,'Lait d''avoine',250,'ml','produits laitiers'),
(r6,'Graines de lin moulues',1,'c. à s.','épices'),
-- r7 – Tartines sardines
(r7,'Pain de seigle complet',2,'tranches','céréales'),
(r7,'Sardines en boîte',1,'boîte','protéines'),
(r7,'Concombre',0.5,'','légumes'),
(r7,'Citron',0.5,'','fruits'),
(r7,'Aneth frais',null,'brins','épices'),
-- r8 – Curry pois chiches
(r8,'Pois chiches cuits',400,'g','protéines'),
(r8,'Lait de coco',250,'ml','matières grasses'),
(r8,'Épinards frais',100,'g','légumes'),
(r8,'Tomates concassées',400,'g','légumes'),
(r8,'Curcuma moulu',1.5,'c. à c.','épices'),
(r8,'Cumin moulu',1,'c. à c.','épices'),
(r8,'Oignon',1,'','légumes'),
(r8,'Ail',3,'gousses','légumes'),
(r8,'Gingembre frais',2,'cm','épices'),
-- r9 – Granola
(r9,'Flocons d''avoine sans gluten',200,'g','céréales'),
(r9,'Noix mélangées',100,'g','protéines'),
(r9,'Graines de courge',50,'g','épices'),
(r9,'Graines de tournesol',50,'g','épices'),
(r9,'Huile de coco',3,'c. à s.','matières grasses'),
(r9,'Miel',2,'c. à s.','autre'),
(r9,'Cannelle',1,'c. à c.','épices'),
-- r10 – Salade roquette noix poire
(r10,'Roquette',80,'g','légumes'),
(r10,'Noix cerneaux',40,'g','protéines'),
(r10,'Poire',2,'','fruits'),
(r10,'Chèvre frais',50,'g','produits laitiers'),
(r10,'Miel de thym',1,'c. à s.','autre'),
(r10,'Vinaigre balsamique',1,'c. à s.','autre'),
-- r11 – Truite asperges
(r11,'Filet de truite',150,'g','protéines'),
(r11,'Asperges vertes',200,'g','légumes'),
(r11,'Citron confit',1,'c. à s.','épices'),
(r11,'Huile d''olive',2,'c. à s.','matières grasses'),
(r11,'Aneth',null,'brins','épices'),
-- r12 – Bowl açaï
(r12,'Purée d''açaï',100,'g','fruits'),
(r12,'Banane',1,'','fruits'),
(r12,'Myrtilles',50,'g','fruits'),
(r12,'Graines de chia',1,'c. à s.','épices'),
(r12,'Lait de coco',100,'ml','matières grasses'),
(r12,'Granola sans gluten',30,'g','céréales'),
-- r13 – Omelette
(r13,'Œufs bio',3,'','protéines'),
(r13,'Champignons de Paris',100,'g','légumes'),
(r13,'Avocat',0.5,'','légumes'),
(r13,'Herbes fraîches (persil, ciboulette)',1,'bouquet','épices'),
(r13,'Huile d''olive',1,'c. à s.','matières grasses'),
-- r14 – Taboulé chou-fleur
(r14,'Chou-fleur',500,'g','légumes'),
(r14,'Persil plat',1,'botte','légumes'),
(r14,'Menthe fraîche',10,'feuilles','épices'),
(r14,'Tomates cerises',150,'g','légumes'),
(r14,'Concombre',1,'','légumes'),
(r14,'Citron',2,'','fruits'),
(r14,'Huile d''olive',3,'c. à s.','matières grasses'),
-- r15 – Compote pomme-cannelle
(r15,'Pommes',4,'','fruits'),
(r15,'Cannelle de Ceylan',1,'c. à c.','épices'),
(r15,'Crème d''amande',4,'c. à s.','matières grasses'),
(r15,'Vanille en poudre',1,'pincée','épices');

-- ────────────────────────────────────────────────────────────
-- ÉTAPES
-- ────────────────────────────────────────────────────────────
INSERT INTO steps (recipe_id, position, instruction) VALUES
-- r1
(r1,1,'Rincer les lentilles corail à l''eau froide jusqu''à ce que l''eau soit claire.'),
(r1,2,'Faire revenir le gingembre et le curcuma râpés dans l''huile d''olive 1 minute.'),
(r1,3,'Ajouter les lentilles, couvrir de lait de coco + 200 ml d''eau. Laisser mijoter 15 min.'),
(r1,4,'Incorporer les épinards en fin de cuisson, saler légèrement.'),
(r1,5,'Servir dans un bol, parsemer de graines de courge torréfiées.'),
-- r2
(r2,1,'Préchauffer le four à 200 °C.'),
(r2,2,'Cuire le quinoa 12 minutes dans l''eau bouillante salée, égoutter.'),
(r2,3,'Disposer le brocoli et l''ail sur une plaque, arroser d''huile d''olive, rôtir 15 min.'),
(r2,4,'Poser le saumon sur la plaque les 8 dernières minutes.'),
(r2,5,'Dresser et arroser de jus de citron frais.'),
-- r3
(r3,1,'Mélanger les graines de chia avec le lait d''amande et la cannelle.'),
(r3,2,'Réfrigérer minimum 4 h (idéalement une nuit).'),
(r3,3,'Remuer au matin pour détacher la texture.'),
(r3,4,'Garnir de myrtilles et d''amandes effilées.'),
-- r4
(r4,1,'Éplucher et couper la patate douce en cubes.'),
(r4,2,'Faire suer l''oignon émincé dans une casserole avec un peu d''huile.'),
(r4,3,'Ajouter patate douce, gingembre râpé et bouillon. Cuire 20 min à feu moyen.'),
(r4,4,'Mixer finement avec le lait de coco.'),
(r4,5,'Rectifier l''assaisonnement, servir chaud avec un filet d''huile d''olive.'),
-- r5
(r5,1,'Réchauffer les pois chiches à la poêle avec une pincée de cumin.'),
(r5,2,'Préparer la sauce : tahin + jus de citron + 2 c. à s. d''eau.'),
(r5,3,'Dresser la roquette, pois chiches tièdes, avocat en tranches.'),
(r5,4,'Parsemer de graines de grenade, arroser de sauce tahin.'),
-- r6
(r6,1,'Placer tous les ingrédients dans un blender.'),
(r6,2,'Mixer 45 s jusqu''à obtenir une texture lisse.'),
(r6,3,'Servir immédiatement dans un grand verre.'),
-- r7
(r7,1,'Égoutter et écraser légèrement les sardines avec une fourchette.'),
(r7,2,'Couper le concombre en fines rondelles.'),
(r7,3,'Tartiner les tranches de seigle de sardines écrasées.'),
(r7,4,'Disposer les rondelles de concombre et arroser de citron.'),
(r7,5,'Garnir d''aneth frais, poivrer.'),
-- r8
(r8,1,'Faire revenir oignon et ail émincés 3 min dans l''huile d''olive.'),
(r8,2,'Ajouter gingembre, curcuma, cumin. Faire revenir 1 min.'),
(r8,3,'Incorporer tomates, lait de coco et pois chiches. Mijoter 15 min.'),
(r8,4,'Ajouter les épinards en fin de cuisson, laisser fondre 2 min.'),
(r8,5,'Servir avec du riz basmati ou du pain naan sans gluten.'),
-- r9
(r9,1,'Préchauffer le four à 160 °C.'),
(r9,2,'Mélanger flocons d''avoine, noix, graines, cannelle dans un saladier.'),
(r9,3,'Faire fondre l''huile de coco avec le miel et verser sur le mélange.'),
(r9,4,'Étaler sur une plaque, cuire 20 min en remuant à mi-cuisson.'),
(r9,5,'Laisser refroidir complètement avant de stocker en bocal.'),
-- r10
(r10,1,'Préchauffer le four à 180 °C.'),
(r10,2,'Couper les poires en deux, arroser de miel de thym, rôtir 12 min.'),
(r10,3,'Préparer la vinaigrette : vinaigre balsamique + huile d''olive + sel.'),
(r10,4,'Dresser la roquette, poires tièdes, noix et chèvre émietté.'),
(r10,5,'Arroser de vinaigrette au moment de servir.'),
-- r11
(r11,1,'Préchauffer le four à 190 °C.'),
(r11,2,'Disposer les asperges sur une plaque huilée, enfourner 10 min.'),
(r11,3,'Poser le filet de truite sur les asperges, ajouter le citron confit, cuire 12 min.'),
(r11,4,'Arroser d''huile d''olive et garnir d''aneth frais.'),
-- r12
(r12,1,'Mixer purée d''açaï, banane et lait de coco jusqu''à consistance crémeuse.'),
(r12,2,'Verser dans un bol.'),
(r12,3,'Garnir de myrtilles, graines de chia et granola.'),
-- r13
(r13,1,'Poêler les champignons émincés 5 min dans l''huile d''olive. Réserver.'),
(r13,2,'Battre les œufs avec les herbes ciselées, sel et poivre.'),
(r13,3,'Cuire l''omelette à feu moyen-doux 3-4 min, replier.'),
(r13,4,'Servir avec l''avocat en tranches et les champignons.'),
-- r14
(r14,1,'Mixer le chou-fleur cru en petites miettes façon semoule dans un robot.'),
(r14,2,'Ciseler finement persil et menthe.'),
(r14,3,'Couper tomates cerises et concombre en petits dés.'),
(r14,4,'Mélanger tous les ingrédients, assaisonner avec citron, huile d''olive et sel.'),
(r14,5,'Réfrigérer 30 min avant de servir pour que les saveurs s''imprègnent.'),
-- r15
(r15,1,'Éplucher et couper les pommes en cubes.'),
(r15,2,'Cuire à feu doux avec 2 c. à s. d''eau et la cannelle pendant 15 min.'),
(r15,3,'Écraser grossièrement à la fourchette (ou mixer pour une texture lisse).'),
(r15,4,'Servir tiède avec une cuillerée de crème d''amande.');

RAISE NOTICE 'Seed terminé : 15 recettes insérées.';
END $$;
