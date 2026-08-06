import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodtruck_app/app/app_router.dart';
import 'package:foodtruck_app/domain/user_profile.dart';
import 'package:foodtruck_app/services/auth_service.dart';
import 'package:foodtruck_app/theme/colors.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _displayNameController = TextEditingController();
  UserRole _selectedRole = UserRole.client;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final authService = context.read<AuthService>();

    try {
      final success = await authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
        displayName: _displayNameController.text.trim().isNotEmpty
            ? _displayNameController.text.trim()
            : null,
      );

      if (!mounted) return;

      // Email confirmation required -> redirect to verification screen
      if (authService.needsEmailVerification) {
        Navigator.of(context).pushReplacementNamed(
          AppRouter.emailVerification,
          arguments: _emailController.text.trim(),
        );
        return;
      }

      if (success) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRouter.home, (route) => false);
        return;
      }

      if (authService.error != null) {
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
        setState(() => _isSubmitting = false);
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
                      Icons.lunch_dining,
                      size: 52,
                      color: FoodtrackColors.vertPickle,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Inscription',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Rejoins la communauté des foodtrucks !',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ModernTextField(
                            controller: _displayNameController,
                            label: 'Pseudo (optionnel)',
                            hint: 'Ton petit nom',
                            textInputAction: TextInputAction.next,
                            prefixIcon: Icons.person_outline_rounded,
                          ),
                          const SizedBox(height: 16),
                          _ModernTextField(
                            controller: _emailController,
                            label: 'Adresse email',
                            hint: 'exemple@email.com',
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            prefixIcon: Icons.alternate_email_rounded,
                            validator: (value) {
                              final email = value?.trim() ?? '';
                              if (email.isEmpty) {
                                return 'Entre ton adresse email';
                              }
                              if (!_isValidEmail(email)) {
                                return 'Adresse email invalide';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _ModernTextField(
                            controller: _passwordController,
                            label: 'Mot de passe',
                            hint: 'Min. 6 caractères',
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.next,
                            prefixIcon: Icons.lock_outline_rounded,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: FoodtrackColors.noirBrule,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Entre un mot de passe';
                              }
                              if (value.length < 6) {
                                return 'Min. 6 caractères';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _ModernTextField(
                            controller: _confirmPasswordController,
                            label: 'Confirmer le mot de passe',
                            hint: 'Répète ton mot de passe',
                            obscureText: _obscureConfirmPassword,
                            textInputAction: TextInputAction.done,
                            prefixIcon: Icons.lock_outline_rounded,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: FoodtrackColors.noirBrule,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Confirme ton mot de passe';
                              }
                              if (value != _passwordController.text) {
                                return 'Les mots de passe ne correspondent pas';
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) => _handleRegister(),
                          ),
                          const SizedBox(height: 24),

                          // Role selection
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: FoodtrackColors.cremeVintage,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: FoodtrackColors.noirBrule,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Tu es...',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: FoodtrackColors.noirBrule,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _RoleCard(
                                        icon: Icons.restaurant_rounded,
                                        label: 'Gourmand',
                                        description:
                                            'Je cherche\n des foodtrucks',
                                        isSelected:
                                            _selectedRole == UserRole.client,
                                        color: FoodtrackColors.jauneMoutarde,
                                        onTap: () {
                                          setState(() {
                                            _selectedRole = UserRole.client;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _RoleCard(
                                        icon: Icons.local_shipping_rounded,
                                        label: 'Pro',
                                        description: 'Je gère\n un foodtruck',
                                        isSelected:
                                            _selectedRole == UserRole.pro,
                                        color: FoodtrackColors.vertPickle,
                                        onTap: () {
                                          setState(() {
                                            _selectedRole = UserRole.pro;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          if (_isSubmitting)
                            const SizedBox(
                              height: 52,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: FoodtrackColors.vertPickle,
                                ),
                              ),
                            )
                          else
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _handleRegister,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      FoodtrackColors.vertPickle,
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
                                child: const Text(
                                  'Créer mon compte',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Déjà un compte ?',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: FoodtrackColors.noirBrule,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).pushReplacementNamed(AppRouter.login);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: FoodtrackColors.rougeKetchup,
                        ),
                        child: const Text(
                          'Se connecter',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }
}

class _ModernTextField extends StatelessWidget {
  const _ModernTextField({
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      style: const TextStyle(
        fontSize: 16,
        color: FoodtrackColors.noirBrule,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(
          color: FoodtrackColors.noirBrule,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: FoodtrackColors.noirBrule)
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: FoodtrackColors.cremeVintage,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: FoodtrackColors.noirBrule,
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: FoodtrackColors.vertPickle,
            width: 2.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: FoodtrackColors.rougeKetchup,
            width: 2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: FoodtrackColors.rougeKetchup,
            width: 2.5,
          ),
        ),
        errorStyle: const TextStyle(
          color: FoodtrackColors.rougeKetchup,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputFormatters: keyboardType == TextInputType.emailAddress
          ? [FilteringTextInputFormatter.deny(RegExp(r'\s'))]
          : null,
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String description;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: FoodtrackColors.noirBrule,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: FoodtrackColors.noirBrule,
                    offset: Offset(3, 3),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 30,
              color: isSelected ? FoodtrackColors.noirBrule : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: isSelected
                    ? FoodtrackColors.noirBrule
                    : FoodtrackColors.noirBrule.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                height: 1.2,
                color: isSelected
                    ? FoodtrackColors.noirBrule
                    : FoodtrackColors.noirBrule.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
