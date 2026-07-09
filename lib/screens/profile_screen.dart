import 'package:flutter/material.dart';
import 'package:foodtruck_app/app/app_router.dart';
import 'package:foodtruck_app/domain/user_profile.dart';
import 'package:foodtruck_app/services/auth_service.dart';
import 'package:foodtruck_app/services/pro_service.dart';
import 'package:foodtruck_app/theme/colors.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, auth, child) {
        final profile = auth.profile;

        return Scaffold(
          backgroundColor: FoodtrackColors.cremeVintage,
          appBar: AppBar(title: const Text('Mon profil')),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: FoodtrackColors.noirBrule,
                      width: 3,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: FoodtrackColors.noirBrule,
                        offset: Offset(4, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: FoodtrackColors.rougeKetchup,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: FoodtrackColors.noirBrule,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: FoodtrackColors.cremeVintage,
                          size: 34,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile?.displayName ??
                                  profile?.email.split('@').first ??
                                  'Invite',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: FoodtrackColors.noirBrule,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              profile?.email ?? '',
                              style: TextStyle(
                                fontSize: 13,
                                color: FoodtrackColors.noirBrule.withOpacity(
                                  0.7,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: profile?.role == UserRole.pro
                                    ? FoodtrackColors.vertPickle
                                    : FoodtrackColors.jauneMoutarde,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: FoodtrackColors.noirBrule,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                profile?.role == UserRole.pro
                                    ? 'COMPTE PRO'
                                    : 'CLIENT',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: FoodtrackColors.noirBrule,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () async {
                    await auth.signOut();
                    if (context.mounted) {
                      context.read<ProService>().clear();
                      Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil(AppRouter.splash, (_) => false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FoodtrackColors.noirBrule,
                    foregroundColor: FoodtrackColors.cremeVintage,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    'Deconnexion',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
