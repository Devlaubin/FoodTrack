#  TODO - Modernisation Auth + Vérification email

## Étapes

- [x] Moderniser la page de connexion (`login_screen.dart`)
- [x] Moderniser la page d'inscription (`register_screen.dart`)
- [x] Ajouter la détection de confirmation email dans `auth_service.dart`
- [x] Ajouter la méthode `resendVerificationEmail` dans `auth_service.dart`
- [x] Créer l'écran de vérification email (`email_verification_screen.dart`)
- [x] Mettre à jour le `app_router.dart` avec la nouvelle route
- [x] Rediriger vers l'écran de vérification après inscription si nécessaire
- [x] Améliorer le message d'erreur de connexion pour email non confirmé
- [x] Résoudre le timeout de création de compte (timeout 60s + redirection gracieuse)
- [x] Corriger erreur "Looking up a deactivated widget's ancestor is unsafe"
  - login/register/email_verification : remplacement des `Consumer<AuthService>` par état local
  - splash_screen : cache de la référence AuthService dans didChangeDependencies + garde `mounted` + pas de `context.read()` dans dispose
- [x] Lancer `flutter analyze` (aucune erreur, seulement des infos de dépréciation pré-existantes)

## Note

Le template HTML Supabase (`{{ .ConfirmationURL }}`) est correct.
L'erreur `signup: 504` dans la console est un timeout côté serveur Supabase (fournisseur d'email lent), indépendant du code.
