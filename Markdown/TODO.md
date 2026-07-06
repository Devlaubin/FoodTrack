TODO list des fonctionnalités à ajouter (ordre par étapes) de l'application "FoodTrack"

Phase 0 — Fondation UI & cohérence
1) Finaliser/valider thème + couleurs (lib/theme/*) et style global (boutons/ombres).
2) Valider navigation de base Splash → Home (actuel: bouton “Entrer”).
3) Structurer Clean Architecture (Domain/UseCases/Repos/DataSources) pour accueillir le backend.
4) Créer modèles Domain: FoodTruck, MenuItem, OpeningHours, Review, User, Post…
5) Mettre en place une stratégie d’état (simple au début) cohérente avec l’architecture.

Phase 1 — Auth & écrans de base
6) Écran Login (connexion utilisateur).
7) Écran Inscription.
8) Distinction Client vs Pro (même si UI minimale: role flag).
9) Intégrer Supabase Auth: connexion/déconnexion + récupération profil.

Phase 2 — Splash “DA” + UX
10) Remplacer Splash bool simple par animation (burger/canette rétro) + transition home.

Phase 3 — Carte: données réelles + interactions
11) Remplacer markers en dur par données provenant d’un backend/API.
12) Ajouter (v1) un filtrage simple: ouverts maintenant / type.
13) Conserver le style “marqueurs sticker” avec contour noir prononcé.
14) Clic marqueur → bottom sheet “Fiche rapide”.

Phase 4 — Liste + fiche détail (Menu & horaires)
15) Créer écran Liste des foodtrucks (depuis recherche/filtre + synchronisé avec carte).
16) Créer widget FoodtruckCard style sticker (bordure noire 3px + ombre nette offset).
17) Créer écran Détail foodtruck:
    Menu du jour façon ardoise
    Horaires en évidence via badge vertPickle
    (d’abord contenu mock, puis API)
    Ajouter placeholders UI pour photos (puis contenu pro).

Phase 5 — Recherche & filtres utilisateur
18) Barre de recherche (nom / ville / type).
19) Filtres avancés progressifs:
    Distance (plus tard géolocalisation)
    cuisine/type
    ouvert maintenant
    Appliquer les filtres à Liste + carte (overlay ou panneau).

Phase 6 — Côté Pro (menu, horaires, GPS temps réel)
19) Barre de navigation en bas de l'ecran : carte, profil, et l'ecran pro pour les utilisateurs Pro.
20) Écran Pro: gestion menu.
21) Écran Pro: gestion horaires.
22) Upload/gestion photos (puis stockage réel).
23) Position GPS temps réel du pro (puis mise à jour sur la carte).
24) Publier dans le fil d’actualité depuis compte pro.

Phase 7 — Géolocalisation & itinéraire GPS
25) Activer géolocalisation temps réel.
26) Afficher position utilisateur sur la carte.
27) Calculer l’itinéraire vers un foodtruck (au moins deep-link Google Maps).

Phase 8 — Avis & favoris
28) Écran Avis (liste + détail). (Dans la barre de navigation en bas)
29) Favoris (ajouter/retirer + liste).
30) Tri/filtre avis (optionnel v1).

Phase 10 — Fil d’actualité “En direct du grill”
34) Écran Fil d’Actualité (scroll vertical).
35) Modèle Post (changement emplacement, rupture stock, édition limitée…).
36) API: récupération posts (pagination) + création par pro (plus tard).
37) UI posts “rapides” + micro-copies ton chaleureux.

Phase 11 — Notifications “Chaudes” (FCM)
38) Intégrer Firebase Cloud Messaging (permissions, token).
39) Micro-copies par catégorie (ex: “Gros plan sur le grill !”).
40) Backend: endpoints pour déclencher notifications.

Phase 12 — Carte de fidélité numérique
41) Écran/composant Fidélité (vieille carte cartonnée).
42) Animation tampon rétro lors de la validation commande.
43) Règles v1 simples (ex: 1 tampon/commande, progression jusqu’à seuil).

Phase 13 — Notifications “Chaudes” (FCM)
44) Intégrer Firebase Cloud Messaging (permissions, token).
45) Micro-copies par catégorie (ex: “Gros plan sur le grill !”).
46) Backend: endpoints pour déclencher notifications.

Phase 14 — Commande & paiement + API publique
47) Écran Commande depuis la fiche foodtruck.
48) Paiement (selon choix du projet).
49) API publique (documentation + endpoints).

Phase 15 — Tests, perf & CI
50) Tests unitaires/widget (étendre test/widget_test.dart).
51) Vérification contrastes sur petits écrans.
52) Optimiser perf (notamment autour du rendu carte/markers et rebuilds; isoler avec RepaintBoundary).
53) GitHub Actions: tests + build multi-plateformes.