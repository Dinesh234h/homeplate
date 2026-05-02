import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class SocialFeedScreen extends StatelessWidget {
  const SocialFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Feed', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () => _showPostDialog(context), icon: const Icon(Icons.add_circle_outline, color: AppTheme.primary)),
        ],
      ),
      body: ListView(
        children: [
          _buildStoriesSection(),
          const Divider(),
          _buildPost(context, state, '1', 'Priya', '👩', 'Just made a fresh batch of Bisi Bele Bath! Smells amazing. 🍲', '10 mins ago', 24),
          _buildPost(context, state, '2', 'Rahul', '👨‍🍳', 'Tried Neha\'s Rajma today. Definitely the best in Bellandur! 🔥', '45 mins ago', 12),
          _buildPost(context, state, '3', 'Simran', '👩‍🦰', 'Looking for healthy breakfast options nearby. Any suggestions?', '2 hours ago', 8),
        ],
      ),
    );
  }

  Widget _buildStoriesSection() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 5,
        itemBuilder: (context, index) {
          final avatars = ['👩‍🍳', '👨‍🍳', '👩', '👨', '👵'];
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.secondary]),
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Text(avatars[index], style: const TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(height: 4),
                Text('Neighbor', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPost(BuildContext context, AppState state, String id, String name, String avatar, String content, String time, int baseLikes) {
    final isLiked = state.likedPosts.contains(id);
    final likes = isLiked ? baseLikes + 1 : baseLikes;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: AppTheme.bg, child: Text(avatar)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(time, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                ],
              ),
              const Spacer(),
              const Icon(Icons.more_horiz, color: AppTheme.border),
            ],
          ),
          const SizedBox(height: 12),
          Text(content, style: const TextStyle(height: 1.4)),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildPostAction(
                context,
                isLiked ? Icons.favorite : Icons.favorite_border,
                '$likes',
                isLiked ? Colors.red : AppTheme.textMuted,
                () => state.toggleLike(id),
              ),
              const SizedBox(width: 24),
              _buildPostAction(context, Icons.chat_bubble_outline, 'Reply', AppTheme.textMuted, () => _showCommentBox(context, name)),
              const SizedBox(width: 24),
              _buildPostAction(context, Icons.share_outlined, 'Share', AppTheme.textMuted, () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostAction(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  void _showPostDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Post to Community'),
        content: const TextField(
          maxLines: 3,
          decoration: InputDecoration(hintText: "What's cooking, neighbor?"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Post')),
        ],
      ),
    );
  }

  void _showCommentBox(BuildContext context, String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Replying to $name...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
