import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../models/app_models.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final TextEditingController _chatController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final order = state.currentOrder;

    if (order == null) {
      return const Scaffold(body: Center(child: Text('No active order')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Status', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          _buildStatusHeader(order),
          _buildTimeline(order),
          const Spacer(),
          _buildCommunicationBar(context, order),
        ],
      ),
    );
  }

  Widget _buildStatusHeader(Order order) {
    String message;
    String emoji;
    
    switch (order.status) {
      case 'placed': message = 'Order Placed'; emoji = '📝'; break;
      case 'accepted': message = 'Chef accepted your order'; emoji = '👩‍🍳'; break;
      case 'cooking': message = 'Cooking your meal'; emoji = '🍳'; break;
      case 'ready': message = 'Ready for Pickup'; emoji = '🛍️'; break;
      default: message = 'Status Unknown'; emoji = '❓';
    }

    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          Text('OTP for pickup: ${order.otp}', style: const TextStyle(color: AppTheme.secondary, fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildTimeline(Order order) {
    final statuses = ['placed', 'accepted', 'cooking', 'ready'];
    final currentIndex = statuses.indexOf(order.status);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: List.generate(statuses.length, (index) {
          final isPast = index <= currentIndex;
          final isLast = index == statuses.length - 1;
          
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isPast ? AppTheme.primary : AppTheme.border,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (!isLast)
                    Container(width: 2, height: 40, color: isPast ? AppTheme.primary : AppTheme.border),
                ],
              ),
              const SizedBox(width: 20),
              Text(
                statuses[index].toUpperCase(),
                style: TextStyle(
                  fontWeight: isPast ? FontWeight.bold : FontWeight.normal,
                  color: isPast ? AppTheme.text : AppTheme.textMuted,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildCommunicationBar(BuildContext context, Order order) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(backgroundColor: AppTheme.bg, child: Text(order.cookAvatar)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.cookName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Text('Your neighbor chef', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showCallDialog(context, order.cookName),
                  icon: const Icon(Icons.phone, color: AppTheme.success),
                ),
                IconButton(
                  onPressed: () => _showChatSheet(context, order.cookName),
                  icon: const Icon(Icons.chat_bubble, color: AppTheme.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCallDialog(BuildContext context, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Call $name?'),
        content: const Text('Connect with your neighbor to coordinate pickup.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Call Now')),
        ],
      ),
    );
  }

  void _showChatSheet(BuildContext context, String name) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Chat with $name', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Container(
              height: 200,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppTheme.bg, borderRadius: BorderRadius.circular(12)),
              child: const Center(child: Text('No messages yet', style: TextStyle(color: AppTheme.textMuted))),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    decoration: const InputDecoration(hintText: 'Type a message...'),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.send, color: AppTheme.primary)),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
