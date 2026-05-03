import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../models/app_models.dart';

class CookMenuManagementScreen extends StatelessWidget {
  const CookMenuManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    // Assume cook ID 0 for demo
    final myCook = state.cooks.firstWhere((c) => c.id == 0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('KITCHEN MENU', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.black, Color(0xFF2D2D2D)]),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildInfoCard(),
                const SizedBox(height: 32),
                const Text('Live Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 16),
                ...myCook.menu.map((dish) => _buildDishCard(context, state, myCook.id, dish)),
                const SizedBox(height: 120),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDishSheet(context, state, myCook.id),
        label: const Text('Add New Dish', style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primarySoft,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: AppTheme.primary),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              'Add clear emojis and fair prices to attract more customers to your kitchen.',
              style: TextStyle(color: AppTheme.primary, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDishCard(BuildContext context, AppState state, int cookId, Dish dish) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: AppTheme.bg, borderRadius: BorderRadius.circular(16)),
            child: Center(child: Text(dish.emoji, style: const TextStyle(fontSize: 32))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dish.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 4),
                Text('₹${dish.price.round()}', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined, color: AppTheme.textMuted)),
              IconButton(
                onPressed: () => state.removeDishFromMenu(cookId, dish.id),
                icon: const Icon(Icons.delete_outline, color: AppTheme.danger),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddDishSheet(BuildContext context, AppState state, int cookId) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final emojiController = TextEditingController(text: '🥘');

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
            const Text('Create New Dish', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 24),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Dish Name')),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: TextField(controller: priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price (₹)'))),
                const SizedBox(width: 16),
                Expanded(child: TextField(controller: emojiController, decoration: const InputDecoration(labelText: 'Emoji'))),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && priceController.text.isNotEmpty) {
                  state.addDishToMenu(cookId, Dish(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    price: double.parse(priceController.text),
                    emoji: emojiController.text,
                    desc: 'Healthy homemade meal',
                    rating: 5.0,
                    orders: 0,
                    veg: true,
                    bg: '#FFFFFF',
                    hbg: '',
                    ingredients: '',
                    allergens: [],
                    nutri: [],
                  ));
                  Navigator.pop(context);
                }
              },
              child: const Text('Add to Kitchen'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
