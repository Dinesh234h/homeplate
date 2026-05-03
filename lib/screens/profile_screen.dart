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
      body: CustomScrollView(
        slivers: [
          _buildAppBar(state),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildWalletCard(context, state),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Account'),
                  _buildMenuTile(
                    icon: Icons.person_outlined,
                    title: 'Edit Profile',
                    subtitle: 'Name, Phone, Email',
                    onTap: () => _showEditProfile(context, state),
                  ),
                  _buildMenuTile(
                    icon: Icons.location_on_outlined,
                    title: 'Saved Addresses',
                    subtitle: 'Manage your delivery locations',
                    onTap: () => _showSavedAddresses(context, state),
                  ),
                  _buildMenuTile(
                    icon: Icons.restaurant_outlined,
                    title: 'Meal Preferences',
                    subtitle: 'Diet, Spice, Allergies & Goals',
                    onTap: () => _showMealPreferences(context, state),
                  ),
                  _buildMenuTile(
                    icon: Icons.payment_outlined,
                    title: 'Payment Methods',
                    subtitle: state.selectedPayment,
                    onTap: () => _showPaymentMethods(context, state),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle('General'),
                  _buildMenuTile(
                    icon: Icons.help_outlined,
                    title: 'Help & Support',
                    subtitle: 'FAQs, Contact us',
                    onTap: () => _showHelp(context),
                  ),
                  _buildMenuTile(
                    icon: Icons.description_outlined,
                    title: 'Terms & Conditions',
                    subtitle: 'Privacy policy, Legal',
                    onTap: () => _showTerms(context),
                  ),
                  _buildMenuTile(
                    icon: Icons.star_outlined,
                    title: 'Rate the App',
                    subtitle: 'Share your feedback',
                    onTap: () {},
                  ),
                  if (state.roles.contains(UserRole.cook)) ...[
                    const SizedBox(height: 16),
                    _buildMenuTile(
                      icon: Icons.restaurant_menu,
                      title: 'Switch to Cook Mode',
                      subtitle: 'Manage your kitchen and orders',
                      onTap: () {
                        state.switchRole(UserRole.cook);
                        Navigator.pushNamed(context, '/cook-home');
                      },
                    ),
                  ],
                  const SizedBox(height: 40),
                  TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                    child: const Text('LOGOUT', style: TextStyle(color: AppTheme.danger, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(AppState state) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primary, AppTheme.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: Text(state.userName?[0] ?? 'A', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primary)),
              ),
              const SizedBox(height: 12),
              Text(state.userName ?? 'Avi Nash', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              Text(state.phone ?? '+91 9876543210', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletCard(BuildContext context, AppState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.primarySoft, shape: BoxShape.circle),
            child: const Icon(Icons.account_balance_wallet, color: AppTheme.primary, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('HomePlate Wallet', style: TextStyle(fontSize: 14, color: AppTheme.textMuted)),
                Text('₹${state.walletBalance.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showAddMoney(context, state),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: Size.zero,
            ),
            child: const Text('ADD MONEY', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.textMuted, letterSpacing: 1.5)),
      ),
    );
  }

  Widget _buildMenuTile({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppTheme.bg, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: AppTheme.text),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textMuted, size: 20),
      onTap: onTap,
    );
  }

  void _showEditProfile(BuildContext context, AppState state) {
    final nameController = TextEditingController(text: state.userName);
    final phoneController = TextEditingController(text: state.phone);

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
            const Text('Edit Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Full Name')),
            const SizedBox(height: 16),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone Number')),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                state.updateProfile(nameController.text, phoneController.text);
                Navigator.pop(context);
              },
              child: const Text('Save Changes'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showSavedAddresses(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Saved Addresses', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => _showAddAddress(context, state), icon: const Icon(Icons.add_circle, color: AppTheme.primary)),
              ],
            ),
            const SizedBox(height: 16),
            ...state.savedAddresses.asMap().entries.map((entry) => ListTile(
              leading: const Icon(Icons.home_outlined),
              title: Text(entry.value),
              trailing: IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: () => _showAddAddress(context, state, index: entry.key)),
              onTap: () {
                state.setUserInfo(state.userName ?? 'User', entry.value);
                Navigator.pop(context);
              },
            )),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showAddAddress(BuildContext context, AppState state, {int? index}) {
    final controller = TextEditingController(text: index != null ? state.savedAddresses[index] : '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(index == null ? 'Add Address' : 'Edit Address'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Enter full address')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () {
            if (index == null) {
              state.addAddress(controller.text);
            } else {
              state.updateAddress(index, controller.text);
            }
            Navigator.pop(context);
          }, child: const Text('Save')),
        ],
      ),
    );
  }

  void _showMealPreferences(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.8,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) => SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Meal Preferences', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Help our AI suggest the best home-made meals for you.', style: TextStyle(color: AppTheme.textMuted)),
                const SizedBox(height: 32),
                
                const Text('DIET PREFERENCE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.textMuted, letterSpacing: 1.5)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildChip(setModalState, 'Veg', state.diet == 'veg', () => state.updateDietaryPreferences(newDiet: 'veg')),
                    const SizedBox(width: 8),
                    _buildChip(setModalState, 'Non-Veg', state.diet == 'non-veg', () => state.updateDietaryPreferences(newDiet: 'non-veg')),
                  ],
                ),
                
                const SizedBox(height: 32),
                const Text('SPICE LEVEL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.textMuted, letterSpacing: 1.5)),
                Slider(
                  value: state.spiceLevel,
                  min: 0,
                  max: 100,
                  activeColor: AppTheme.primary,
                  onChanged: (val) {
                    setModalState(() {});
                    state.updateDietaryPreferences(newSpice: val);
                  },
                ),
                
                const SizedBox(height: 32),
                const Text('HEALTH GOALS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.textMuted, letterSpacing: 1.5)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    'Weight Loss', 'Muscle Gain', 'Healthy Living', 'Low Carb', 'High Protein'
                  ].map((goal) {
                    final isSelected = state.healthGoals.contains(goal);
                    return _buildChip(setModalState, goal, isSelected, () {
                      final list = List<String>.from(state.healthGoals);
                      if (isSelected) {
                        list.remove(goal);
                      } else {
                        list.add(goal);
                      }
                      state.updateDietaryPreferences(newGoals: list);
                    });
                  }).toList(),
                ),
                
                const SizedBox(height: 32),
                const Text('ALLERGIES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.textMuted, letterSpacing: 1.5)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    'Nuts', 'Dairy', 'Gluten', 'Seafood', 'Soy'
                  ].map((allergy) {
                    final isSelected = state.allergies.contains(allergy);
                    return _buildChip(setModalState, allergy, isSelected, () {
                      final list = List<String>.from(state.allergies);
                      if (isSelected) {
                        list.remove(allergy);
                      } else {
                        list.add(allergy);
                      }
                      state.updateDietaryPreferences(newAllergies: list);
                    });
                  }).toList(),
                ),
                
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('SAVE PREFERENCES'),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChip(StateSetter setModalState, String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setModalState(() {});
        onTap();
      },
      selectedColor: AppTheme.primarySoft,
      checkmarkColor: AppTheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primary : AppTheme.text,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  void _showPaymentMethods(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Payment Methods', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ...state.paymentMethods.map((m) => ListTile(
              leading: const Icon(Icons.payment),
              title: Text(m),
              trailing: state.selectedPayment == m ? const Icon(Icons.check_circle, color: AppTheme.success) : null,
              onTap: () {
                state.setPaymentMethod(m);
                Navigator.pop(context);
              },
            )),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showAddMoney(BuildContext context, AppState state) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Money to Wallet'),
        content: TextField(controller: controller, keyboardType: TextInputType.number, decoration: const InputDecoration(prefixText: '₹ ', hintText: 'Enter amount')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () {
            final val = double.tryParse(controller.text) ?? 0;
            state.walletBalance += val;
            Navigator.pop(context);
          }, child: const Text('Add')),
        ],
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          children: [
            const Text('Help & Support', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildFaqItem('How do I order food?', 'Simply browse kitchens, add items to cart, and place order!'),
            _buildFaqItem('What is the delivery time?', 'Most home chefs prepare food within 30-45 minutes.'),
            _buildFaqItem('Can I cancel my order?', 'Orders can be cancelled before the chef starts cooking.'),
            const SizedBox(height: 32),
            const Text('Contact Us', style: TextStyle(fontWeight: FontWeight.bold)),
            const ListTile(leading: Icon(Icons.email_outlined), title: Text('support@homeplate.app')),
            const ListTile(leading: Icon(Icons.phone_outlined), title: Text('+91 1800-HOME-PLATE')),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String q, String a) {
    return ExpansionTile(title: Text(q, style: const TextStyle(fontWeight: FontWeight.bold)), children: [Padding(padding: const EdgeInsets.all(16), child: Text(a))]);
  }

  void _showTerms(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          children: const [
            Text('Terms & Conditions', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 24),
            Text('By using HomePlate, you agree to follow our guidelines on food safety and community standards...'),
            SizedBox(height: 16),
            Text('1. User Eligibility\n2. Order Placement\n3. Payment Terms\n4. Chef Responsibility...'),
          ],
        ),
      ),
    );
  }
}
