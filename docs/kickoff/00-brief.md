# Brief projet — App SOPK (redémarrage from scratch)

## Vision
Application iOS pour aider les femmes atteintes du SOPK (syndrome des ovaires polykystiques) à mieux vivre au quotidien :
alimentation anti-inflammatoire / index glycémique bas, activité physique adaptée, suivi du cycle et des symptômes.
Point de départ : aider une personne réelle (la compagne du porteur de projet), puis l'ouvrir à d'autres femmes.

## Contraintes
- Porteur : développeur web à l'aise, débutant/intermédiaire en iOS (SwiftUI).
- Cible : iOS 17+, SwiftUI. Projet perso → budget faible, infra simple, maintenable par une seule personne.
- Données de santé = sensibles (RGPD, catégorie particulière). Privacy by design, local-first apprécié.
- Pas un dispositif médical : l'app informe et accompagne, elle ne diagnostique pas et ne remplace pas un médecin.
- Langue : français d'abord.

## Historique
Le repo contient une V0 (SwiftUI + Supabase + backoffice Next.js) qu'on abandonne. Elle peut servir de référence
mais on repart de zéro. Les livrables de kickoff vont dans `docs/kickoff/`.
