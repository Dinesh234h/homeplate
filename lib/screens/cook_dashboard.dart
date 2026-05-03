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
    final myCookProfile = state.cooks.firstWhere(
      (c) => c.name == state.userName, 
      orElse: () => state.cooks.firstWhere((c) => c.id == 0)
    );
    final myOrders = state.orders.where((o) => o.cookId == myCookProfile.id).toList();
    final earnings = myOrders.where((o) => o.status == 'completed').fold<double>(0, (sum, o) => sum + o.total);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            _buildSliverAppBar(context, state, myCookProfile, state.userName ?? myCookProfile.name),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPulseCard(state, myOrders),
                    const SizedBox(height: 32),
                    _buildStatsRow(state, earnings, myCookProfile.rating.toString(), myOrders.length.toString()),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  labelColor: Colors.black,
                  unselectedLabelColor: AppTheme.textMuted,
                  indicatorColor: AppTheme.accent,
                  indicatorWeight: 4,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                  tabs: [
                    Tab(text: state.tr('active_orders').toUpperCase()),
                    Tab(text: state.tr('upcoming_orders').toUpperCase()),
                    Tab(text: state.tr('past_orders').toUpperCase()),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            children: [
              _buildOrderListView(context, state, myOrders.where((o) => ['placed', 'preparing', 'ready'].contains(o.status)).toList()),
              _buildOrderListView(context, state, myOrders.where((o) => o.status == 'upcoming').toList()),
              _buildOrderListView(context, state, myOrders.where((o) => o.status == 'completed').toList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, AppState state, Cook cook, String displayName) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: Colors.black,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Color(0xFF2D2D2D)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.white,
                child: Text(cook.avatar, style: const TextStyle(fontSize: 30)),
              ),
              const SizedBox(height: 12),
              Text(displayName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
              Text(state.isAvailable ? 'RECEIVING ORDERS' : 'KITCHEN CLOSED', 
                   style: TextStyle(color: state.isAvailable ? AppTheme.success : AppTheme.danger, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
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

  Widget _buildPulseCard(AppState state, List<Order> orders) {
    final pendingCount = orders.where((o) => o.status == 'placed').length;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(30),
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
                  pendingCount > 0 ? '$pendingCount New Orders!' : state.tr('online_status'),
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Icon(Icons.bolt, color: AppTheme.accent, size: 32),
        ],
      ),
    );
  }

  Widget _buildStatsRow(AppState state, double earnings, String rating, String totalOrders) {
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderListView(BuildContext context, AppState state, List<Order> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_outlined, color: AppTheme.textMuted.withValues(alpha: 0.3), size: 64),
            const SizedBox(height: 16),
            const Text('No orders found', style: TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: orders.length,
      itemBuilder: (context, index) => _buildOrderCard(context, state, orders[index]),
    );
  }

  Widget _buildOrderCard(BuildContext context, AppState state, Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(20),
            leading: const CircleAvatar(backgroundColor: AppTheme.bg, child: Icon(Icons.person, color: AppTheme.textMuted)),
            title: Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            subtitle: Text('Order #${order.id}', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
            trailing: _buildStatusChip(order.status),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('REVENUE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                    Text('₹${order.total.round()}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppTheme.success)),
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
    Color color = AppTheme.textMuted;
    if (status == 'placed') color = AppTheme.primary;
    if (status == 'preparing') color = AppTheme.secondary;
    if (status == 'ready') color = AppTheme.success;
    if (status == 'completed') color = Colors.blue;
    if (status == 'upcoming') color = Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900)),
    );
  }

  Widget _buildOrderActions(BuildContext context, AppState state, Order order) {
    if (order.status == 'completed' || order.status == 'upcoming') return const SizedBox.shrink();
    
    String label = 'ACCEPT';
    String next = 'preparing';
    Color color = AppTheme.primary;

    if (order.status == 'preparing') { label = 'READY'; next = 'ready'; color = AppTheme.secondary; }
    if (order.status == 'ready') { label = 'COMPLETE'; next = 'completed'; color = AppTheme.success; }

    return ElevatedButton(
      onPressed: () => state.updateStatusPublic(order.id, next),
      style: ElevatedButton.styleFrom(backgroundColor: color, minimumSize: const Size(100, 40)),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;
  @override double get minExtent => _tabBar.preferredSize.height;
  @override double get maxExtent => _tabBar.preferredSize.height;
  @override Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Colors.white, child: _tabBar);
  }
  @override bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
