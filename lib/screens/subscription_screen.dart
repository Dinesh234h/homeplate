import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Plans', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (state.activePlanName != null) _buildActivePlanCard(state),
          const SizedBox(height: 24),
          _buildInfoCard(),
          const SizedBox(height: 32),
          const Text('Choose a Plan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildPlanCard(
            context,
            state,
            'Daily Lunch Box',
            'Authentic North Indian Thali with 3 Rotis, Dal, Sabzi, and Rice. Perfect for office-goers.',
            '₹2,400/month',
            '22 Meals · Mon to Fri',
            const Color(0xFFFF6B47),
            ['Free Delivery on every meal', 'Priority slot booking', 'Customizable menu every week'],
          ),
          _buildPlanCard(
            context,
            state,
            'Healthy Dinner',
            'Low oil, high protein meals curated by nutritionists. Includes salads and grilled items.',
            '₹3,200/month',
            '30 Meals · Daily',
            const Color(0xFF2D5F3F),
            ['Calories tracked', 'Fresh organic ingredients', 'Evening delivery (7-8 PM)'],
          ),
          _buildPlanCard(
            context,
            state,
            'South Indian Breakfast',
            'Start your day with healthy steamed Idlis, crispy Dosas, and fresh Chutneys.',
            '₹1,800/month',
            '20 Meals · Mon to Sat',
            const Color(0xFFF4B942),
            ['Served with fresh coconut chutney', 'Healthy probiotic dough', 'Quick morning delivery'],
          ),
        ],
      ),
    );
  }

  Widget _buildActivePlanCard(AppState state) {
    final expiry = DateFormat('dd MMM yyyy').format(state.planDueDate!);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified, color: AppTheme.success, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ACTIVE PLAN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.success, letterSpacing: 1.2)),
                Text(state.activePlanName!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Valid until $expiry', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.calendar_month, color: Colors.white, size: 32),
          SizedBox(height: 16),
          Text('Save 20% with Plans', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Subscribe to your favorite neighbor cook and get fresh home food delivered daily to your doorstep.', 
               style: TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, AppState state, String title, String subtitle, String price, String detail, Color color, List<String> benefits) {
    final isActive = state.activePlanName == title;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: isActive ? null : () => _showPurchaseDialog(context, state, title, price, benefits),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isActive ? AppTheme.success : AppTheme.border, width: isActive ? 2 : 1),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.restaurant, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(price, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Text('· $detail', style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                      ],
                    ),
                  ],
                ),
              ),
              if (isActive) 
                const Icon(Icons.check_circle, color: AppTheme.success)
              else 
                const Icon(Icons.chevron_right, color: AppTheme.border),
            ],
          ),
        ),
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context, AppState state, String title, String price, List<String> benefits) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Subscribe to $title?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Benefits:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...benefits.map((b) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(children: [
                const Icon(Icons.check_circle, size: 14, color: AppTheme.success), 
                const SizedBox(width: 8), 
                Expanded(child: Text(b, style: const TextStyle(fontSize: 12)))
              ]),
            )),
            const SizedBox(height: 16),
            Text('Price: $price', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primary)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              state.subscribeToPlan(title);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Successfully subscribed to $title!'),
                  backgroundColor: AppTheme.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Confirm & Pay'),
          ),
        ],
      ),
    );
  }
}
