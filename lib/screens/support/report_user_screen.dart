import 'package:flutter/material.dart';
import 'package:foodtruck_app/domain/user_report.dart';
import 'package:foodtruck_app/services/auth_service.dart';
import 'package:foodtruck_app/services/report_service.dart';
import 'package:foodtruck_app/theme/colors.dart';
import 'package:provider/provider.dart';

/// Screen where the user can report another user (harassment, spam, ...).
class ReportUserScreen extends StatefulWidget {
  const ReportUserScreen({super.key});

  @override
  State<ReportUserScreen> createState() => _ReportUserScreenState();
}

class _ReportUserScreenState extends State<ReportUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _descriptionController = TextEditingController();
  ReportReason _reason = ReportReason.other;

  @override
  void dispose() {
    _emailController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final reportService = context.read<ReportService>();
    final auth = context.read<AuthService>();
    final user = auth.user;
    if (user == null) return;

    final success = await reportService.submitUserReport(
      reporterId: user.id,
      reportedUserEmail: _emailController.text.trim(),
      reason: _reason,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Signalement envoye. Merci !'),
          backgroundColor: FoodtrackColors.vertPickle,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      );
      Navigator.of(context).pop();
    } else if (reportService.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(reportService.error!),
          backgroundColor: FoodtrackColors.rougeKetchup,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FoodtrackColors.cremeVintage,
      appBar: AppBar(
        title: const Text('Signaler un utilisateur'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Intro card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: FoodtrackColors.noirBrule,
                    width: 2,
                  ),
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
                    const Icon(
                      Icons.shield_outlined,
                      color: FoodtrackColors.rougeKetchup,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Ton signalement reste confidentiel. '
                        'Notre equipe le verifiera rapidement.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: FoodtrackColors.noirBrule.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Reported user email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration().copyWith(
                  labelText: 'Email de l\'utilisateur a signaler',
                  hintText: 'exemple@email.com',
                  prefixIcon: const Icon(
                    Icons.alternate_email,
                    color: FoodtrackColors.noirBrule,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Indique l\'email de la personne a signaler';
                  }
                  if (!value.contains('@')) {
                    return 'Email invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Reason
              const Text(
                'Motif du signalement',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: FoodtrackColors.noirBrule,
                ),
              ),
              const SizedBox(height: 10),
              ...ReportReason.values.map(
                (reason) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ReasonTile(
                    reason: reason,
                    isSelected: _reason == reason,
                    onTap: () => setState(() => _reason = reason),
                  ),
                ),
              ),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                maxLength: 500,
                decoration: _inputDecoration().copyWith(
                  labelText: 'Details (optionnel)',
                  hintText: 'Ajoute des details utiles pour notre equipe...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 8),

              // Submit button
              Consumer<ReportService>(
                builder: (context, service, child) {
                  if (service.isLoading) {
                    return const SizedBox(
                      height: 52,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: FoodtrackColors.rougeKetchup,
                        ),
                      ),
                    );
                  }
                  return ElevatedButton.icon(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FoodtrackColors.rougeKetchup,
                      foregroundColor: FoodtrackColors.cremeVintage,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(
                          color: FoodtrackColors.noirBrule,
                          width: 2,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.report_problem),
                    label: const Text(
                      'Envoyer le signalement',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(
        color: FoodtrackColors.noirBrule,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: TextStyle(
        color: FoodtrackColors.noirBrule.withOpacity(0.4),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: FoodtrackColors.noirBrule,
          width: 2,
        ),
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
          color: FoodtrackColors.rougeKetchup,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: FoodtrackColors.rougeKetchup,
          width: 2,
        ),
      ),
    );
  }
}

/// A selectable tile for a report reason.
class _ReasonTile extends StatelessWidget {
  const _ReasonTile({
    required this.reason,
    required this.isSelected,
    required this.onTap,
  });

  final ReportReason reason;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? FoodtrackColors.jauneMoutarde : Colors.white,
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
        child: Row(
          children: [
            Icon(
              reason.icon,
              size: 22,
              color: isSelected
                  ? FoodtrackColors.noirBrule
                  : FoodtrackColors.rougeKetchup,
            ),
            const SizedBox(width: 12),
            Text(
              reason.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? FoodtrackColors.noirBrule
                    : FoodtrackColors.noirBrule.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

