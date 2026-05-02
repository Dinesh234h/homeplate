import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../models/app_models.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final order = state.currentOrder;

    if (order == null) {
      return const Scaffold(body: Center(child: Text('No active order')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${order.id}', style: const TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildStatusBanner(order),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildOtpSection(order),
                const SizedBox(height: 32),
                _buildCookInfo(order),
                const SizedBox(height: 32),
                _buildTimeline(order),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(Order order) {
    final cfg = {
      'placed': {'h': 'Order placed', 's': 'Waiting for confirmation', 'e': '📨'},
      'accepted': {'h': 'Cook accepted', 's': 'Your meal is in the queue', 'e': '👩‍🍳'},
      'cooking': {'h': 'Cooking now', 's': 'Preparing your meal', 'e': '🍲'},
      'ready': {'h': 'Ready for pickup!', 's': 'Walk over and show your OTP', 'e': '🛍️'},
      'pickedup': {'h': 'Picked up', 's': 'Hope it was delicious!', 'e': '😋'},
    }[order.status]!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: order.status == 'ready' ? AppTheme.secondary : AppTheme.primary,
      ),
      child: Row(
        children: [
          Text(cfg['e']!, style: const TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cfg['h']!, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                Text(cfg['s']!, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpSection(Order order) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          const Text('PICKUP OTP', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
          const SizedBox(height: 8),
          Text(
            order.otp.split('').join(' '),
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: 10, color: AppTheme.primary),
          ),
          const SizedBox(height: 8),
          const Text('Show this to the cook at her door', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
        ],
      ),
    );
  }

  Widget _buildCookInfo(Order order) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: order.cookColors),
            shape: BoxShape.circle,
          ),
          child: Center(child: Text(order.cookAvatar, style: const TextStyle(fontSize: 24))),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(order.cookName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              Text('${order.cookDist} km · Pickup at her place', style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeline(Order order) {
    final stages = ['placed', 'accepted', 'cooking', 'ready', 'pickedup'];
    final currentIndex = stages.indexOf(order.status);
    
    return Column(
      children: stages.asMap().entries.map((entry) {
        final i = entry.key;
        final s = entry.value;
        final isPast = i < currentIndex;
        final isCurrent = i == currentIndex;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            children: [
              Column(
                children: [
                  Icon(
                    isPast ? Icons.check_circle : (isCurrent ? Icons.radio_button_checked : Icons.radio_button_off),
                    color: isPast || isCurrent ? AppTheme.secondary : AppTheme.border,
                    size: 20,
                  ),
                  if (i < stages.length - 1)
                    Container(width: 2, height: 30, color: isPast ? AppTheme.secondary : AppTheme.border),
                ],
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.toUpperCase(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isPast || isCurrent ? AppTheme.text : AppTheme.textLight,
                    ),
                  ),
                  Text(
                    isCurrent ? 'Current Status' : (isPast ? 'Completed' : 'Upcoming'),
                    style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
