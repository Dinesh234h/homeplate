import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../models/app_models.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _promoController = TextEditingController();
  double _discount = 0.0;
  String? _appliedCode;

  void _applyPromo() {
    if (_promoController.text.toUpperCase() == 'HOME50') {
      setState(() {
        _discount = 50.0;
        _appliedCode = 'HOME50';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coupon applied successfully!'), backgroundColor: AppTheme.secondary),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid coupon code'), backgroundColor: AppTheme.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final subtotal = state.cart.fold<double>(0, (sum, item) => sum + (item.price * item.qty));
    final grandTotal = (subtotal - _discount).clamp(0.0, double.infinity);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: state.cart.isEmpty ? _buildEmptyCart() : _buildCartContent(context, state, subtotal, grandTotal),
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

  Widget _buildCartContent(BuildContext context, AppState state, double subtotal, double grandTotal) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildCookHeader(state),
              const SizedBox(height: 24),
              _buildAddressSection(context, state),
              const SizedBox(height: 24),
              ...state.cart.asMap().entries.map((entry) => _buildCartItem(state, entry.key, entry.value)),
              const SizedBox(height: 24),
              _buildGroupOrderCard(context),
              const SizedBox(height: 24),
              _buildPaymentSection(context, state),
              const SizedBox(height: 24),
              _buildPromoSection(),
              const SizedBox(height: 24),
              _buildBillSummary(subtotal, grandTotal),
            ],
          ),
        ),
        _buildCheckoutBar(context, state, grandTotal),
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

  Widget _buildAddressSection(BuildContext context, AppState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('DELIVERY ADDRESS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              const Icon(Icons.location_on, color: AppTheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(state.userAddress ?? 'Select Address', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Text('Delivering to your door', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => _showAddressSelector(context, state),
                child: const Text('CHANGE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddressSelector(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Deliver to:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...state.savedAddresses.map((a) => ListTile(
              leading: const Icon(Icons.home_outlined, color: AppTheme.primary),
              title: Text(a),
              trailing: state.userAddress == a ? const Icon(Icons.check_circle, color: AppTheme.success) : null,
              onTap: () {
                state.setUserInfo(state.userName ?? 'User', a);
                Navigator.pop(context);
              },
            )),
            const SizedBox(height: 24),
          ],
        ),
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

  Widget _buildGroupOrderCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primarySoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.group_add, color: AppTheme.primary),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Group Ordering', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primary)),
                Text('Invite friends to add items to this cart.', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showInviteDialog(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Invite', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  void _showInviteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invite Friends'),
        content: const Text('Share this link with your friends to start a group order!\n\nhttps://homeplate.app/group/12345'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Copy Link')),
        ],
      ),
    );
  }

  Widget _buildPaymentSection(BuildContext context, AppState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('PAYMENT METHOD', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              const Icon(Icons.payment, color: AppTheme.secondary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(state.selectedPayment, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Text('Secured Payment', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => _showPaymentSelector(context, state),
                child: const Text('CHANGE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showPaymentSelector(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Payment Method', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...state.paymentMethods.map((p) => ListTile(
              leading: const Icon(Icons.payment, color: AppTheme.secondary),
              title: Text(p),
              trailing: state.selectedPayment == p ? const Icon(Icons.check_circle, color: AppTheme.success) : null,
              onTap: () {
                state.setPaymentMethod(p);
                Navigator.pop(context);
              },
            )),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.secondary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('OFFERS & BENEFITS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.secondary)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _promoController,
                  decoration: const InputDecoration(
                    hintText: 'Enter promo code',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: _applyPromo,
                child: const Text('APPLY', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
              ),
            ],
          ),
          if (_appliedCode != null) ...[
            const SizedBox(height: 8),
            Text('Code $_appliedCode applied! You saved ₹${_discount.round()}', 
                 style: const TextStyle(fontSize: 12, color: AppTheme.secondary, fontWeight: FontWeight.bold)),
          ],
        ],
      ),
    );
  }

  Widget _buildBillSummary(double subtotal, double grandTotal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('BILL SUMMARY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
        const SizedBox(height: 12),
        _buildSummaryRow('Subtotal', '₹$subtotal'),
        if (_discount > 0) _buildSummaryRow('Promo Discount', '-₹$_discount', color: AppTheme.secondary),
        _buildSummaryRow('Delivery (Self Pickup)', '₹0'),
        const Divider(height: 24),
        _buildSummaryRow('Grand Total', '₹$grandTotal', isTotal: true),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.w800 : FontWeight.normal)),
          Text(value, style: TextStyle(
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w700, 
            fontSize: isTotal ? 18 : 14, 
            color: color ?? (isTotal ? AppTheme.primary : AppTheme.text)
          )),
        ],
      ),
    );
  }

  Widget _buildCheckoutBar(BuildContext context, AppState state, double grandTotal) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: state.isLoading ? null : () => _placeOrder(context, state, grandTotal),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (state.isLoading) 
                const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
              if (state.isLoading) const SizedBox(width: 12),
              Text(state.isLoading ? 'Reserving...' : 'Place Order'),
              const SizedBox(width: 8),
              const Text('·'),
              const SizedBox(width: 8),
              Text('₹$grandTotal'),
            ],
          ),
        ),
      ),
    );
  }

  void _placeOrder(BuildContext context, AppState state, double grandTotal) async {
    final cook = state.cooks.firstWhere((c) => c.id == state.cart[0].cookId);
    await state.placeOrderReal(cook, 'Today, 1:00 PM');
    if (!mounted) return;
    
    // Show Success UI
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildSuccessUI(context, grandTotal),
    );

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context); // Close dialog
      Navigator.pushReplacementNamed(context, '/tracking');
    });
  }

  Widget _buildSuccessUI(BuildContext context, double total) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: AppTheme.success, size: 100),
            const SizedBox(height: 24),
            const Text('Order Placed Successfully!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('₹${total.round()} paid via UPI', style: const TextStyle(color: AppTheme.textMuted)),
            const SizedBox(height: 40),
            const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary)),
            const SizedBox(height: 16),
            const Text('Connecting to your neighbor chef...', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
          ],
        ),
      ),
    );
  }
}
