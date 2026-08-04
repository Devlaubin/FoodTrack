import 'package:flutter/material.dart';
import 'package:foodtruck_app/domain/app_feedback.dart';
import 'package:foodtruck_app/services/auth_service.dart';
import 'package:foodtruck_app/services/report_service.dart';
import 'package:foodtruck_app/theme/colors.dart';
import 'package:provider/provider.dart';

/// Screen where the user can submit a bug report or a feature suggestion.
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  FeedbackType _type = FeedbackType.bug;
  FeedbackCategory _category = FeedbackCategory.autre;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final reportService = context.read<ReportService>();
    final auth = context.read<AuthService>();
    final user = auth.user;
    if (user == null) return;

    final success = await reportService.submitFeedback(
      userId: user.id,
      type: _type,
      category: _category,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Merci pour ton retour !'),
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
        title: const Text('Aide & Retour'),
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
                      Icons.help_outline,
                      color: FoodtrackColors.rougeKetchup,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Un bug ou une idee ? Dis-nous tout, '
                        'on lit chaque retour !',
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

              // Type selector
              const Text(
                'Type de retour',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: FoodtrackColors.noirBrule,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _TypeCard(
                      icon: Icons.bug_report,
                      label: 'Bug',
                      isSelected: _type == FeedbackType.bug,
                      color: FoodtrackColors.rougeKetchup,
                      onTap: () => setState(() => _type = FeedbackType.bug),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TypeCard(
                      icon: Icons.lightbulb_outline,
                      label: 'Amelioration',
                      isSelected: _type == FeedbackType.suggestion,
                      color: FoodtrackColors.vertPickle,
                      onTap: () =>
                          setState(() => _type = FeedbackType.suggestion),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Category
              const Text(
                'Categorie',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: FoodtrackColors.noirBrule,
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<FeedbackCategory>(
                initialValue: _category,
                dropdownColor: FoodtrackColors.cremeVintage,
                decoration: _inputDecoration(),
                items: FeedbackCategory.values
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(c.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _category = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration().copyWith(
                  labelText: 'Titre',
                  hintText: 'Ex: La carte ne se charge pas',
                  prefixIcon: const Icon(
                    Icons.title,
                    color: FoodtrackColors.noirBrule,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Donne un titre court';
                  }
                  if (value.trim().length < 3) {
                    return 'Titre trop court';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                maxLength: 1000,
                decoration: _inputDecoration().copyWith(
                  labelText: 'Description',
                  hintText: _type == FeedbackType.bug
                      ? 'Que s\'est-il passe ? Comment reproduire le bug ?'
                      : 'Decris ton idee en quelques lignes...',
                  alignLabelWithHint: true,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 80),
                    child: Icon(
                      Icons.notes,
                      color: FoodtrackColors.noirBrule,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Decris-nous le probleme ou ton idee';
                  }
                  if (value.trim().length < 10) {
                    return 'Ajoute un peu plus de details (min. 10 caracteres)';
                  }
                  return null;
                },
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
                    icon: const Icon(Icons.send),
                    label: const Text(
                      'Envoyer mon retour',
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

/// A "sticker" style selectable card for choosing Bug vs Amelioration.
class _TypeCard extends StatelessWidget {
  const _TypeCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(16),
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
              size: 28,
              color: isSelected
                  ? FoodtrackColors.cremeVintage
                  : FoodtrackColors.noirBrule,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? FoodtrackColors.cremeVintage
                    : FoodtrackColors.noirBrule,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

