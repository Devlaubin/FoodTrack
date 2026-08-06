import 'package:flutter/material.dart';
import 'package:foodtruck_app/app/app_router.dart';
import 'package:foodtruck_app/services/auth_service.dart';
import 'package:foodtruck_app/theme/colors.dart';
import 'package:provider/provider.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key, required this.email});

  final String email;

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _resent = false;
  bool _isResending = false;

  Future<void> _resendEmail() async {
    if (_isResending) return;
    setState(() => _isResending = true);

    final authService = context.read<AuthService>();

    try {
      final success = await authService.resendVerificationEmail(
        email: widget.email,
      );

      if (!mounted) return;

      if (success) {
        setState(() => _resent = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Email de confirmation renvoyé ! Vérifie ta boîte mail.',
            ),
            backgroundColor: FoodtrackColors.vertPickle,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (authService.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authService.error!),
            backgroundColor: FoodtrackColors.rougeKetchup,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FoodtrackColors.cremeVintage,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: FoodtrackColors.noirBrule,
                          blurRadius: 0,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.mark_email_unread_outlined,
                      size: 52,
                      color: FoodtrackColors.jauneMoutarde,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Vérifie ton email',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Un lien de confirmation a été envoyé à\n'
                    '${widget.email}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                      color: FoodtrackColors.noirBrule,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Clique sur le lien dans l\'email pour activer ton compte, '
                    'puis connecte-toi.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                      color: FoodtrackColors.noirBrule,
                    ),
                  ),
                  const SizedBox(height: 32),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: FoodtrackColors.noirBrule,
                        width: 2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: FoodtrackColors.noirBrule,
                          offset: Offset(6, 6),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: FoodtrackColors.jauneMoutarde,
                          size: 32,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Tu n\'as pas reçu l\'email ?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: FoodtrackColors.noirBrule,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Vérifie tes courriers indésirables (spam) ou '
                          'renvoie un nouvel email.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: FoodtrackColors.noirBrule,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_isResending)
                          const SizedBox(
                            height: 48,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: FoodtrackColors.rougeKetchup,
                              ),
                            ),
                          )
                        else
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton.icon(
                              onPressed: _resendEmail,
                              icon: const Icon(
                                Icons.refresh_rounded,
                                color: FoodtrackColors.rougeKetchup,
                              ),
                              label: Text(
                                _resent
                                    ? 'Renvoyer à nouveau'
                                    : 'Renvoyer l\'email',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: FoodtrackColors.rougeKetchup,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: FoodtrackColors.noirBrule,
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRouter.login,
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.login_rounded),
                      label: const Text(
                        'Aller à la connexion',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FoodtrackColors.rougeKetchup,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(
                            color: FoodtrackColors.noirBrule,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
