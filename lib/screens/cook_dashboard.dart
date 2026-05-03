import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../models/app_models.dart';

class CookDashboard extends StatelessWidget {
  const CookDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final myCookProfile = state.cooks.firstWhere((c) => c.id == 0);
    final myOrders = state.orders.where((o) => o.cookId == 0).toList();
    final earnings = myOrders.where((o) => o.status == 'completed').fold<double>(0, (sum, o) => sum + o.total);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context, state, myCookProfile),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPulseCard(state, myOrders),
                  const SizedBox(height: 32),
                  _buildStatsRow(earnings, myCookProfile.rating.toString(), myOrders.length.toString()),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Active Orders', myOrders.where((o) => o.status != 'completed').length.toString()),
                  const SizedBox(height: 16),
                  _buildOrderList(context, state, myOrders),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Top Dishes', myCookProfile.menu.length.toString()),
                  const SizedBox(height: 16),
                  _buildMenuList(context, state, myCookProfile),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDishSheet(context, state, myCookProfile.id),
        backgroundColor: Colors.black,
        icon: const Icon(Icons.add, color: AppTheme.accent),
        label: const Text('NEW DISH', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.2)),
      ),
    );
  }

  Widget _buildPulseCard(AppState state, List<Order> orders) {
    final pendingCount = orders.where((o) => o.status == 'placed').length;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('KITCHEN PULSE', style: TextStyle(color: AppTheme.accent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                const SizedBox(height: 8),
                Text(
                  pendingCount > 0 ? '$pendingCount New Orders!' : 'All Caught Up!',
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  state.isAvailable ? 'Your kitchen is visible to neighbors' : 'Kitchen is currently closed',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.accent.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: Icon(state.isAvailable ? Icons.flash_on : Icons.flash_off, color: AppTheme.accent),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, AppState state, Cook cook) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: AppTheme.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primary, AppTheme.primary.withValues(alpha: 0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Text(cook.avatar, style: const TextStyle(fontSize: 30)),
              ),
              const SizedBox(height: 12),
              Text(cook.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
              Text(state.isAvailable ? 'ONLINE · Receiving Orders' : 'OFFLINE · Not Visible', 
                   style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.swap_horiz, color: Colors.white),
        onPressed: () {
          state.switchRole(UserRole.consumer);
          Navigator.pushReplacementNamed(context, '/home');
        },
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Switch(
            value: state.isAvailable,
            onChanged: (val) => state.toggleAvailability(),
            activeThumbColor: Colors.white,
            activeTrackColor: AppTheme.success,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(double earnings, String rating, String totalOrders) {
    return Row(
      children: [
        _buildStatBox('Earnings', '₹${earnings.round()}', Icons.account_balance_wallet, AppTheme.secondary),
        const SizedBox(width: 12),
        _buildStatBox('Rating', rating, Icons.star, AppTheme.accent),
        const SizedBox(width: 12),
        _buildStatBox('Orders', totalOrders, Icons.shopping_bag, AppTheme.primary),
      ],
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String count) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: AppTheme.bg, borderRadius: BorderRadius.circular(10)),
          child: Text(count, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary)),
        ),
      ],
    );
  }

  Widget _buildOrderList(BuildContext context, AppState state, List<Order> orders) {
    final active = orders.where((o) => o.status != 'completed').toList();
    if (active.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: AppTheme.bg, borderRadius: BorderRadius.circular(20)),
        child: const Column(
          children: [
            Icon(Icons.restaurant, color: AppTheme.textMuted, size: 40),
            SizedBox(height: 12),
            Text('No active orders right now', style: TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }
    return Column(children: active.map((o) => _buildOrderCard(context, state, o)).toList());
  }

  Widget _buildOrderCard(BuildContext context, AppState state, Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(color: AppTheme.bg, shape: BoxShape.circle),
                  child: const Center(child: Icon(Icons.person, color: AppTheme.textMuted)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      Text('Order #${order.id} · ${order.items.length} items', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                    ],
                  ),
                ),
                _buildStatusChip(order.status),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TOTAL EARNING', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                    Text('₹${order.total.round()}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppTheme.success)),
                  ],
                ),
                _buildOrderActions(context, state, order),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'placed': color = AppTheme.primary; break;
      case 'accepted': color = AppTheme.secondary; break;
      case 'cooking': color = AppTheme.accent; break;
      case 'ready': color = AppTheme.success; break;
      default: color = AppTheme.textMuted;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900)),
    );
  }

  Widget _buildOrderActions(BuildContext context, AppState state, Order order) {
    String label;
    String next;
    Color color;

    if (order.status == 'placed') { label = 'ACCEPT'; next = 'accepted'; color = AppTheme.primary; }
    else if (order.status == 'accepted') { label = 'COOK'; next = 'cooking'; color = AppTheme.secondary; }
    else if (order.status == 'cooking') { label = 'READY'; next = 'ready'; color = AppTheme.success; }
    else if (order.status == 'ready') { label = 'COMPLETE'; next = 'completed'; color = AppTheme.accent; }
    else { return const SizedBox.shrink(); }

    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pushNamed(context, '/tracking'),
          icon: const Icon(Icons.chat_bubble_outline, color: AppTheme.primary, size: 20),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => state.updateStatusPublic(order.id, next),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            minimumSize: const Size(0, 36),
          ),
          child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildMenuList(BuildContext context, AppState state, Cook cook) {
    return Column(
      children: cook.menu.map((dish) => _buildDishTile(context, state, cook.id, dish)).toList(),
    );
  }

  Widget _buildDishTile(BuildContext context, AppState state, int cookId, Dish dish) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(dish.emoji, style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dish.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                Text('₹${dish.price}', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => state.removeDishFromMenu(cookId, dish.id),
            icon: const Icon(Icons.delete_outline, color: AppTheme.danger, size: 20),
          ),
        ],
      ),
    );
  }

  void _showAddDishSheet(BuildContext context, AppState state, int cookId) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final emojiController = TextEditingController(text: '🍲');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add New Dish', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 24),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Dish Name', hintText: 'e.g. Special Paneer Thali')),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: TextField(controller: priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price', prefixText: '₹ '))),
                const SizedBox(width: 16),
                Expanded(child: TextField(controller: emojiController, decoration: const InputDecoration(labelText: 'Emoji'))),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && priceController.text.isNotEmpty) {
                  final newDish = Dish(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    price: double.parse(priceController.text),
                    emoji: emojiController.text,
                    desc: 'Freshly prepared home cooked meal',
                    rating: 5.0,
                    orders: 0,
                    veg: true,
                    bg: '#FFFFFF',
                    hbg: '',
                    ingredients: '',
                    allergens: [],
                    nutri: [],
                  );
                  state.addDishToMenu(cookId, newDish);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add to Menu'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
