import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../models/app_models.dart';

class DishDetailScreen extends StatefulWidget {
  final Cook cook;
  final Dish dish;

  const DishDetailScreen({super.key, required this.cook, required this.dish});

  @override
  State<DishDetailScreen> createState() => _DishDetailScreenState();
}

class _DishDetailScreenState extends State<DishDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleSection(),
                      const SizedBox(height: 24),
                      _buildIngredientsSection(),
                      const SizedBox(height: 24),
                      _buildNutritionSection(),
                      const SizedBox(height: 24),
                      _buildAllergyWarning(),
                      const SizedBox(height: 24),
                      _buildPickupSection(),
                      const SizedBox(height: 100), // Space for bottom bar
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppTheme.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primary, AppTheme.accent],
            ),
          ),
          child: Center(
            child: Text(
              widget.dish.emoji,
              style: const TextStyle(fontSize: 80),
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.dish.name,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
            ),
            Text(
              '₹${widget.dish.price}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.primary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'By ${widget.cook.short} · ${widget.cook.distance} km',
          style: const TextStyle(fontSize: 14, color: AppTheme.textMuted, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Text(
          widget.dish.desc,
          style: const TextStyle(fontSize: 16, color: AppTheme.text, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildIngredientsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('INGREDIENTS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
        const SizedBox(height: 8),
        Text(widget.dish.ingredients, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildNutritionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('NUTRITION (PER PORTION)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
        const SizedBox(height: 12),
        Row(
          children: widget.dish.nutri.map((n) => Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: [
                  Text(n.v, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(n.l, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                ],
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildAllergyWarning() {
    final state = context.watch<AppState>();
    final conflicts = widget.dish.allergens.where((a) => state.allergies.contains(a)).toList();
    
    if (conflicts.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.danger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.danger.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Contains ${conflicts.join(', ')} — you declared an allergy',
              style: const TextStyle(color: AppTheme.danger, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('PICKUP DETAILS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              const CircleAvatar(backgroundColor: AppTheme.bg, child: Icon(Icons.access_time, color: AppTheme.text)),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Today, 1:00 PM – 1:15 PM', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Pickup at her place', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                  ],
                ),
              ),
              Text('${widget.cook.walkMin} min walk', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.secondary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppTheme.border)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            _buildQuantitySelector(),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  context.read<AppState>().addToCart(widget.cook, widget.dish, _quantity);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added $_quantity x ${widget.dish.name} to cart'),
                      action: SnackBarAction(label: 'VIEW CART', onPressed: () => Navigator.pushNamed(context, '/cart')),
                    ),
                  );
                },
                child: Text('Add to Cart · ₹${widget.dish.price * _quantity}'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          IconButton(onPressed: () => setState(() => _quantity = (_quantity > 1 ? _quantity - 1 : 1)), icon: const Icon(Icons.remove)),
          Text('$_quantity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          IconButton(onPressed: () => setState(() => _quantity++), icon: const Icon(Icons.add)),
        ],
      ),
    );
  }
}
