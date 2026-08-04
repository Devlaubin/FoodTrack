import 'package:flutter/material.dart';
import 'package:foodtruck_app/domain/foodtruck.dart';
import 'package:foodtruck_app/theme/colors.dart';
import 'package:foodtruck_app/utils/formatters.dart';
import 'package:url_launcher/url_launcher.dart';

/// Renders a row of tappable social links (Instagram, Facebook, TikTok, X,
/// website, phone) for a foodtruck. Opens the corresponding URL / app.
class SocialLinks extends StatelessWidget {
  const SocialLinks({super.key, required this.foodtruck});

  final FoodTruck foodtruck;

  Future<void> _launch(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      final ok = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir ce lien')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir ce lien')),
        );
      }
    }
  }

  String _instagramUrl(String handle) {
    final h = Formatters.cleanHandle(handle);
    return 'https://instagram.com/$h';
  }

  String _facebookUrl(String handle) {
    final h = Formatters.cleanHandle(handle);
    return 'https://facebook.com/$h';
  }

  String _tiktokUrl(String handle) {
    final h = Formatters.cleanHandle(handle);
    return 'https://tiktok.com/@$h';
  }

  String _xUrl(String handle) {
    final h = Formatters.cleanHandle(handle);
    return 'https://x.com/$h';
  }

  String _websiteUrl(String url) {
    var u = url.trim();
    if (!u.startsWith('http')) u = 'https://$u';
    return u;
  }

  @override
  Widget build(BuildContext context) {
    final links = <Widget>[];

    void addLink({
      required IconData icon,
      required String tooltip,
      required String url,
      Color color = FoodtrackColors.rougeKetchup,
    }) {
      links.add(
        Tooltip(
          message: tooltip,
          child: GestureDetector(
            onTap: () => _launch(context, url),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: FoodtrackColors.noirBrule,
                  width: 2,
                ),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
          ),
        ),
      );
      links.add(const SizedBox(width: 8));
    }

    if (foodtruck.socialInstagram != null &&
        foodtruck.socialInstagram!.trim().isNotEmpty) {
      addLink(
        icon: Icons.photo_camera_outlined,
        tooltip: 'Instagram',
        url: _instagramUrl(foodtruck.socialInstagram!),
      );
    }
    if (foodtruck.socialFacebook != null &&
        foodtruck.socialFacebook!.trim().isNotEmpty) {
      addLink(
        icon: Icons.facebook_outlined,
        tooltip: 'Facebook',
        url: _facebookUrl(foodtruck.socialFacebook!),
      );
    }
    if (foodtruck.socialTiktok != null &&
        foodtruck.socialTiktok!.trim().isNotEmpty) {
      addLink(
        icon: Icons.music_note_outlined,
        tooltip: 'TikTok',
        url: _tiktokUrl(foodtruck.socialTiktok!),
        color: FoodtrackColors.noirBrule,
      );
    }
    if (foodtruck.socialX != null && foodtruck.socialX!.trim().isNotEmpty) {
      addLink(
        icon: Icons.alternate_email,
        tooltip: 'X (Twitter)',
        url: _xUrl(foodtruck.socialX!),
        color: FoodtrackColors.noirBrule,
      );
    }
    if (foodtruck.socialWebsite != null &&
        foodtruck.socialWebsite!.trim().isNotEmpty) {
      addLink(
        icon: Icons.public,
        tooltip: 'Site web',
        url: _websiteUrl(foodtruck.socialWebsite!),
        color: FoodtrackColors.vertPickle,
      );
    }
    if (foodtruck.phone != null && foodtruck.phone!.trim().isNotEmpty) {
      addLink(
        icon: Icons.phone_outlined,
        tooltip: 'Telephone',
        url: 'tel:${foodtruck.phone!.trim()}',
        color: FoodtrackColors.vertPickle,
      );
    }

    if (links.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: links,
    );
  }
}

