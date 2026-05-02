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
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.primary,
              child: Text('A', style: TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            Text(state.userName ?? 'Avi Kumar', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(state.phone ?? '+91 1234567890', style: const TextStyle(color: AppTheme.textMuted)),
            const SizedBox(height: 32),
            
            _buildRoleToggle(context, state),
            
            const SizedBox(height: 24),
            _buildProfileOption(Icons.location_on_outlined, 'Saved Addresses', 'Home, Office'),
            _buildProfileOption(Icons.payment_outlined, 'Payment Methods', 'UPI, Cards'),
            _buildProfileOption(Icons.notifications_outlined, 'Notifications', 'Order updates, Offers'),
            _buildProfileOption(Icons.help_outline, 'Help & Support', 'FAQs, Contact us'),
            
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

  Widget _buildRoleToggle(BuildContext context, AppState state) {
    final isCook = state.roles.contains(UserRole.cook);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border, width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cook Mode', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Share your meals with neighbors', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                ],
              ),
              if (!isCook)
                ElevatedButton(
                  onPressed: () {
                    state.setRole(UserRole.cook);
                    Navigator.pushNamed(context, '/onboarding');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    minimumSize: Size.zero,
                  ),
                  child: const Text('Enable', style: TextStyle(fontSize: 12)),
                )
              else
                Switch(
                  value: state.activeRole == UserRole.cook,
                  onChanged: (val) {
                    final targetRole = val ? UserRole.cook : UserRole.consumer;
                    state.switchRole(targetRole);
                    if (targetRole == UserRole.cook) {
                      Navigator.pushNamedAndRemoveUntil(context, '/cook-home', (route) => false);
                    } else {
                      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                    }
                  },
                  activeThumbColor: AppTheme.primary,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppTheme.bg, borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: AppTheme.primary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.border),
      onTap: () {},
    );
  }
}
