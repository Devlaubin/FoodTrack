import 'package:flutter/material.dart';
import 'package:foodtruck_app/domain/foodtruck.dart';
import 'package:foodtruck_app/domain/foodtruck_icons.dart';
import 'package:foodtruck_app/domain/menu_item.dart';
import 'package:foodtruck_app/services/auth_service.dart';
import 'package:foodtruck_app/services/pro_service.dart';
import 'package:foodtruck_app/theme/colors.dart';
import 'package:provider/provider.dart';

class ProDashboardScreen extends StatefulWidget {
  const ProDashboardScreen({super.key});

  @override
  State<ProDashboardScreen> createState() => _ProDashboardScreenState();
}

class _ProDashboardScreenState extends State<ProDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ownerId = context.read<AuthService>().user?.id;
      if (ownerId != null) {
        context.read<ProService>().loadMyFoodtruck(ownerId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FoodtrackColors.cremeVintage,
      appBar: AppBar(title: const Text('Espace Pro')),
      body: Consumer<ProService>(
        builder: (context, pro, child) {
          if (pro.isLoading && pro.myFoodtruck == null) {
            return const Center(
              child: CircularProgressIndicator(
                color: FoodtrackColors.rougeKetchup,
              ),
            );
          }

          if (pro.myFoodtruck == null) {
            return const _CreateFoodtruckForm();
          }

          return Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: FoodtrackColors.noirBrule,
                      width: 2,
                    ),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: FoodtrackColors.rougeKetchup,
                  unselectedLabelColor: FoodtrackColors.noirBrule,
                  indicatorColor: FoodtrackColors.rougeKetchup,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                  tabs: const [
                    Tab(text: 'INFOS & GPS'),
                    Tab(text: 'MENU'),
                    Tab(text: 'HORAIRES'),
                  ],
                ),
              ),
              if (pro.error != null)
                Container(
                  width: double.infinity,
                  color: FoodtrackColors.rougeKetchup.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    pro.error!,
                    style: const TextStyle(color: FoodtrackColors.rougeKetchup),
                  ),
                ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const [_InfoAndGpsTab(), _MenuTab(), _HoursTab()],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Reusable icon picker widget for selecting a foodtruck logo.
class _IconPicker extends StatelessWidget {
  const _IconPicker({
    required this.selectedIconId,
    required this.onIconSelected,
  });

  final String? selectedIconId;
  final ValueChanged<String> onIconSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choisis ton logo',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: FoodtrackColors.noirBrule,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          // Limit height to about 3 rows of icons
          height: 150,
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: foodtruckIcons.map((fi) {
                final isSelected = fi.id == selectedIconId;
                return GestureDetector(
                  onTap: () => onIconSelected(fi.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? FoodtrackColors.rougeKetchup
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: FoodtrackColors.noirBrule,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          fi.icon,
                          size: 20,
                          color: isSelected
                              ? FoodtrackColors.cremeVintage
                              : FoodtrackColors.noirBrule,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          fi.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? FoodtrackColors.cremeVintage
                                : FoodtrackColors.noirBrule,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _CreateFoodtruckForm extends StatefulWidget {
  const _CreateFoodtruckForm();

  @override
  State<_CreateFoodtruckForm> createState() => _CreateFoodtruckFormState();
}

class _CreateFoodtruckFormState extends State<_CreateFoodtruckForm> {
  int _currentStep = 0;
  final _nameController = TextEditingController();
  final _cuisineController = TextEditingController();
  String? _selectedIconId;
  bool _isSubmitting = false;

  static const int _totalSteps = 3;

  @override
  void dispose() {
    _nameController.dispose();
    _cuisineController.dispose();
    super.dispose();
  }

  bool get _canGoNext {
    switch (_currentStep) {
      case 0:
        return _nameController.text.trim().isNotEmpty;
      case 1:
        return _selectedIconId != null;
      case 2:
        return true;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty) return;

    setState(() => _isSubmitting = true);

    final ownerId = context.read<AuthService>().user?.id;
    if (ownerId != null) {
      await context.read<ProService>().createMyFoodtruck(
        ownerId: ownerId,
        name: _nameController.text.trim(),
        cuisineType: _cuisineController.text.trim().isEmpty
            ? null
            : _cuisineController.text.trim(),
      );

      // If an icon was selected, update it after creation
      if (_selectedIconId != null) {
        await context.read<ProService>().updateInfo(imageUrl: _selectedIconId);
      }
    }

    if (mounted) setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          const Text(
            'Cree ta fiche foodtruck',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: FoodtrackColors.noirBrule,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ceci te permettra d\'apparaitre sur la carte et de gerer ton menu.',
            style: TextStyle(color: FoodtrackColors.noirBrule.withOpacity(0.7)),
          ),
          const SizedBox(height: 20),

          // Step indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_totalSteps, (index) {
              final isActive = index == _currentStep;
              final isCompleted = index < _currentStep;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? FoodtrackColors.vertPickle
                          : isActive
                              ? FoodtrackColors.rougeKetchup
                              : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: FoodtrackColors.noirBrule,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              color: FoodtrackColors.cremeVintage,
                              size: 20,
                            )
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: isActive
                                    ? FoodtrackColors.cremeVintage
                                    : FoodtrackColors.noirBrule,
                              ),
                            ),
                    ),
                  ),
                  if (index < _totalSteps - 1)
                    Container(
                      width: 40,
                      height: 2,
                      color: index < _currentStep
                          ? FoodtrackColors.vertPickle
                          : FoodtrackColors.noirBrule.withOpacity(0.2),
                    ),
                ],
              );
            }),
          ),
          const SizedBox(height: 20),

          // Step labels
          Center(
            child: Text(
              _stepLabel,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: FoodtrackColors.noirBrule,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Step content
          _buildStepContent(),
          const SizedBox(height: 24),

          // Navigation buttons
          Row(
            children: [
              if (_currentStep > 0)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _prevStep,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: FoodtrackColors.noirBrule,
                      side: const BorderSide(
                        color: FoodtrackColors.noirBrule,
                        width: 2,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text(
                      'Precedent',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              if (_currentStep > 0) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _currentStep == _totalSteps - 1
                      ? (_isSubmitting ? null : _submit)
                      : (_canGoNext ? _nextStep : null),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FoodtrackColors.rougeKetchup,
                    foregroundColor: FoodtrackColors.cremeVintage,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: FoodtrackColors.cremeVintage,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentStep == _totalSteps - 1
                                  ? 'Creer'
                                  : 'Suivant',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (_currentStep < _totalSteps - 1) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, size: 18),
                            ],
                          ],
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String get _stepLabel {
    switch (_currentStep) {
      case 0:
        return 'Étape 1 : Nom & Type de cuisine';
      case 1:
        return 'Étape 2 : Choisis ton logo';
      case 2:
        return 'Étape 3 : Resume et creation';
      default:
        return '';
    }
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: FoodtrackColors.noirBrule,
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informations de base',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: FoodtrackColors.noirBrule,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Nom du foodtruck *',
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: FoodtrackColors.rougeKetchup,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _cuisineController,
                    decoration: InputDecoration(
                      labelText: 'Type de cuisine (ex: burger, tacos...)',
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: FoodtrackColors.rougeKetchup,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      case 1:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: FoodtrackColors.noirBrule,
              width: 2,
            ),
          ),
          child: _IconPicker(
            selectedIconId: _selectedIconId,
            onIconSelected: (id) {
              setState(() => _selectedIconId = id);
            },
          ),
        );
      case 2:
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: FoodtrackColors.noirBrule,
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.check_circle,
                      color: FoodtrackColors.vertPickle, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Resume de ta fiche',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: FoodtrackColors.noirBrule,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _resumeRow('Nom', _nameController.text.trim()),
              const Divider(height: 20),
              _resumeRow(
                'Type de cuisine',
                _cuisineController.text.trim().isEmpty
                    ? 'Non specifie'
                    : _cuisineController.text.trim(),
              ),
              const Divider(height: 20),
              _resumeRow(
                'Logo',
                _selectedIconId != null
                    ? foodtruckIcons
                        .firstWhere((f) => f.id == _selectedIconId)
                        .label
                    : 'Aucun',
                icon: _selectedIconId != null
                    ? foodtruckIcons
                        .firstWhere((f) => f.id == _selectedIconId)
                        .icon
                    : null,
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _resumeRow(String label, String value, {IconData? icon}) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: FoodtrackColors.noirBrule.withOpacity(0.7),
            ),
          ),
        ),
        if (icon != null) ...[
          Icon(icon, size: 20, color: FoodtrackColors.rougeKetchup),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: FoodtrackColors.noirBrule,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoAndGpsTab extends StatefulWidget {
  const _InfoAndGpsTab();

  @override
  State<_InfoAndGpsTab> createState() => _InfoAndGpsTabState();
}

class _InfoAndGpsTabState extends State<_InfoAndGpsTab> {
  String? _positionMessage;

  @override
  Widget build(BuildContext context) {
    return Consumer<ProService>(
      builder: (context, pro, child) {
        final ft = pro.myFoodtruck!;

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: FoodtrackColors.noirBrule, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: ft.isCurrentlyOpen
                              ? FoodtrackColors.rougeKetchup
                              : FoodtrackColors.noirBrule.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: FoodtrackColors.noirBrule,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          ft.logoIcon,
                          size: 24,
                          color: ft.isCurrentlyOpen
                              ? FoodtrackColors.cremeVintage
                              : FoodtrackColors.noirBrule.withOpacity(0.3),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        ft.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: FoodtrackColors.noirBrule,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _IconPicker(
                    selectedIconId: ft.imageUrl,
                    onIconSelected: (iconId) {
                      pro.updateInfo(imageUrl: iconId);
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text(
                        'Ouvert actuellement : ',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Switch(
                        value: ft.isOpen,
                        activeColor: FoodtrackColors.vertPickle,
                        onChanged: (value) {
                          pro.updateInfo(isOpen: value);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Position actuelle : ${ft.latitude.toStringAsFixed(5)}, '
                    '${ft.longitude.toStringAsFixed(5)}',
                    style: TextStyle(
                      color: FoodtrackColors.noirBrule.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: pro.isUpdatingPosition
                  ? null
                  : () async {
                      final error = await pro.updateLivePosition();
                      if (!mounted) return;
                      setState(
                        () => _positionMessage =
                            error ?? 'Position mise a jour !',
                      );
                    },
              icon: pro.isUpdatingPosition
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: FoodtrackColors.cremeVintage,
                      ),
                    )
                  : const Icon(Icons.gps_fixed),
              label: const Text(
                'Mettre a jour ma position GPS',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: FoodtrackColors.vertPickle,
                foregroundColor: FoodtrackColors.cremeVintage,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            if (_positionMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _positionMessage!,
                style: TextStyle(
                  color: FoodtrackColors.noirBrule.withOpacity(0.8),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Ton navigateur va demander l\'autorisation d\'acceder a ta '
              'position. La carte des clients se mettra a jour avec ce point.',
              style: TextStyle(
                fontSize: 12,
                color: FoodtrackColors.noirBrule.withOpacity(0.6),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MenuTab extends StatelessWidget {
  const _MenuTab();

  void _showItemForm(BuildContext context, {MenuItem? item}) {
    final nameController = TextEditingController(text: item?.name ?? '');
    final priceController = TextEditingController(
      text: item != null ? item.price.toString() : '',
    );
    final categoryController = TextEditingController(
      text: item?.category ?? '',
    );
    final descriptionController = TextEditingController(
      text: item?.description ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: FoodtrackColors.cremeVintage,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                item == null ? 'Ajouter un article' : 'Modifier l\'article',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Prix (EUR)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: 'Categorie (ex: plat, dessert...)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Description (optionnel)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  final price = double.tryParse(
                    priceController.text.trim().replaceAll(',', '.'),
                  );
                  if (name.isEmpty || price == null) return;

                  final pro = sheetContext.read<ProService>();
                  if (item == null) {
                    await pro.addMenuItem(
                      name: name,
                      price: price,
                      category: categoryController.text.trim().isEmpty
                          ? null
                          : categoryController.text.trim(),
                      description: descriptionController.text.trim().isEmpty
                          ? null
                          : descriptionController.text.trim(),
                    );
                  } else {
                    await pro.updateMenuItem(
                      item.id,
                      name: name,
                      price: price,
                      category: categoryController.text.trim(),
                      description: descriptionController.text.trim(),
                    );
                  }

                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: FoodtrackColors.rougeKetchup,
                  foregroundColor: FoodtrackColors.cremeVintage,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Enregistrer',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProService>(
      builder: (context, pro, child) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: pro.menuItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        size: 56,
                        color: FoodtrackColors.noirBrule.withOpacity(0.3),
                      ),
                      const SizedBox(height: 12),
                      const Text('Aucun article pour le moment'),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                  itemCount: pro.menuItems.length,
                  itemBuilder: (context, index) {
                    final item = pro.menuItems[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: FoodtrackColors.noirBrule,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '${item.priceFormatted} - ${item.category ?? "plat"}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: FoodtrackColors.noirBrule
                                        .withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: item.isAvailable,
                            activeColor: FoodtrackColors.vertPickle,
                            onChanged: (value) {
                              context.read<ProService>().updateMenuItem(
                                item.id,
                                isAvailable: value,
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () => _showItemForm(context, item: item),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: FoodtrackColors.rougeKetchup,
                              size: 20,
                            ),
                            onPressed: () {
                              context.read<ProService>().deleteMenuItem(
                                item.id,
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: FoodtrackColors.rougeKetchup,
            onPressed: () => _showItemForm(context),
            child: const Icon(Icons.add, color: FoodtrackColors.cremeVintage),
          ),
        );
      },
    );
  }
}

class _HoursTab extends StatefulWidget {
  const _HoursTab();

  @override
  State<_HoursTab> createState() => _HoursTabState();
}

class _HoursTabState extends State<_HoursTab> {
  static const _days = [
    ('Lundi', 'monday'),
    ('Mardi', 'tuesday'),
    ('Mercredi', 'wednesday'),
    ('Jeudi', 'thursday'),
    ('Vendredi', 'friday'),
    ('Samedi', 'saturday'),
    ('Dimanche', 'sunday'),
  ];

  final Map<String, TextEditingController> _openControllers = {};
  final Map<String, TextEditingController> _closeControllers = {};
  bool _initialized = false;

  void _initControllers(Map<String, DayHours>? hours) {
    if (_initialized) return;
    for (final (_, key) in _days) {
      final existing = hours?[key];
      _openControllers[key] = TextEditingController(
        text: existing?.openTime ?? '',
      );
      _closeControllers[key] = TextEditingController(
        text: existing?.closeTime ?? '',
      );
    }
    _initialized = true;
  }

  @override
  void dispose() {
    for (final c in _openControllers.values) {
      c.dispose();
    }
    for (final c in _closeControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save(BuildContext context) async {
    final hours = <String, DayHours>{};
    for (final (_, key) in _days) {
      final open = _openControllers[key]!.text.trim();
      final close = _closeControllers[key]!.text.trim();
      if (open.isNotEmpty && close.isNotEmpty) {
        hours[key] = DayHours(openTime: open, closeTime: close);
      }
    }

    final success = await context.read<ProService>().updateOpeningHours(hours);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Horaires mis a jour !' : 'Erreur lors de la sauvegarde',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ft = context.watch<ProService>().myFoodtruck as FoodTruck;
    _initControllers(ft.openingHours);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      children: [
        Text(
          'Format HH:mm (ex: 11:30). Laisse vide pour un jour ferme.',
          style: TextStyle(
            fontSize: 12,
            color: FoodtrackColors.noirBrule.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 12),
        for (final (label, key) in _days)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                SizedBox(width: 90, child: Text(label)),
                Expanded(
                  child: TextField(
                    controller: _openControllers[key],
                    decoration: const InputDecoration(
                      labelText: 'Ouverture',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _closeControllers[key],
                    decoration: const InputDecoration(
                      labelText: 'Fermeture',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => _save(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: FoodtrackColors.rougeKetchup,
            foregroundColor: FoodtrackColors.cremeVintage,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text(
            'Enregistrer les horaires',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
