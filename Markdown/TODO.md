# TODO - Système de signalement utilisateur + retours bug/amélioration

## Étapes d'implémentation

- [x] 1. Migration SQL : tables `user_reports` + `feedback` avec RLS
- [x] 2. Modèle domain : `UserReport`
- [x] 3. Modèle domain : `AppFeedback`
- [x] 4. Service : `ReportService` (ChangeNotifier)
- [x] 5. Écran : `FeedbackScreen` (bug / suggestion)
- [x] 6. Écran : `ReportUserScreen` (signaler un utilisateur)
- [x] 7. Écran : `MyReportsScreen` (liste de mes signalements/retours)
- [x] 8. Intégration : `main.dart` (provider ReportService)
- [x] 9. Intégration : `app_router.dart` (routes)
- [x] 10. Intégration : `profile_screen.dart` (section Aide & Signalements)
- [x] 11. Vérification : `flutter analyze` (aucune erreur)

## Étapes restantes (manuelles)

- [ ] Appliquer la migration SQL `supabase/migrations/20260710000000_create_user_reports_feedback.sql` sur le projet Supabase (Dashboard → SQL Editor, ou `supabase db push`)

