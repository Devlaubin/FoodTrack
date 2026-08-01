# TODO - Build Android BETA FoodTrack

## Étapes

- [x] **Étape 0:** Analyse du projet et plan approuvé
- [x] **Étape 1:** Mettre à jour `pubspec.yaml` - Version BETA 1.1.0+2
- [x] **Étape 2:** Mettre à jour `android/app/build.gradle.kts` - applicationId `com.foodtrack.app`, signing release, versionCode/Name
- [x] **Étape 3:** Mettre à jour `AndroidManifest.xml` (main) - Permissions INTERNET + localisation, label "FoodTrack"
- [x] **Étape 4:** Mettre à jour `lib/screens/profile_screen.dart` - Pied de page BETA v1.1.0
- [x] **Étape 5:** Mettre à jour `.gitignore` - Ignorer keystore + key.properties
- [x] **Étape 6:** Mettre à jour `lib/screens/food_radar_home.dart` - userAgentPackageName aligné
- [x] **Étape 7:** Créer `android/key.properties` + générer keystore `foodtrack-key.jks`
- [x] **Étape 8:** Ajouter icône de lanceur FoodTrack + splash (logo assets/Logo.png)
- [x] **Étape 9:** `flutter pub get`
- [x] **Étape 10:** `flutter analyze` (0 erreur, 87 infos dépréciation)
- [x] **Étape 11:** `flutter build apk --release --split-per-abi` - 3 APK signés BETA (arm64-v8a, armeabi-v7a, x86_64)
- [x] **Étape 12:** `flutter build appbundle --release` - `app-release.aab` (50,4 MB) signé BETA
