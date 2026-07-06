import 'package:flutter/material.dart';
import 'package:foodtruck_app/domain/foodtruck.dart';
import 'package:foodtruck_app/domain/menu_item.dart';
import 'package:foodtruck_app/theme/colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FoodtruckDetailScreen extends StatefulWidget {
  const FoodtruckDetailScreen({
    super.key,
    required this.foodtruck,
  });

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FoodtrackColors.cremeVintage,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: FoodtrackColors.cremeVintage,
            foregroundColor: FoodtrackColors.noirBrule,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  color: _getAccentColor(),
                  border: const Border(
                    bottom: BorderSide(
                      color: FoodtrackColors.noirBrule,
                      width: 3,
                    ),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.fastfood,
                    size: 80,
                    color: FoodtrackColors.cremeVintage,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
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
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.foodtruck.name,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: FoodtrackColors.noirBrule,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: widget.foodtruck.isCurrentlyOpen
                                    ? FoodtrackColors.vertPickle
                                    : FoodtrackColors.noirBrule.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: FoodtrackColors.noirBrule,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 10,
                                    color: widget.foodtruck.isCurrentlyOpen
                                        ? FoodtrackColors.cremeVintage
                                        : FoodtrackColors.noirBrule
                                            .withOpacity(0.3),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    widget.foodtruck.isCurrentlyOpen
                                        ? 'OUVERT'
                                        : 'FERME',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
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
                                fontWeight: FontWeight.w700,
                                color: FoodtrackColors.noirBrule,
                              ),
                            ),
                          ),
                        ],
                        if (widget.foodtruck.description != null &&
                            widget.foodtruck.description!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            widget.foodtruck.description!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: FoodtrackColors.noirBrule.withOpacity(0.8),
                              height: 1.4,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 18,
                              color: FoodtrackColors.rougeKetchup,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.foodtruck.status,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: FoodtrackColors.noirBrule,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tabs
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
                        color: FoodtrackColors.rougeKetchup,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: FoodtrackColors.noirBrule,
                          width: 2,
                        ),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorPadding: const EdgeInsets.all(4),
                      labelStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      tabs: const [
                        Tab(text: 'MENU'),
                        Tab(text: 'HORAIRES'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tab content
                  SizedBox(
                    height: 500,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildMenuTab(),
                        _buildHoursTab(),
                      ],
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
        child: CircularProgressIndicator(
          color: FoodtrackColors.rougeKetchup,
        ),
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
          ],
        ),
      );
    }

    // Group items by category
    final categories = <String, List<MenuItem>>{};
    for (final item in _menuItems) {
      final cat = item.category ?? 'Autre';
      categories.putIfAbsent(cat, () => []).add(item);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
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
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: FoodtrackColors.jauneMoutarde,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              ...items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: item.isAvailable
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.4),
                                  decoration: item.isAvailable
                                      ? TextDecoration.none
                                      : TextDecoration.lineThrough,
                                ),
                              ),
                              if (item.description != null &&
                                  item.description!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  item.description!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: item.isAvailable
                                        ? Colors.white.withOpacity(0.7)
                                        : Colors.white.withOpacity(0.3),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: item.isAvailable
                                ? FoodtrackColors.vertPickle
                                : FoodtrackColors.noirBrule.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.priceFormatted,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: item.isAvailable
                                  ? FoodtrackColors.cremeVintage
                                  : FoodtrackColors.cremeVintage.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
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
      child: ListView.builder(
        itemCount: days.length,
        itemBuilder: (context, index) {
          final (dayName, dayKey) = days[index];
          final hours = widget.foodtruck.openingHours?[dayKey];
          final isToday = widget.foodtruck.isCurrentlyOpen;
          final currentDayOfWeek = DateTime.now().weekday - 1; // 0 = Monday
          final isCurrentDay = index == currentDayOfWeek;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isCurrentDay
                  ? FoodtrackColors.vertPickle
                  : FoodtrackColors.cremeVintage,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: FoodtrackColors.noirBrule,
                width: 2,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (isCurrentDay) ...[
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: const BoxDecoration(
                          color: FoodtrackColors.cremeVintage,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                    Text(
                      dayName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isCurrentDay
                            ? FoodtrackColors.cremeVintage
                            : FoodtrackColors.noirBrule,
                      ),
                    ),
                    if (isCurrentDay && isToday) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: FoodtrackColors.cremeVintage,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isToday ? 'OUVERT' : 'FERME',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: FoodtrackColors.vertPickle,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  hours != null
                      ? '${hours.openTime} - ${hours.closeTime}'
                      : 'Ferme',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isCurrentDay
                        ? FoodtrackColors.cremeVintage
                        : FoodtrackColors.noirBrule.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getAccentColor() {
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
}
