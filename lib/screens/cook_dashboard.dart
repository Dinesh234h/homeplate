import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class CookDashboard extends StatelessWidget {
  const CookDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(state),
              _buildEarningsCard(),
              _buildQuickStats(),
              _buildNextPickups(),
              _buildAiSuggestion(),
              const SizedBox(height: 80), 
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.textLight,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.today), label: 'Today'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Menu'),
          BottomNavigationBarItem(icon: Icon(Icons.psychology), label: 'AI Ideas'),
          BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: 'Earn'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Me'),
        ],
      ),
    );
  }

  Widget _buildHeader(AppState state) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.primary,
            child: Text('N', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Good morning, ${state.userName?.split(' ')[0] ?? 'Neha'} 👋', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const Text('Tuesday, 27 April', style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.text,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Today\'s earnings', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          const Text('₹1,240', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(
            '↑ 18% vs last Tue · ₹14,820 this week',
            style: TextStyle(color: AppTheme.success.withValues(alpha: 0.9), fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          _buildStatBox('0', 'Pending', AppTheme.danger.withValues(alpha: 0.1), AppTheme.danger),
          const SizedBox(width: 12),
          _buildStatBox('2', 'Cooking', AppTheme.accent.withValues(alpha: 0.1), AppTheme.accent),
          const SizedBox(width: 12),
          _buildStatBox('1', 'Done', AppTheme.bg, AppTheme.textMuted),
        ],
      ),
    );
  }

  Widget _buildStatBox(String val, String label, Color bg, Color textColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Text(val, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textColor)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _buildNextPickups() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Next pickups', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
          const SizedBox(height: 12),
          _buildPickupItem('1:00 PM', 'Avi K.', 'Rajma Rice', 'Ready'),
          _buildPickupItem('1:15 PM', 'Sneha P.', 'Palak Paneer', 'Cooking'),
        ],
      ),
    );
  }

  Widget _buildPickupItem(String time, String name, String dish, String status) {
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
          Column(
            children: [
              Text(time.split(' ')[0], style: const TextStyle(fontWeight: FontWeight.w800)),
              Text(time.split(' ')[1], style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$name · $dish', style: const TextStyle(fontWeight: FontWeight.w700)),
                const Text('Less spicy · ₹110', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: status == 'Ready' ? AppTheme.success.withValues(alpha: 0.1) : AppTheme.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: status == 'Ready' ? AppTheme.success : AppTheme.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiSuggestion() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(4)),
                child: const Text('AI Suggestion', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Chole Bhature', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const Text('Demand spike Wednesday — Punjabi day in your area.', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAiMetric('Demand', '14-18 orders'),
              _buildAiMetric('Profit', '₹62/dish'),
              _buildAiMetric('Match', '92%'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('Add to menu'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiMetric(String label, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
        Text(val, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
