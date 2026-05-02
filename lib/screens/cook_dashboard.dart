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
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, state),
              const SizedBox(height: 32),
              _buildStats(state),
              const SizedBox(height: 32),
              _buildOrderSection(context, state),
              const SizedBox(height: 32),
              _buildMenuSection(context, state),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddItemDialog(context),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add),
        label: const Text('Add Dish', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome back, ${state.userName?.split(' ')[0] ?? 'Chef'}!', 
                 style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(state.isAvailable ? 'You are receiving orders' : 'You are currently offline', 
                 style: TextStyle(color: state.isAvailable ? AppTheme.success : AppTheme.textMuted, fontSize: 13)),
          ],
        ),
        _buildAvailabilityToggle(state),
      ],
    );
  }

  Widget _buildAvailabilityToggle(AppState state) {
    return Column(
      children: [
        Switch(
          value: state.isAvailable,
          onChanged: (val) => state.toggleAvailability(),
          activeColor: AppTheme.success,
        ),
        Text(state.isAvailable ? 'ONLINE' : 'OFFLINE', 
             style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: state.isAvailable ? AppTheme.success : AppTheme.textMuted)),
      ],
    );
  }

  Widget _buildStats(AppState state) {
    return Row(
      children: [
        _buildStatCard('Earnings', '₹4,820', Icons.account_balance_wallet, AppTheme.secondary),
        const SizedBox(width: 16),
        _buildStatCard('Rating', '4.9', Icons.star, AppTheme.accent),
        const SizedBox(width: 16),
        _buildStatCard('Orders', '124', Icons.shopping_bag, AppTheme.primary),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSection(BuildContext context, AppState state) {
    final activeOrders = state.orders.where((o) => o.status != 'completed').toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Active Orders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(onPressed: () {}, child: const Text('View All')),
          ],
        ),
        if (activeOrders.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: Text('No active orders', style: TextStyle(color: AppTheme.textMuted))),
          )
        else
          ...activeOrders.map((o) => _buildOrderTile(context, state, o)),
      ],
    );
  }

  Widget _buildOrderTile(BuildContext context, AppState state, Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order #${order.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(order.items.map((i) => '${i.qty}x ${i.name}').join(', '), 
                     style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
              ],
            ),
          ),
          _buildStatusButton(state, order),
        ],
      ),
    );
  }

  Widget _buildStatusButton(AppState state, Order order) {
    String nextLabel;
    String nextStatus;
    Color color;

    switch (order.status) {
      case 'placed':
        nextLabel = 'Accept';
        nextStatus = 'accepted';
        color = AppTheme.primary;
        break;
      case 'accepted':
        nextLabel = 'Start Cooking';
        nextStatus = 'cooking';
        color = AppTheme.accent;
        break;
      case 'cooking':
        nextLabel = 'Mark Ready';
        nextStatus = 'ready';
        color = AppTheme.success;
        break;
      default:
        return const Text('READY', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.success));
    }

    return ElevatedButton(
      onPressed: () => state.updateStatusPublic(order.id, nextStatus),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(nextLabel, style: const TextStyle(fontSize: 11)),
    );
  }

  Widget _buildMenuSection(BuildContext context, AppState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Your Menu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        // Mock menu for the current cook
        _buildMenuTile('Rajma + Rice', '₹110', '🍛'),
        _buildMenuTile('Palak Paneer', '₹140', '🥘'),
      ],
    );
  }

  Widget _buildMenuTile(String name, String price, String emoji) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(color: AppTheme.bg, borderRadius: BorderRadius.circular(10)),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(price, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
      trailing: const Icon(Icons.edit_outlined, size: 20),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Dish'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: InputDecoration(hintText: 'Dish Name')),
            SizedBox(height: 12),
            TextField(decoration: InputDecoration(hintText: 'Price (₹)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Save')),
        ],
      ),
    );
  }
}
