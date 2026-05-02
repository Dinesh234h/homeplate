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
  final List<Map<String, String>> _messages = [
    {"sender": "chef", "text": "Hi! I've started preparing your meal."},
    {"sender": "chef", "text": "It should be ready in about 15 minutes."},
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final order = state.currentOrder;

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Tracking')),
        body: const Center(child: Text('No active order found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Tracking Order', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('Order #${order.id}', style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
          ],
        ),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 20), onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(
            onPressed: () => _showCallUI(context, order.cookName),
            icon: const Icon(Icons.phone_in_talk, color: AppTheme.success),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildStatusBanner(order),
          Expanded(child: _buildChatArea()),
          _buildChatInput(order.cookName),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(Order order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: AppTheme.bg,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          _buildStatusIcon(order.status),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_getStatusTitle(order.status), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                Text(_getStatusSub(order.status), style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border)),
            child: Column(
              children: [
                const Text('OTP', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                Text(order.otp, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.primary, letterSpacing: 1)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    IconData icon;
    Color color;
    switch (status) {
      case 'placed': icon = Icons.receipt_long; color = AppTheme.primary; break;
      case 'accepted': icon = Icons.thumb_up; color = AppTheme.secondary; break;
      case 'cooking': icon = Icons.restaurant; color = AppTheme.accent; break;
      case 'ready': icon = Icons.shopping_bag; color = AppTheme.success; break;
      default: icon = Icons.help; color = AppTheme.textMuted;
    }
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 24),
    );
  }

  String _getStatusTitle(String status) {
    if (status == 'placed') return 'Order Placed';
    if (status == 'accepted') return 'Chef Accepted';
    if (status == 'cooking') return 'Cooking Now';
    if (status == 'ready') return 'Ready for Pickup!';
    return 'Processing';
  }

  String _getStatusSub(String status) {
    if (status == 'ready') return 'Please head to the kitchen';
    return 'Next: We will notify you';
  }

  Widget _buildChatArea() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        final isChef = msg['sender'] == 'chef';
        return Align(
          alignment: isChef ? Alignment.centerLeft : Alignment.centerRight,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isChef ? AppTheme.bg : AppTheme.primary,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isChef ? 0 : 16),
                bottomRight: Radius.circular(isChef ? 16 : 0),
              ),
            ),
            child: Text(
              msg['text']!,
              style: TextStyle(color: isChef ? AppTheme.text : Colors.white, fontSize: 13),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChatInput(String name) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: AppTheme.bg, borderRadius: BorderRadius.circular(24)),
                child: TextField(
                  controller: _chatController,
                  decoration: InputDecoration(
                    hintText: 'Message $name...',
                    border: InputBorder.none,
                    hintStyle: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: () {
                if (_chatController.text.isNotEmpty) {
                  setState(() {
                    _messages.add({"sender": "user", "text": _chatController.text});
                    _chatController.clear();
                  });
                }
              },
              icon: const Icon(Icons.send_rounded, color: AppTheme.primary),
            ),
          ],
        ),
      ),
    );
  }

  void _showCallUI(BuildContext context, String name) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(radius: 40, backgroundColor: AppTheme.bg, child: Icon(Icons.person, size: 40, color: AppTheme.primary)),
            const SizedBox(height: 16),
            Text('Calling $name...', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text('+91 98XXX XXXXX', style: TextStyle(color: AppTheme.textMuted)),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCallAction(Icons.mic_off, 'Mute', Colors.grey),
                _buildCallAction(Icons.call_end, 'End', AppTheme.danger, onTap: () => Navigator.pop(context)),
                _buildCallAction(Icons.volume_up, 'Speaker', Colors.grey),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCallAction(IconData icon, String label, Color color, {VoidCallback? onTap}) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
      ],
    );
  }
}
