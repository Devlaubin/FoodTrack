# 📋 TODO List & Plan de Développement — Foodtrack (Flutter)

Ce document détaille la feuille de route pour développer l'application mobile **Foodtrack** avec le framework **Flutter**, en intégrant scrupuleusement la Direction Artistique (Rétro, Chaleureux, Néo-brutaliste adouci).

---

## 🛠️ Phase 1 : Configuration & Setup de la DA (Thème)

- [ ] **Initialiser le projet Flutter** (`flutter create foodtrack`)
- [ ] **Configurer les polices rétro et modernes** dans le fichier `pubspec.yaml` :
  - Titres : _Recoleta_ ou _Cooper Black_ (ou équivalent Google Fonts comme _Plumpudding_ ou _Bowlby One_)
  - Corps de texte : _Plus Jakarta Sans_ ou _DM Sans_
- [ ] **Définir la palette de couleurs officielle** dans un fichier `theme/colors.dart` :
  - `cremeVintage = Color(0xFFFDF6EC);`
  - `rougeKetchup = Color(0xFFD32F2F);`
  - `jauneMoutarde = Color(0xFFFBC02D);`
  - `vertPickle = Color(0xFF388E3C);`
  - `noirBrule = Color(0xFF212121);`
- [ ] **Créer le `ThemeData` personnalisé** (`theme/app_theme.dart`) :
  - Configurer le fond global de l'appli sur `cremeVintage`.
  - Personnaliser le style global des boutons (`ElevatedButtonThemeData`) avec des angles très arrondis (`BorderRadius.circular(24)`), des bordures épaisses `noirBrule` et une ombre nette non floutée via un décalage d'un `Container` ou un package comme `neubrutalism`.

---

## 🗺️ Phase 2 : Écrans Principaux & Architecture UI

### 1a. Une page d'inscription ou et de connection utilisateur et Fooftruck

Differente page

### 1. Écran de Chargement / Splash Screen ("On fait chauffer les moteurs...")

- [ ] Créer une animation personnalisée : une illustration de burger qui roule sur un skateboard ou une canette rétro qui pétille.
- [ ] Intégrer la typographie de titre imposante pour le logo.

### 2. Écran Carte du FoodTrack (Écran d'accueil principal)

- [ ] Intégrer un package de cartographie (`google_maps_flutter` ou `flutter_map` avec OpenStreetMap).
- [ ] Appliquer un style de carte personnalisé (JSON de configuration pour masquer le bleu/blanc chirurgical au profit d'un ton crème/vintage).
- [ ] Créer des marqueurs personnalisés sous forme de "badges physiques" (petits stickers de camions, tacos, pizzas) avec un contour noir prononcé.

### 3. Liste et Fiche Détail des Foodtrucks

- [ ] Concevoir le widget `FoodtruckCard` avec l'effet "Sticker" :
  - Bordure noire épaisse de 3px.
  - Ombre décalée nette noire (`boxShadow: [BoxShadow(color: noirBrule, offset: Offset(4, 4))]`).
- [ ] Écran détail : Menu du jour façon ardoise de restaurant, horaires d'ouverture mis en évidence par un badge `vertPickle`.

---

## ⚡ Phase 3 : Fonctionnalités Clés & Expérience Utilisateur

- [ ] **Le Fil d'Actualité ("En direct du grill")** : Un flux vertical de publications rapides des gérants de foodtrucks (changements d'emplacement de dernière minute, ruptures de stock, éditions limitées).
- [ ] **La Carte de Fidélité Numérique ("À tamponner")** :
  - Interface visuelle imitant une vieille carte cartonnée.
  - Animation de tampon rétro qui s'écrase sur l'écran lors d'une validation de commande.
- [ ] **Système de Notifications "Chaudes"** :
  - Configurer Firebase Cloud Messaging (FCM).
  - Rédiger les micro-copies dans le ton de la voix amical et complice (_"Gros plan sur le grill ! Ton burger est chaud..."_).

---

## 🧪 Phase 4 : Tests & Peaufinage

- [ ] Tester les contrastes de l'interface sur les petits écrans.
- [ ] Vérifier que les ombres de style Néo-brutaliste ne causent pas de ralentissements lors du défilement (optimisation des `RepaintBoundary`).
- [ ] Valider la conformité de l'expérience utilisateur globale avec l'esprit chaleureux et convivial ciblé.
