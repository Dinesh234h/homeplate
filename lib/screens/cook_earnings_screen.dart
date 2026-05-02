import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../models/app_models.dart';

class CookEarningsScreen extends StatelessWidget {
  const CookEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final myOrders = state.orders.where((o) => o.cookId == 0).toList();
    final completedOrders = myOrders.where((o) => o.status == 'completed').toList();
    final totalEarnings = completedOrders.fold<double>(0, (sum, o) => sum + o.total);
    final commission = totalEarnings * 0.08;
    final netAmount = totalEarnings - commission;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Earnings', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSummaryCard(totalEarnings, commission, netAmount),
          const SizedBox(height: 32),
          _buildPayoutStatus(),
          const SizedBox(height: 32),
          const Text('Recent Payouts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          ...completedOrders.map((o) => _buildEarningsTile(o)),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(double gross, double fee, double net) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.secondary, Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: AppTheme.secondary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          const Text('AVAILABLE FOR PAYOUT', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          Text('₹${net.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSimpleStat('Gross', '₹${gross.round()}'),
              Container(width: 1, height: 30, color: Colors.white24),
              _buildSimpleStat('Fee (8%)', '-₹${fee.round()}'),
              Container(width: 1, height: 30, color: Colors.white24),
              _buildSimpleStat('Orders', '12'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleStat(String label, String val) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Widget _buildPayoutStatus() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user_outlined, color: AppTheme.success),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Instant Payouts Enabled', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text('Next payout scheduled for Monday', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: const Size(0, 32),
            ),
            child: const Text('Withdraw', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsTile(Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.success.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.add, color: AppTheme.success, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order #${order.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(order.customerName, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('+₹${(order.total * 0.92).toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.success)),
              const Text('Settled', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}
