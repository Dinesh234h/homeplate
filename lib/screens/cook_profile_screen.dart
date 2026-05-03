import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../models/app_models.dart';

class CookProfileScreen extends StatelessWidget {
  const CookProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final myCookProfile = state.cooks.firstWhere(
      (c) => c.name == state.userName, 
      orElse: () => state.cooks.firstWhere((c) => c.id == 0)
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(myCookProfile),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('KITCHEN STATUS'),
                  _buildStatusCard(state),
                  const SizedBox(height: 32),
                  _buildSectionTitle('BUSINESS DETAILS'),
                  _buildInfoTile(Icons.storefront, 'Kitchen Name', myCookProfile.name),
                  _buildInfoTile(Icons.location_on_outlined, 'Location', state.userAddress ?? 'Set Address'),
                  _buildInfoTile(Icons.access_time, 'Operational Hours', '10:00 AM - 09:00 PM'),
                  _buildInfoTile(Icons.description_outlined, 'Kitchen Bio', 'Traditional home-cooked meals prepared with love and organic ingredients.'),
                  const SizedBox(height: 32),
                  _buildSectionTitle('REVENUE & SETTINGS'),
                  _buildActionTile(Icons.account_balance, 'Bank Account Details', 'Connected (HDFC ****4242)', () {}),
                  _buildActionTile(Icons.notifications_active_outlined, 'Order Notifications', 'Sound On', () {}),
                  _buildActionTile(Icons.verified_outlined, 'Certifications', 'FSSAI Verified', () {}),
                  const SizedBox(height: 40),
                  _buildLogoutButton(context),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(Cook cook) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: Colors.black,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://images.unsplash.com/photo-1556910103-1c02745aae4d?q=80&w=2070&auto=format&fit=crop',
              fit: BoxFit.cover,
            ),
            Container(color: Colors.black.withValues(alpha: 0.3)),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: Text(cook.avatar, style: const TextStyle(fontSize: 35)),
                  ),
                  const SizedBox(height: 12),
                  Text(cook.name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppTheme.accent, size: 16),
                      const SizedBox(width: 4),
                      Text(cook.rating.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      const Icon(Icons.verified, color: Colors.blueAccent, size: 16),
                      const SizedBox(width: 4),
                      const Text('Verified Chef', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.textMuted, letterSpacing: 1.5)),
    );
  }

  Widget _buildStatusCard(AppState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.isAvailable ? 'Currently Open' : 'Currently Closed',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: state.isAvailable ? AppTheme.success : AppTheme.danger),
              ),
              const Text('Visible to neighbors', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
            ],
          ),
          const Spacer(),
          Switch(
            value: state.isAvailable,
            onChanged: (val) => state.toggleAvailability(),
            activeThumbColor: Colors.white,
            activeTrackColor: AppTheme.success,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppTheme.bg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.black, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title, String value, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppTheme.primary, size: 22),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(value, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
        trailing: const Icon(Icons.chevron_right, size: 18),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppTheme.danger),
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text('LOGOUT KITCHEN', style: TextStyle(color: AppTheme.danger, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
      ),
    );
  }
}
