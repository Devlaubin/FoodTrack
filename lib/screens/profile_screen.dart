import 'package:flutter/material.dart';
import 'package:foodtruck_app/app/app_router.dart';
import 'package:foodtruck_app/domain/user_profile.dart';
import 'package:foodtruck_app/services/auth_service.dart';
import 'package:foodtruck_app/services/pro_service.dart';
import 'package:foodtruck_app/theme/colors.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _showLicenses = false;
  bool _showSettings = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, auth, child) {
        final profile = auth.profile;

        return Scaffold(
          backgroundColor: FoodtrackColors.cremeVintage,
          appBar: AppBar(
            title: const Text('Mon profil'),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile card
                _buildProfileCard(profile),
                const SizedBox(height: 20),

                // Settings section
                _buildSectionHeader(
                  icon: Icons.settings,
                  title: 'Parametres',
                  isExpanded: _showSettings,
                  onTap: () => setState(() => _showSettings = !_showSettings),
                ),
                if (_showSettings) ...[
                  const SizedBox(height: 8),
                  _buildSettingsPanel(),
                ],
                const SizedBox(height: 16),

                // Credits & Licenses section
                _buildSectionHeader(
                  icon: Icons.info_outline,
                  title: 'Credits & Licences',
                  isExpanded: _showLicenses,
                  onTap: () => setState(() => _showLicenses = !_showLicenses),
                ),
                if (_showLicenses) ...[
                  const SizedBox(height: 8),
                  _buildLicensesPanel(),
                ],
                const SizedBox(height: 24),

                // Logout button
                _buildLogoutButton(auth),

                const SizedBox(height: 12),

                // Version info
                Center(
                  child: Text(
                    'FoodTrack BETA v1.1.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: FoodtrackColors.noirBrule.withOpacity(0.4),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileCard(UserProfile? profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: FoodtrackColors.noirBrule, width: 3),
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
              border: Border.all(color: FoodtrackColors.noirBrule, width: 2),
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
                    color: FoodtrackColors.noirBrule.withOpacity(0.7),
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
                    profile?.role == UserRole.pro ? 'COMPTE PRO' : 'CLIENT',
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
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: FoodtrackColors.noirBrule, width: 2),
          boxShadow: const [
            BoxShadow(
              color: FoodtrackColors.noirBrule,
              offset: Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: FoodtrackColors.rougeKetchup, size: 22),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: FoodtrackColors.noirBrule,
              ),
            ),
            const Spacer(),
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.expand_more,
                color: FoodtrackColors.noirBrule.withOpacity(0.6),
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: FoodtrackColors.noirBrule, width: 2),
      ),
      child: Column(
        children: [
          _settingsTile(
            icon: Icons.language,
            title: 'Langue',
            subtitle: 'Francais',
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showComingSoon(context, 'Changement de langue'),
          ),
          const Divider(height: 24),
          _settingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Notifications push',
            trailing: Switch(
              value: true,
              activeColor: FoodtrackColors.vertPickle,
              onChanged: (val) {
                _showComingSoon(context, 'Parametres des notifications');
              },
            ),
          ),
          const Divider(height: 24),
          _settingsTile(
            icon: Icons.map_outlined,
            title: 'Rayon de recherche',
            subtitle: '5 km',
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showComingSoon(context, 'Rayon de recherche'),
          ),
          const Divider(height: 24),
          _settingsTile(
            icon: Icons.dark_mode_outlined,
            title: 'Mode sombre',
            subtitle: 'Desactive',
            trailing: Switch(
              value: false,
              activeColor: FoodtrackColors.vertPickle,
              onChanged: (val) {
                _showComingSoon(context, 'Mode sombre');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLicensesPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: FoodtrackColors.noirBrule, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Logiciels utilises',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: FoodtrackColors.noirBrule,
            ),
          ),
          const SizedBox(height: 12),
          _licenseTile(
            'Flutter',
            'Google',
            'BSD 3-Clause License',
            'Framework UI open-source pour applications multi-plateformes.',
          ),
          _licenseTile(
            'Supabase',
            'Supabase Inc.',
            'Apache 2.0',
            'Plateforme backend open-source avec authentification et base de donnees.',
          ),
          _licenseTile(
            'OpenStreetMap',
            'OpenStreetMap contributors',
            'ODbL',
            'Donnees cartographiques libres utilisees via flutter_map.',
          ),
          _licenseTile(
            'Google Fonts',
            'Google',
            'OFL / Apache 2.0',
            'Polices Poppins utilisees dans l\'interface.',
          ),
          _licenseTile(
            'Provider',
            'Remi Rousselet',
            'MIT',
            'Gestion d\'etat pour Flutter.',
          ),
          _licenseTile(
            'Geolocator',
            'Baseflow',
            'MIT',
            'Acces a la position GPS pour la localisation des foodtrucks.',
          ),
          _licenseTile(
            'latlong2',
            'Michael Bims',
            'Apache 2.0',
            'Bibliotheque de manipulation de coordonnees geographiques.',
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: FoodtrackColors.cremeVintage,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: FoodtrackColors.noirBrule.withOpacity(0.3),
              ),
            ),
            child: const Text(
              'Certaines icones utilisees dans cette application proviennent '
              'de Material Icons (Google) sous licence Apache 2.0.\n\n'
              'FoodTrack est un projet open-source. Consultez notre '
              'depot GitHub pour plus d\'informations.',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: FoodtrackColors.noirBrule,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: FoodtrackColors.cremeVintage,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: FoodtrackColors.noirBrule.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              size: 20,
              color: FoodtrackColors.rougeKetchup,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: FoodtrackColors.noirBrule,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: FoodtrackColors.noirBrule.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _licenseTile(
    String name,
    String author,
    String license,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: FoodtrackColors.rougeKetchup,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: FoodtrackColors.noirBrule,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: FoodtrackColors.jauneMoutarde.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: FoodtrackColors.noirBrule.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        license,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: FoodtrackColors.noirBrule,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  author,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: FoodtrackColors.noirBrule.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: FoodtrackColors.noirBrule.withOpacity(0.5),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(AuthService auth) {
    return ElevatedButton.icon(
      onPressed: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: FoodtrackColors.cremeVintage,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(
                color: FoodtrackColors.noirBrule,
                width: 2,
              ),
            ),
            title: const Text(
              'Deconnexion',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            content: const Text(
              'Es-tu sur de vouloir te deconnecter ?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: FoodtrackColors.rougeKetchup,
                  foregroundColor: FoodtrackColors.cremeVintage,
                ),
                child: const Text('Se deconnecter'),
              ),
            ],
          ),
        );

        if (confirm == true) {
          await auth.signOut();
          if (context.mounted) {
            context.read<ProService>().clear();
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRouter.splash,
              (_) => false,
            );
          }
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
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - bientot disponible !'),
        backgroundColor: FoodtrackColors.rougeKetchup,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

