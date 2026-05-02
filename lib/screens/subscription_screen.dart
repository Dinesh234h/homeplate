import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Plans', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildInfoCard(),
          const SizedBox(height: 32),
          const Text('Recommended for you', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildPlanCard(
            context,
            'Daily Lunch Box',
            'Authentic North Indian Thali with 3 Rotis, Dal, Sabzi, and Rice. Perfect for office-goers.',
            '₹2,400/month',
            '22 Meals · Mon to Fri',
            const Color(0xFFFF6B47),
          ),
          _buildPlanCard(
            context,
            'Healthy Dinner',
            'Low oil, high protein meals curated by nutritionists. Includes salads and grilled items.',
            '₹3,200/month',
            '30 Meals · Daily',
            const Color(0xFF2D5F3F),
          ),
          _buildPlanCard(
            context,
            'South Indian Breakfast',
            'Start your day with healthy steamed Idlis, crispy Dosas, and fresh Chutneys.',
            '₹1,800/month',
            '20 Meals · Mon to Sat',
            const Color(0xFFF4B942),
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

  Widget _buildPlanCard(BuildContext context, String title, String subtitle, String price, String detail, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showPurchaseDialog(context, title, price),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.border),
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
              const Icon(Icons.chevron_right, color: AppTheme.border),
            ],
          ),
        ),
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context, String title, String price) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Subscribe to $title?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Benefits:'),
            const SizedBox(height: 8),
            const Row(children: [Icon(Icons.check, size: 16, color: AppTheme.success), SizedBox(width: 8), Text('Free Delivery')]),
            const Row(children: [Icon(Icons.check, size: 16, color: AppTheme.success), SizedBox(width: 8), Text('Priority Slot Booking')]),
            const Row(children: [Icon(Icons.check, size: 16, color: AppTheme.success), SizedBox(width: 8), Text('Customizable Menu')]),
            const SizedBox(height: 16),
            Text('Price: $price', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
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
