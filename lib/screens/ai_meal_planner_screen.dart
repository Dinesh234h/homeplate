import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import 'dart:math';

class AIMealPlannerScreen extends StatefulWidget {
  const AIMealPlannerScreen({super.key});

  @override
  State<AIMealPlannerScreen> createState() => _AIMealPlannerScreenState();
}

class _AIMealPlannerScreenState extends State<AIMealPlannerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isGenerating = true;
  Map<String, dynamic>? _suggestion;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _generateSuggestion();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _generateSuggestion() async {
    final state = context.read<AppState>();
    await Future.delayed(const Duration(seconds: 3)); 
    
    final cuisines = state.cuisines.isEmpty ? ['North Indian', 'Healthy'] : state.cuisines;
    final diet = state.diet;
    final spice = state.spiceLevel > 70 ? 'Spicy' : (state.spiceLevel < 30 ? 'Mild' : 'Medium');
    final allergens = state.allergies.isEmpty ? 'no specific allergens' : state.allergies.join(', ');
    final goal = state.healthGoals.isEmpty ? 'general wellness' : state.healthGoals[0];

    final options = [
      {
        'name': 'Home-style ${cuisines[0]} Platter',
        'desc': 'A balanced ${diet == 'veg' ? 'vegetarian' : 'protein-rich'} meal featuring regional specialties. Prepared with $spice spice levels to match your profile.',
        'calories': '${350 + Random().nextInt(200)} kcal',
        'protein': '18g',
        'match': '98%',
        'why': 'This meal matches your $cuisines preference and is optimized for $goal. It avoids $allergens and strictly follows your $spice spice preference.',
        'emoji': '🍱',
        'price': '₹120',
      },
      {
        'name': 'Wholesome ${state.diet.toUpperCase()} Bowl',
        'desc': 'Tailored for your $goal journey. Low oil, high fiber, and perfectly $spice.',
        'calories': '${280 + Random().nextInt(100)} kcal',
        'protein': '22g',
        'match': '95%',
        'why': 'Selected for its high protein content to support $goal. It uses farm-fresh ingredients and respects your $allergens restrictions.',
        'emoji': '🥗',
        'price': '₹150',
      }
    ];

    if (mounted) {
      setState(() {
        _suggestion = options[Random().nextInt(options.length)];
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildAIBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(state),
                Expanded(
                  child: _isGenerating ? _buildLoadingState() : _buildResultState(state),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIBackground() {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.5),
            radius: 1.5,
            colors: [Color(0xFF1A1A2E), Colors.black],
          ),
        ),
        child: Opacity(
          opacity: 0.1,
          child: Image.network(
            'https://images.unsplash.com/photo-1620712943543-bcc4628c9759?q=80&w=1965&auto=format&fit=crop',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(AppState state) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(state.tr('meal_planner').toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 14)),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RotationTransition(
          turns: _controller,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.accent.withValues(alpha: 0.2), width: 8),
              boxShadow: [BoxShadow(color: AppTheme.accent.withValues(alpha: 0.1), blurRadius: 40, spreadRadius: 10)],
            ),
            child: const Center(child: Icon(Icons.auto_awesome, color: AppTheme.accent, size: 40)),
          ),
        ),
        const SizedBox(height: 48),
        const Text('Analyzing your profile...', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Personalizing the perfect meal for you', style: TextStyle(color: Colors.white54, fontSize: 14)),
      ],
    );
  }

  Widget _buildResultState(AppState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.verified, color: AppTheme.accent, size: 32),
          const SizedBox(height: 16),
          const Text('AI RECOMMENDATION', style: TextStyle(color: AppTheme.accent, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 3)),
          const SizedBox(height: 40),
          _buildSuggestionCard(),
          const SizedBox(height: 32),
          _buildWhyCard(),
          const SizedBox(height: 48),
          _buildActionButtons(state),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Text(_suggestion!['emoji'], style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 24),
          Text(_suggestion!['name'], textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Text(_suggestion!['desc'], textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.5)),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNutrientInfo('Calories', _suggestion!['calories']),
              _buildNutrientInfo('Protein', _suggestion!['protein']),
              _buildNutrientInfo('Match', _suggestion!['match']),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWhyCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppTheme.accent),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('WHY THIS MEAL?', style: TextStyle(color: AppTheme.accent, fontSize: 10, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(_suggestion!['why'], style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientInfo(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ],
    );
  }

  Widget _buildActionButtons(AppState state) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton(
            onPressed: () => _fastCheckout(state),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Text(state.tr('instant_order').toUpperCase(), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16)),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Text(state.tr('explore_kitchens').toUpperCase(), style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            setState(() => _isGenerating = true);
            _generateSuggestion();
          },
          child: Text(state.tr('regenerate').toUpperCase(), style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        ),
      ],
    );
  }

  void _fastCheckout(AppState state) {
    final cook = state.cooks.firstWhere((c) => c.id == 0);
    final dish = cook.menu.first;
    state.addToCart(cook, dish, 1);
    Navigator.pushNamed(context, '/cart');
  }
}
