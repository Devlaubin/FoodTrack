import 'package:flutter/material.dart';
import 'package:foodtruck_app/domain/foodtruck.dart';
import 'package:foodtruck_app/domain/menu_item.dart';
import 'package:foodtruck_app/theme/colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FoodtruckDetailScreen extends StatefulWidget {
  const FoodtruckDetailScreen({super.key, required this.foodtruck});

  final FoodTruck foodtruck;

  @override
  State<FoodtruckDetailScreen> createState() => _FoodtruckDetailScreenState();
}

class _FoodtruckDetailScreenState extends State<FoodtruckDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  List<MenuItem> _menuItems = [];
  bool _isLoadingMenu = true;
  String? _menuError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    _loadMenuItems();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMenuItems() async {
    try {
      final response = await Supabase.instance.client
          .from('menu_items')
          .select()
          .eq('foodtruck_id', widget.foodtruck.id)
          .order('category')
          .order('name');

      setState(() {
        _menuItems = response
            .map<MenuItem>((json) => MenuItem.fromJson(json))
            .toList();
        _isLoadingMenu = false;
      });
    } catch (e) {
      setState(() {
        _menuError = 'Impossible de charger le menu';
        _isLoadingMenu = false;
      });
    }
  }

  Color get _accentColor {
    switch (widget.foodtruck.cuisineType?.toLowerCase()) {
      case 'burger':
        return FoodtrackColors.rougeKetchup;
      case 'tacos':
        return FoodtrackColors.vertPickle;
      case 'pizza':
        return FoodtrackColors.jauneMoutarde;
      case 'french':
        return FoodtrackColors.noirBrule;
      case 'crepes':
        return FoodtrackColors.jauneMoutarde;
      case 'falafel':
        return FoodtrackColors.vertPickle;
      case 'asian':
        return FoodtrackColors.rougeKetchup;
      case 'bbq':
        return FoodtrackColors.rougeKetchup;
      default:
        return FoodtrackColors.rougeKetchup;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FoodtrackColors.cremeVintage,
      body: CustomScrollView(
        slivers: [
          // Banner header
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: FoodtrackColors.cremeVintage,
            foregroundColor: FoodtrackColors.cremeVintage,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_accentColor, _accentColor.withOpacity(0.8)],
                  ),
                  border: const Border(
                    bottom: BorderSide(
                      color: FoodtrackColors.noirBrule,
                      width: 3,
                    ),
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative pattern
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Icon(
                        widget.foodtruck.logoIcon,
                        size: 160,
                        color: FoodtrackColors.cremeVintage.withOpacity(0.15),
                      ),
                    ),
                    Positioned(
                      left: -20,
                      bottom: -20,
                      child: Icon(
                        widget.foodtruck.logoIcon,
                        size: 100,
                        color: FoodtrackColors.cremeVintage.withOpacity(0.1),
                      ),
                    ),
                    // Main icon
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: FoodtrackColors.cremeVintage,
                          borderRadius: BorderRadius.circular(22),
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
                        child: Icon(
                          widget.foodtruck.logoIcon,
                          size: 44,
                          color: _accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---- Info card ----
                  Container(
                    width: double.infinity,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name + status
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                widget.foodtruck.name,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: FoodtrackColors.noirBrule,
                                  height: 1.1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: widget.foodtruck.isCurrentlyOpen
                                    ? FoodtrackColors.vertPickle
                                    : FoodtrackColors.noirBrule.withOpacity(
                                        0.1,
                                      ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: FoodtrackColors.noirBrule,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: widget.foodtruck.isCurrentlyOpen
                                          ? FoodtrackColors.cremeVintage
                                          : FoodtrackColors.noirBrule
                                                .withOpacity(0.3),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    widget.foodtruck.isCurrentlyOpen
                                        ? 'OUVERT'
                                        : 'FERME',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: widget.foodtruck.isCurrentlyOpen
                                          ? FoodtrackColors.cremeVintage
                                          : FoodtrackColors.noirBrule
                                                .withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Cuisine type
                        if (widget.foodtruck.cuisineType != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: FoodtrackColors.jauneMoutarde,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: FoodtrackColors.noirBrule,
                                width: 2,
                              ),
                            ),
                            child: Text(
                              widget.foodtruck.cuisineType!.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: FoodtrackColors.noirBrule,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],

                        // Description
                        if (widget.foodtruck.description != null &&
                            widget.foodtruck.description!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: FoodtrackColors.cremeVintage,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: FoodtrackColors.noirBrule.withOpacity(
                                  0.3,
                                ),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.format_quote,
                                  size: 18,
                                  color: FoodtrackColors.rougeKetchup
                                      .withOpacity(0.4),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.foodtruck.description!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: FoodtrackColors.noirBrule
                                          .withOpacity(0.8),
                                      height: 1.4,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),

                        // Location + hours row
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: FoodtrackColors.cremeVintage,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: FoodtrackColors.noirBrule.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 18,
                                color: FoodtrackColors.rougeKetchup,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  widget.foodtruck.status,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: FoodtrackColors.noirBrule,
                                  ),
                                ),
                              ),
                              if (widget.foodtruck.getTodayHours() != null) ...[
                                Container(
                                  width: 1,
                                  height: 20,
                                  color: FoodtrackColors.noirBrule.withOpacity(
                                    0.2,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: widget.foodtruck.isCurrentlyOpen
                                      ? FoodtrackColors.vertPickle
                                      : FoodtrackColors.noirBrule.withOpacity(
                                          0.5,
                                        ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.foodtruck.getTodayHours()!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: widget.foodtruck.isCurrentlyOpen
                                        ? FoodtrackColors.vertPickle
                                        : FoodtrackColors.noirBrule.withOpacity(
                                            0.6,
                                          ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ---- Tabs ----
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: FoodtrackColors.noirBrule,
                        width: 2,
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: FoodtrackColors.cremeVintage,
                      unselectedLabelColor: FoodtrackColors.noirBrule,
                      indicator: BoxDecoration(
                        color: _accentColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: FoodtrackColors.noirBrule,
                          width: 2,
                        ),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorPadding: const EdgeInsets.all(4),
                      labelStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.restaurant_menu,
                                size: 18,
                                color: _tabController.index == 0
                                    ? FoodtrackColors.cremeVintage
                                    : FoodtrackColors.noirBrule,
                              ),
                              const SizedBox(width: 6),
                              const Text('MENU'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 18,
                                color: _tabController.index == 1
                                    ? FoodtrackColors.cremeVintage
                                    : FoodtrackColors.noirBrule,
                              ),
                              const SizedBox(width: 6),
                              const Text('HORAIRES'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tab content
                  SizedBox(
                    height: 500,
                    child: TabBarView(
                      controller: _tabController,
                      children: [_buildMenuTab(), _buildHoursTab()],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTab() {
    if (_isLoadingMenu) {
      return const Center(
        child: CircularProgressIndicator(color: FoodtrackColors.rougeKetchup),
      );
    }

    if (_menuError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: FoodtrackColors.rougeKetchup.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _menuError!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: FoodtrackColors.noirBrule,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMenuItems,
              style: ElevatedButton.styleFrom(
                backgroundColor: FoodtrackColors.rougeKetchup,
                foregroundColor: FoodtrackColors.cremeVintage,
              ),
              child: const Text('Reessayer'),
            ),
          ],
        ),
      );
    }

    if (_menuItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 64,
              color: FoodtrackColors.noirBrule.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'Menu non disponible',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: FoodtrackColors.noirBrule,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ce foodtruck n\'a pas encore ajoute son menu.',
              style: TextStyle(
                fontSize: 14,
                color: FoodtrackColors.noirBrule.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    // Group items by category
    final categories = <String, List<MenuItem>>{};
    for (final item in _menuItems) {
      final cat = item.category ?? 'Plat';
      categories.putIfAbsent(cat, () => []).add(item);
    }

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, categoryIndex) {
          final entry = categories.entries.elementAt(categoryIndex);
          final category = entry.key;
          final items = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (categoryIndex > 0) const SizedBox(height: 20),
              // Category header
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _accentColor,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      category.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: FoodtrackColors.noirBrule,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              // Menu items
              ...items.map(
                (item) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: item.isAvailable
                        ? FoodtrackColors.cremeVintage
                        : FoodtrackColors.cremeVintage.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: item.isAvailable
                          ? FoodtrackColors.noirBrule.withOpacity(0.3)
                          : FoodtrackColors.noirBrule.withOpacity(0.15),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Item details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (!item.isAvailable)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: FoodtrackColors.rougeKetchup
                                            .withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'INDISPONIBLE',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: FoodtrackColors.rougeKetchup,
                                        ),
                                      ),
                                    ),
                                  ),
                                Expanded(
                                  child: Text(
                                    item.name,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: item.isAvailable
                                          ? FoodtrackColors.noirBrule
                                          : FoodtrackColors.noirBrule
                                                .withOpacity(0.4),
                                      decoration: item.isAvailable
                                          ? TextDecoration.none
                                          : TextDecoration.lineThrough,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (item.description != null &&
                                item.description!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                item.description!,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: item.isAvailable
                                      ? FoodtrackColors.noirBrule.withOpacity(
                                          0.6,
                                        )
                                      : FoodtrackColors.noirBrule.withOpacity(
                                          0.3,
                                        ),
                                  fontStyle: FontStyle.italic,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Price
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: item.isAvailable
                              ? _accentColor
                              : FoodtrackColors.noirBrule.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: FoodtrackColors.noirBrule,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          item.priceFormatted,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: item.isAvailable
                                ? FoodtrackColors.cremeVintage
                                : FoodtrackColors.noirBrule.withOpacity(0.4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHoursTab() {
    final days = [
      ('Lundi', 'monday'),
      ('Mardi', 'tuesday'),
      ('Mercredi', 'wednesday'),
      ('Jeudi', 'thursday'),
      ('Vendredi', 'friday'),
      ('Samedi', 'saturday'),
      ('Dimanche', 'sunday'),
    ];

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
      child: ListView.builder(
        itemCount: days.length,
        itemBuilder: (context, index) {
          final (dayName, dayKey) = days[index];
          final hours = widget.foodtruck.openingHours?[dayKey];
          final currentDayOfWeek = DateTime.now().weekday - 1;
          final isCurrentDay = index == currentDayOfWeek;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isCurrentDay ? _accentColor : FoodtrackColors.cremeVintage,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: FoodtrackColors.noirBrule,
                width: isCurrentDay ? 2 : 1.5,
              ),
              boxShadow: isCurrentDay
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
              children: [
                // Day indicator
                if (isCurrentDay)
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: const BoxDecoration(
                      color: FoodtrackColors.cremeVintage,
                      shape: BoxShape.circle,
                    ),
                  ),
                // Day name
                SizedBox(
                  width: 80,
                  child: Text(
                    dayName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isCurrentDay
                          ? FoodtrackColors.cremeVintage
                          : FoodtrackColors.noirBrule,
                    ),
                  ),
                ),
                // Hours
                Expanded(
                  child: Text(
                    hours != null
                        ? '${hours.openTime} - ${hours.closeTime}'
                        : 'Ferme',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isCurrentDay
                          ? FoodtrackColors.cremeVintage
                          : hours != null
                          ? FoodtrackColors.noirBrule
                          : FoodtrackColors.noirBrule.withOpacity(0.4),
                    ),
                  ),
                ),
                // "Aujourd'hui" badge
                if (isCurrentDay) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: FoodtrackColors.cremeVintage,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "AUJOURD'HUI",
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: _accentColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
