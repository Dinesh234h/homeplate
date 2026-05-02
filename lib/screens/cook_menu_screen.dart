import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../models/app_models.dart';
import 'dish_detail_screen.dart';

class CookMenuScreen extends StatelessWidget {
  final Cook cook;

  const CookMenuScreen({super.key, required this.cook});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cook.tagline, style: const TextStyle(fontSize: 16, color: AppTheme.textMuted)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: AppTheme.accent),
                      const SizedBox(width: 4),
                      Text('${cook.rating} (${cook.ratingCount} reviews)', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      Text('${cook.distance} km away', style: const TextStyle(color: AppTheme.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('HOUSE SPECIALS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildDishCard(context, cook.menu[index]),
                childCount: cook.menu.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
      floatingActionButton: _buildCartBar(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppTheme.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(cook.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white, shadows: [Shadow(blurRadius: 10, color: Colors.black45)])),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [cook.c1, cook.c2], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: Center(child: Text(cook.avatar, style: const TextStyle(fontSize: 80))),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black38],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDishCard(BuildContext context, Dish dish) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DishDetailScreen(cook: cook, dish: dish))),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(dish.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      if (dish.veg) ...[const SizedBox(width: 8), const Icon(Icons.circle, color: Colors.green, size: 10)],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(dish.desc, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted), maxLines: 2),
                  const SizedBox(height: 12),
                  Text('₹${dish.price}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary, fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(color: AppTheme.bg, borderRadius: BorderRadius.circular(16)),
              child: Center(child: Text(dish.emoji, style: const TextStyle(fontSize: 40))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartBar(BuildContext context) {
    final state = context.watch<AppState>();
    if (state.cart.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/cart'),
        backgroundColor: AppTheme.primary,
        label: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
              child: Text('${state.cart.length} ITEMS', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 16),
            const Text('VIEW CART', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(width: 8),
            const Icon(Icons.shopping_bag, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}
