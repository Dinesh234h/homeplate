import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../models/app_models.dart';

class CookLoginScreen extends StatefulWidget {
  const CookLoginScreen({super.key});

  @override
  State<CookLoginScreen> createState() => _CookLoginScreenState();
}

class _CookLoginScreenState extends State<CookLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _kitchenController = TextEditingController();
  bool _otpSent = false;
  bool _isLoading = false;

  void _handleLogin() async {
    if (_phoneController.text.length < 10) return;
    
    setState(() => _isLoading = true);
    
    // Mock OTP flow
    await Future.delayed(const Duration(seconds: 2));
    
    if (!_otpSent) {
      setState(() {
        _otpSent = true;
        _isLoading = false;
      });
    } else {
      if (_otpController.text == '1234') {
        final state = context.read<AppState>();
        state.setUserInfo(_kitchenController.text.isEmpty ? 'Chef Neha' : _kitchenController.text, '123, Kitchen Street');
        state.setRole(UserRole.cook);
        state.switchRole(UserRole.cook);
        Navigator.pushReplacementNamed(context, '/cook-home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid OTP'), backgroundColor: AppTheme.danger),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A), // Deep dark theme for professional chefs
      body: Stack(
        children: [
          // Background Image with gradient overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: Image.network(
                'https://images.unsplash.com/photo-1556910103-1c02745aae4d?q=80&w=2070&auto=format&fit=crop',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withValues(alpha: 0.9), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  const Icon(Icons.restaurant_menu, color: AppTheme.accent, size: 48),
                  const SizedBox(height: 24),
                  const Text('HomePlate', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: -1)),
                  const Text('FOR CHEFS & KITCHENS', style: TextStyle(color: AppTheme.accent, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  const SizedBox(height: 60),
                  
                  if (!_otpSent) ...[
                    _buildInputLabel('KITCHEN NAME'),
                    _buildTextField(_kitchenController, 'e.g. Neha\'s Kitchen', Icons.storefront),
                    const SizedBox(height: 24),
                    _buildInputLabel('PHONE NUMBER'),
                    _buildTextField(_phoneController, 'Enter 10 digit number', Icons.phone, keyboard: TextInputType.phone),
                  ] else ...[
                    const Text('Verify your account', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const Text('We sent a code to your phone', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 32),
                    _buildInputLabel('OTP CODE'),
                    _buildTextField(_otpController, 'Enter 4 digit code', Icons.lock_outline, keyboard: TextInputType.number),
                  ],
                  
                  const Spacer(),
                  _buildPrimaryButton(),
                  const SizedBox(height: 24),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                      child: Text('ARE YOU A CUSTOMER? LOGIN HERE', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(label, style: const TextStyle(color: AppTheme.accent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {TextInputType keyboard = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
          prefixIcon: Icon(icon, color: AppTheme.accent, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton() {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 10,
          shadowColor: AppTheme.accent.withValues(alpha: 0.4),
        ),
        child: _isLoading 
          ? const CircularProgressIndicator(color: Colors.black)
          : Text(_otpSent ? 'ENTER KITCHEN' : 'SEND OTP', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16)),
      ),
    );
  }
}
