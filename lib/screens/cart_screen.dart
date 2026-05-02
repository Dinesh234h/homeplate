import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../models/app_models.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final subtotal = state.cart.fold<double>(0, (sum, item) => sum + (item.price * item.qty));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: state.cart.isEmpty ? _buildEmptyCart() : _buildCartContent(context, state, subtotal),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🛒', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 16),
          const Text('Your cart is empty', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('Add some home-cooked meals!', style: TextStyle(color: AppTheme.textMuted)),
        ],
      ),
    );
  }

  Widget _buildCartContent(BuildContext context, AppState state, double subtotal) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildCookHeader(state),
              const SizedBox(height: 24),
              ...state.cart.asMap().entries.map((entry) => _buildCartItem(state, entry.key, entry.value)),
              const SizedBox(height: 24),
              _buildBillSummary(subtotal),
            ],
          ),
        ),
        _buildCheckoutBar(context, state, subtotal),
      ],
    );
  }

  Widget _buildCookHeader(AppState state) {
    final cookId = state.cart[0].cookId;
    final cook = state.cooks.firstWhere((c) => c.id == cookId);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [cook.c1, cook.c2]),
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(cook.avatar, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(cook.name, style: const TextStyle(fontWeight: FontWeight.w800)),
              Text('${cook.distance} km · ${cook.walkMin} min walk', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(AppState state, int index, CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(item.emoji, style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text('₹${item.price} each', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
              ],
            ),
          ),
          Row(
            children: [
              _buildQtyBtn(Icons.remove, () => state.updateCartQty(index, -1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('${item.qty}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              _buildQtyBtn(Icons.add, () => state.updateCartQty(index, 1)),
            ],
          ),
          const SizedBox(width: 16),
          Text('₹${item.price * item.qty}', style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.border),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }

  Widget _buildBillSummary(double subtotal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('BILL SUMMARY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
        const SizedBox(height: 12),
        _buildSummaryRow('Subtotal', '₹$subtotal'),
        _buildSummaryRow('Delivery (Self Pickup)', '₹0'),
        const Divider(height: 24),
        _buildSummaryRow('Grand Total', '₹$subtotal', isTotal: true),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.w800 : FontWeight.normal)),
          Text(value, style: TextStyle(fontWeight: isTotal ? FontWeight.w800 : FontWeight.w700, fontSize: isTotal ? 18 : 14, color: isTotal ? AppTheme.primary : AppTheme.text)),
        ],
      ),
    );
  }

  Widget _buildCheckoutBar(BuildContext context, AppState state, double subtotal) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () {
            final cook = state.cooks.firstWhere((c) => c.id == state.cart[0].cookId);
            state.placeOrder(cook, 'Today, 1:00 PM');
            Navigator.pushNamed(context, '/tracking');
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Place Order'),
              const SizedBox(width: 8),
              const Text('·'),
              const SizedBox(width: 8),
              Text('₹$subtotal'),
            ],
          ),
        ),
      ),
    );
  }
}
