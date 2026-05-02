import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../models/app_models.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  void _next() {
    if (_currentStep < 5) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      context.read<AppState>().setUserInfo(_nameController.text, _addressController.text);
      if (context.read<AppState>().activeRole == UserRole.cook) {
        Navigator.pushReplacementNamed(context, '/cook-home');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.text),
          onPressed: () {
            if (_currentStep > 0) {
              _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Row(
          children: List.generate(6, (index) => Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: index <= _currentStep ? AppTheme.primary : AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          )),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) => setState(() => _currentStep = index),
        children: [
          _buildNameStep(),
          _buildDietStep(),
          _buildCuisineStep(),
          _buildPreferenceStep(),
          _buildAllergiesStep(),
          _buildHealthGoalsStep(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ElevatedButton(
          onPressed: _isNextEnabled() ? _next : null,
          child: Text(_currentStep == 5 ? 'Finish' : 'Next'),
        ),
      ),
    );
  }

  bool _isNextEnabled() {
    if (_currentStep == 0) return _nameController.text.isNotEmpty && _addressController.text.isNotEmpty;
    return true;
  }

  Widget _buildNameStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Introduce Yourself', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('So your neighbors know who they are.', style: TextStyle(color: AppTheme.textMuted)),
          const SizedBox(height: 32),
          const Text('YOUR NAME', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(hintText: 'e.g. Avi Kumar'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 24),
          const Text('PICKUP ADDRESS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
          const SizedBox(height: 8),
          TextField(
            controller: _addressController,
            decoration: const InputDecoration(hintText: 'House no, Layout, Near landmark'),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildDietStep() {
    final state = context.watch<AppState>();
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Dietary Preference', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('This helps us show you relevant cooks.', style: TextStyle(color: AppTheme.textMuted)),
          const SizedBox(height: 32),
          _buildOption('🥬 Pure Vegetarian', 'veg', state.diet == 'veg'),
          _buildOption('🍗 Non-Vegetarian', 'nonveg', state.diet == 'nonveg'),
          _buildOption('🥛 Eggetarian', 'eggetarian', state.diet == 'eggetarian'),
          _buildOption('🥗 Vegan', 'vegan', state.diet == 'vegan'),
        ],
      ),
    );
  }

  Widget _buildOption(String title, String value, bool selected) {
    return GestureDetector(
      onTap: () => setState(() => context.read<AppState>().diet = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primarySoft : AppTheme.bg,
          border: Border.all(color: selected ? AppTheme.primary : AppTheme.border, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
            if (selected) const Icon(Icons.check_circle, color: AppTheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildCuisineStep() {
    final state = context.watch<AppState>();
    final List<String> available = ['North Indian', 'South Indian', 'Punjabi', 'Bengali', 'Andhra', 'Healthy', 'Maharashtrian'];
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Favorite Cuisines', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('Pick at least 2 cuisines you love.', style: TextStyle(color: AppTheme.textMuted)),
          const SizedBox(height: 32),
          Wrap(
            spacing: 8,
            runSpacing: 12,
            children: available.map((c) {
              final selected = state.cuisines.contains(c);
              return FilterChip(
                label: Text(c),
                selected: selected,
                onSelected: (val) {
                  setState(() {
                    if (val) { state.cuisines.add(c); }
                    else { state.cuisines.remove(c); }
                  });
                },
                selectedColor: AppTheme.primarySoft,
                checkmarkColor: AppTheme.primary,
                labelStyle: TextStyle(
                  color: selected ? AppTheme.primary : AppTheme.text,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100), side: BorderSide(color: selected ? AppTheme.primary : AppTheme.border, width: 2)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceStep() {
    final state = context.watch<AppState>();
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your Taste', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('Tailor the discovery engine to your vibe.', style: TextStyle(color: AppTheme.textMuted)),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Spice Level', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(state.spiceLevel < 33 ? 'Mild' : state.spiceLevel < 66 ? 'Medium' : 'Hot', 
                   style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
            ],
          ),
          Slider(
            value: state.spiceLevel,
            onChanged: (v) => setState(() => state.spiceLevel = v),
            min: 0,
            max: 100,
            activeColor: AppTheme.primary,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Budget per meal', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('₹${state.budgetLevel.round()}', 
                   style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
            ],
          ),
          Slider(
            value: state.budgetLevel,
            onChanged: (v) => setState(() => state.budgetLevel = v),
            min: 40,
            max: 200,
            divisions: 16,
            activeColor: AppTheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildAllergiesStep() {
    final state = context.watch<AppState>();
    final List<String> common = ['Peanuts', 'Dairy', 'Gluten', 'Eggs', 'Soy', 'Shellfish', 'Mustard', 'None'];
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Food Allergies', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('Safety first. We will flag these for cooks.', style: TextStyle(color: AppTheme.textMuted)),
          const SizedBox(height: 32),
          Wrap(
            spacing: 8,
            runSpacing: 12,
            children: common.map((a) {
              final selected = state.allergies.contains(a);
              return FilterChip(
                label: Text(a),
                selected: selected,
                onSelected: (val) {
                  setState(() {
                    if (val) { state.allergies.add(a); }
                    else { state.allergies.remove(a); }
                  });
                },
                selectedColor: AppTheme.primarySoft,
                checkmarkColor: AppTheme.primary,
                labelStyle: TextStyle(
                  color: selected ? AppTheme.primary : AppTheme.text,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100), side: BorderSide(color: selected ? AppTheme.primary : AppTheme.border, width: 2)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthGoalsStep() {
    final state = context.watch<AppState>();
    final List<String> goals = ['Weight Loss', 'High Protein', 'Low Carb', 'Muscle Gain', 'Better Digestion', 'Energy Boost'];
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Health Goals', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('Tell us what you want to achieve.', style: TextStyle(color: AppTheme.textMuted)),
          const SizedBox(height: 32),
          Wrap(
            spacing: 8,
            runSpacing: 12,
            children: goals.map((g) {
              final selected = state.healthGoals.contains(g);
              return FilterChip(
                label: Text(g),
                selected: selected,
                onSelected: (val) {
                  setState(() {
                    if (val) { state.healthGoals.add(g); }
                    else { state.healthGoals.remove(g); }
                  });
                },
                selectedColor: AppTheme.primarySoft,
                checkmarkColor: AppTheme.primary,
                labelStyle: TextStyle(
                  color: selected ? AppTheme.primary : AppTheme.text,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100), side: BorderSide(color: selected ? AppTheme.primary : AppTheme.border, width: 2)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
