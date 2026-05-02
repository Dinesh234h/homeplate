import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../models/app_models.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildUserInfo(state),
            const SizedBox(height: 24),
            _buildGoldBanner(),
            const SizedBox(height: 32),
            _buildRoleToggle(context, state),
            const SizedBox(height: 24),
            _buildSection('Account Settings', [
              _buildOption(context, Icons.location_on_outlined, 'Saved Addresses', '${state.savedAddresses.length} addresses', () => _showAddresses(context, state)),
              _buildOption(context, Icons.payment_outlined, 'Payment Methods', state.paymentMethods.first, () => _showPayments(context, state)),
              _buildOption(context, Icons.wallet_outlined, 'HomePlate Wallet', 'Balance: ₹${state.walletBalance.round()}', () {}),
            ]),
            const SizedBox(height: 24),
            _buildSection('Support & Legals', [
              _buildOption(context, Icons.help_outline, 'Help & Support', 'FAQs, Contact us', () => _showHelp(context)),
              _buildOption(context, Icons.description_outlined, 'Terms of Service', 'Usage policy', () {}),
            ]),
            const SizedBox(height: 32),
            TextButton(
              onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false),
              child: const Text('Log Out', style: TextStyle(color: AppTheme.danger, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(AppState state) {
    return Row(
      children: [
        CircleAvatar(
          radius: 35,
          backgroundColor: AppTheme.primary,
          child: Text(state.userName?.substring(0, 1).toUpperCase() ?? 'U', 
               style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(state.userName ?? 'User Name', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(state.phone ?? '+91 1234567890', style: const TextStyle(color: AppTheme.textMuted)),
          ],
        ),
        const Spacer(),
        IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined, size: 20)),
      ],
    );
  }

  Widget _buildGoldBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF2D2D2D), Color(0xFF4A4A4A)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(Icons.stars, color: Color(0xFFFFD700), size: 24),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('HOMEPLATE GOLD', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
                Text('Free Deliveries & Priority', style: TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.white70),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildOption(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppTheme.bg, borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: AppTheme.primary, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.border, size: 20),
    );
  }

  Widget _buildRoleToggle(BuildContext context, AppState state) {
    final isCook = state.roles.contains(UserRole.cook);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primarySoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Switch to Cook Mode', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primary)),
              Text('Earn by sharing your recipes', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
            ],
          ),
          Switch(
            value: state.activeRole == UserRole.cook,
            onChanged: (val) {
              if (!isCook && val) {
                state.setRole(UserRole.cook);
                Navigator.pushNamed(context, '/onboarding');
              } else {
                state.switchRole(val ? UserRole.cook : UserRole.consumer);
                Navigator.pushNamedAndRemoveUntil(context, val ? '/cook-home' : '/home', (route) => false);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showAddresses(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Saved Addresses', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...state.savedAddresses.map((a) => ListTile(
              leading: const Icon(Icons.location_on, color: AppTheme.primary),
              title: Text(a),
              onTap: () => Navigator.pop(context),
            )),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () {}, child: const Text('Add New Address')),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showPayments(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Payment Methods', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...state.paymentMethods.map((p) => ListTile(
              leading: const Icon(Icons.payment, color: AppTheme.secondary),
              title: Text(p),
              trailing: const Icon(Icons.check_circle, color: AppTheme.success),
              onTap: () => Navigator.pop(context),
            )),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: () {}, child: const Text('Add New UPI/Card')),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('How can we help?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildHelpItem(Icons.chat, 'Chat with Support', 'Wait time: < 2 mins'),
            _buildHelpItem(Icons.phone, 'Call Helpline', '9 AM - 11 PM'),
            _buildHelpItem(Icons.article, 'FAQs', 'Read our common guides'),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpItem(IconData icon, String title, String sub) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
      onTap: () {},
    );
  }
}
