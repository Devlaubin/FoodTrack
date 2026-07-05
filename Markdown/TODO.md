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
19) Barre de recherche (nom / ville / type).
20) Filtres avancés progressifs:
    Distance (plus tard géolocalisation)
    cuisine/type
    ouvert maintenant
    Appliquer les filtres à Liste + carte (overlay ou panneau).

Phase 6 — Géolocalisation & itinéraire GPS
22) Activer géolocalisation temps réel.
23) Afficher position utilisateur sur la carte.
24) Calculer l’itinéraire vers un foodtruck (au moins deep-link Google Maps).

Phase 7 — Fil d’actualité “En direct du grill”
25) Écran Fil d’Actualité (scroll vertical).
26) Modèle Post (changement emplacement, rupture stock, édition limitée…).
27) API: récupération posts (pagination) + création par pro (plus tard).
28) UI posts “rapides” + micro-copies ton chaleureux.

Phase 8 — Carte de fidélité numérique
29) Écran/composant Fidélité (vieille carte cartonnée).
30) Animation tampon rétro lors de la validation commande.
31) Règles v1 simples (ex: 1 tampon/commande, progression jusqu’à seuil).

Phase 9 — Notifications “Chaudes” (FCM)
32) Intégrer Firebase Cloud Messaging (permissions, token).
33) Micro-copies par catégorie (ex: “Gros plan sur le grill !”).
34) Backend: endpoints pour déclencher notifications.

Phase 10 — Avis & favoris
35) Écran Avis (liste + détail).
36) Favoris (ajouter/retirer + liste).
37) Tri/filtre avis (optionnel v1).

Phase 11 — Côté Pro (menu, horaires, GPS temps réel)
38) Écran Pro: gestion menu.
39) Écran Pro: gestion horaires.
40) Upload/gestion photos (puis stockage réel).
41) Position GPS temps réel du pro (puis mise à jour sur la carte).
42) Publier dans le fil d’actualité depuis compte pro.

Phase 12 — Commande & paiement + API publique
43) Écran Commande depuis la fiche foodtruck.
44) Paiement (selon choix du projet).
45) API publique (documentation + endpoints).

Phase 13 — Tests, perf & CI
46) Tests unitaires/widget (étendre test/widget_test.dart).
47) Vérification contrastes sur petits écrans.
48) Optimiser perf (notamment autour du rendu carte/markers et rebuilds; isoler avec RepaintBoundary).
49) GitHub Actions: tests + build multi-plateformes.