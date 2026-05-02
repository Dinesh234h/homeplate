import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/app_models.dart';
import '../theme/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primary, Color(0xFFF4B942)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Center(
                  child: Text('🏠', style: TextStyle(fontSize: 50)),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'HomePlate',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1.2,
                ),
              ),
              const SizedBox(height: 14),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Authentic home-cooked meals from your neighbors.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildActionButton(
                      context,
                      'I want to Eat',
                      Colors.white,
                      AppTheme.primary,
                      () {
                        context.read<AppState>().setRole(UserRole.consumer);
                        Navigator.pushNamed(context, '/login');
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildActionButton(
                      context,
                      'I want to Cook',
                      Colors.white.withValues(alpha: 0.18),
                      Colors.white,
                      () {
                        context.read<AppState>().setRole(UserRole.cook);
                        Navigator.pushNamed(context, '/login');
                      },
                      isOutline: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String text, Color bg, Color textColor, VoidCallback onPressed, {bool isOutline = false}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: textColor,
          side: isOutline ? const BorderSide(color: Colors.white, width: 1) : null,
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}
