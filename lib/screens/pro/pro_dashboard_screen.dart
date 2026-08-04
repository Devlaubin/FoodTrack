import 'package:flutter/material.dart';
import 'package:foodtruck_app/domain/foodtruck.dart';
import 'package:foodtruck_app/domain/foodtruck_icons.dart';
import 'package:foodtruck_app/domain/menu_item.dart';
import 'package:foodtruck_app/services/auth_service.dart';
import 'package:foodtruck_app/services/pro_service.dart';
import 'package:foodtruck_app/theme/colors.dart';
import 'package:foodtruck_app/utils/formatters.dart';
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
    _tabController = TabController(length: 4, vsync: this);
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
                    Tab(text: 'PROFIL'),
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
                  children: const [
                    _InfoAndGpsTab(),
                    _MenuTab(),
                    _HoursTab(),
                    _ProfileTab(),
                  ],
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
  final Set<String> _selectedCuisineTypes = {};
  String? _selectedIconId;
  bool _isSubmitting = false;

  static const int _totalSteps = 3;

  @override
  void dispose() {
    _nameController.dispose();
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
        cuisineType: _selectedCuisineTypes.isEmpty
            ? null
            : joinCuisineTypes(_selectedCuisineTypes),
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
                  _CuisineTypeDropdown(
                    selectedTypes: _selectedCuisineTypes,
                    onChanged: (types) {
                      setState(() {
                        _selectedCuisineTypes
                          ..clear()
                          ..addAll(types);
                      });
                    },
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
                _selectedCuisineTypes.isEmpty
                    ? 'Non specifie'
                    : joinCuisineTypes(_selectedCuisineTypes),
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

/// A neo-brutalist multi-select dropdown for choosing cuisine types.
class _CuisineTypeDropdown extends StatelessWidget {
  const _CuisineTypeDropdown({
    required this.selectedTypes,
    required this.onChanged,
  });

  final Set<String> selectedTypes;
  final ValueChanged<Set<String>> onChanged;

  void _toggleType(String type) {
    final updated = Set<String>.from(selectedTypes);
    if (!updated.remove(type)) {
      updated.add(type);
    }
    onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final displayText = selectedTypes.isEmpty
        ? 'Choisis tes types de cuisine (plusieurs possibles)'
        : joinCuisineTypes(selectedTypes);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            showModalBottomSheet<void>(
              context: context,
              backgroundColor: FoodtrackColors.cremeVintage,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              builder: (sheetContext) {
                return StatefulBuilder(
                  builder: (sheetContext, setSheetState) {
                    return DraggableScrollableSheet(
                      expand: false,
                      initialChildSize: 0.6,
                      minChildSize: 0.4,
                      maxChildSize: 0.9,
                      builder: (context, scrollController) {
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  const Text(
                                    'Type de cuisine',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: FoodtrackColors.noirBrule,
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () {
                                      onChanged(const {});
                                    },
                                    child: const Text(
                                      'Tout effacer',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: FoodtrackColors.rougeKetchup,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1, color: FoodtrackColors.noirBrule),
                            Expanded(
                              child: ListView(
                                controller: scrollController,
                                padding: const EdgeInsets.all(16),
                                children: [
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: cuisineTypes.map((type) {
                                      final isSelected = selectedTypes.contains(type);
                                      return GestureDetector(
                                        onTap: () {
                                          setSheetState(() {
                                            _toggleType(type);
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? FoodtrackColors.vertPickle
                                                : Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: FoodtrackColors.noirBrule,
                                              width: isSelected ? 3 : 2,
                                            ),
                                            boxShadow: isSelected
                                                ? const [
                                                    BoxShadow(
                                                      color: FoodtrackColors.noirBrule,
                                                      offset: Offset(2, 2),
                                                      blurRadius: 0,
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (isSelected) ...[
                                                const Icon(
                                                  Icons.check,
                                                  size: 16,
                                                  color: FoodtrackColors.noirBrule,
                                                ),
                                                const SizedBox(width: 6),
                                              ],
                                              Text(
                                                type,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color: isSelected
                                                      ? FoodtrackColors.noirBrule
                                                      : FoodtrackColors.noirBrule
                                                          .withOpacity(0.7),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(sheetContext);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: FoodtrackColors.rougeKetchup,
                                    foregroundColor: FoodtrackColors.cremeVintage,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: const Text(
                                    'Valider',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: FoodtrackColors.noirBrule, width: 2),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: selectedTypes.isEmpty
                          ? FoodtrackColors.noirBrule.withOpacity(0.5)
                          : FoodtrackColors.noirBrule,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_drop_down,
                  color: FoodtrackColors.rougeKetchup,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
        if (selectedTypes.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: selectedTypes.map((type) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: FoodtrackColors.jauneMoutarde,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: FoodtrackColors.noirBrule, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      type,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: FoodtrackColors.noirBrule,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => _toggleType(type),
                      child: const Icon(
                        Icons.close,
                        size: 14,
                        color: FoodtrackColors.noirBrule,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
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

class _ProfileTab extends StatefulWidget {
  const _ProfileTab();

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  late TextEditingController _bioController;
  late TextEditingController _phoneController;
  late TextEditingController _serviceTypeController;
  late TextEditingController _instagramController;
  late TextEditingController _facebookController;
  late TextEditingController _tiktokController;
  late TextEditingController _xController;
  late TextEditingController _websiteController;
  bool _initialized = false;
  bool _saving = false;

  @override
  void dispose() {
    _bioController.dispose();
    _phoneController.dispose();
    _serviceTypeController.dispose();
    _instagramController.dispose();
    _facebookController.dispose();
    _tiktokController.dispose();
    _xController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void _initControllers(FoodTruck ft) {
    if (_initialized) return;
    _bioController = TextEditingController(text: ft.bio ?? '');
    _phoneController = TextEditingController(text: ft.phone ?? '');
    _serviceTypeController = TextEditingController(
      text: ft.serviceType ?? '',
    );
    _instagramController = TextEditingController(
      text: ft.socialInstagram ?? '',
    );
    _facebookController = TextEditingController(text: ft.socialFacebook ?? '');
    _tiktokController = TextEditingController(text: ft.socialTiktok ?? '');
    _xController = TextEditingController(text: ft.socialX ?? '');
    _websiteController = TextEditingController(text: ft.socialWebsite ?? '');
    _initialized = true;
  }

  Future<void> _save(ProService pro) async {
    setState(() => _saving = true);
    final ok = await pro.updateInfo(
      bio: _bioController.text.trim(),
      phone: _phoneController.text.trim(),
      serviceType: _serviceTypeController.text.trim(),
      socialInstagram: _instagramController.text.trim(),
      socialFacebook: _facebookController.text.trim(),
      socialTiktok: _tiktokController.text.trim(),
      socialX: _xController.text.trim(),
      socialWebsite: _websiteController.text.trim(),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? 'Profil mis a jour !'
                : 'Erreur lors de l\'enregistrement du profil',
          ),
          backgroundColor: ok
              ? FoodtrackColors.vertPickle
              : FoodtrackColors.rougeKetchup,
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProService>(
      builder: (context, pro, child) {
        final ft = pro.myFoodtruck!;
        _initControllers(ft);

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          children: [
            // Seniority card
            if (ft.proSince != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: FoodtrackColors.jauneMoutarde,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: FoodtrackColors.noirBrule,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.verified_outlined,
                      color: FoodtrackColors.noirBrule,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Membre FoodTrack depuis '
                        '${Formatters.monthYear(ft.proSince!)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: FoodtrackColors.noirBrule,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Bio / Description
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
                  const Text(
                    'Description complete',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: FoodtrackColors.noirBrule,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _bioController,
                    maxLines: 5,
                    maxLength: 600,
                    decoration: InputDecoration(
                      labelText: 'Parle de ton foodtruck, ton histoire...',
                      alignLabelWithHint: true,
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
                  const SizedBox(height: 8),
                  const Text(
                    'Ce texte sera affiche sur ta fiche publique.',
                    style: TextStyle(
                      fontSize: 11,
                      color: FoodtrackColors.noirBrule,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Contact & services
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
                  const Text(
                    'Contact & services',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: FoodtrackColors.noirBrule,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Telephone (optionnel)',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _serviceTypeController,
                    decoration: InputDecoration(
                      labelText: 'Type de service (sur place, a emporter...)',
                      prefixIcon: const Icon(Icons.storefront_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Social networks
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
                  const Row(
                    children: [
                      Icon(
                        Icons.alternate_email,
                        size: 20,
                        color: FoodtrackColors.rougeKetchup,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Reseaux sociaux',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: FoodtrackColors.noirBrule,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tes liens seront affiches sur ta fiche publique.',
                    style: TextStyle(
                      fontSize: 11,
                      color: FoodtrackColors.noirBrule,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _socialField(
                    controller: _instagramController,
                    label: 'Instagram',
                    hint: '@mon_foodtruck',
                    icon: Icons.photo_camera_outlined,
                  ),
                  const SizedBox(height: 12),
                  _socialField(
                    controller: _facebookController,
                    label: 'Facebook',
                    hint: 'pseudo ou page',
                    icon: Icons.facebook_outlined,
                  ),
                  const SizedBox(height: 12),
                  _socialField(
                    controller: _tiktokController,
                    label: 'TikTok',
                    hint: '@mon_foodtruck',
                    icon: Icons.music_note_outlined,
                  ),
                  const SizedBox(height: 12),
                  _socialField(
                    controller: _xController,
                    label: 'X (Twitter)',
                    hint: '@mon_foodtruck',
                    icon: Icons.alternate_email,
                  ),
                  const SizedBox(height: 12),
                  _socialField(
                    controller: _websiteController,
                    label: 'Site web',
                    hint: 'https://monfoodtruck.fr',
                    icon: Icons.public,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _saving ? null : () => _save(pro),
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: FoodtrackColors.cremeVintage,
                      ),
                    )
                  : const Icon(Icons.save_outlined),
              label: const Text(
                'Enregistrer le profil',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: FoodtrackColors.rougeKetchup,
                foregroundColor: FoodtrackColors.cremeVintage,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _socialField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: FoodtrackColors.rougeKetchup,
            width: 2,
          ),
        ),
      ),
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
