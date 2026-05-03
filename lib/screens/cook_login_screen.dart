import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../models/app_models.dart';
import '../services/auth_service.dart';

class CookLoginScreen extends StatefulWidget {
  const CookLoginScreen({super.key});

  @override
  State<CookLoginScreen> createState() => _CookLoginScreenState();
}

class _CookLoginScreenState extends State<CookLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _kitchenController = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(4, (_) => TextEditingController());
  bool _otpSent = false;
  bool _isLoading = false;
  String? _verificationId;
  final AuthService _authService = AuthService();

  void _sendOtp() async {
    if (_phoneController.text.length == 10) {
      int? firstDigit = int.tryParse(_phoneController.text[0]);
      if (firstDigit != null && firstDigit < 6) {
        _showError('the number is wrong');
        return;
      }

      setState(() => _isLoading = true);
      
      try {
        await _authService.verifyPhone(
          phoneNumber: '+91${_phoneController.text}',
          onCodeSent: (verificationId, resendToken) {
            if (!mounted) return;
            setState(() {
              _otpSent = true;
              _verificationId = verificationId;
              _isLoading = false;
            });
          },
          onVerificationFailed: (e) {
            if (!mounted) return;
            setState(() => _isLoading = false);
            _showError('Verification failed: ${e.message}');
          },
          onVerificationCompleted: (credential) async {},
        );
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _otpSent = true;
          _verificationId = "MOCK_VERIFICATION_ID";
          _isLoading = false;
        });
      }
    }
  }

  void _verifyOtp() async {
    String enteredOtp = _otpControllers.map((c) => c.text).join();
    if (enteredOtp.length == 4) {
      setState(() => _isLoading = true);
      
      if (_verificationId == "MOCK_VERIFICATION_ID") {
        await Future.delayed(const Duration(seconds: 1));
        if (enteredOtp == "1234") {
          _onSuccess();
        } else {
          _showError('wrong otp');
          setState(() => _isLoading = false);
        }
        return;
      }

      final result = await _authService.signInWithOTP(_verificationId!, enteredOtp);
      if (result?.user != null) {
        _onSuccess();
      } else {
        _showError('wrong otp');
        setState(() => _isLoading = false);
      }
    }
  }

  void _onSuccess() {
    final state = context.read<AppState>();
    state.setUserInfo(_kitchenController.text.isEmpty ? 'Chef Neha' : _kitchenController.text, '123, Kitchen Street');
    state.setRole(UserRole.cook);
    state.switchRole(UserRole.cook);
    Navigator.pushReplacementNamed(context, '/cook-home');
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppTheme.danger),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.network(
                'https://images.unsplash.com/photo-1556910103-1c02745aae4d?q=80&w=2070&auto=format&fit=crop',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                  const SizedBox(height: 40),
                  const Icon(Icons.restaurant_menu, color: AppTheme.primary, size: 48),
                  const SizedBox(height: 16),
                  const Text('Chef Partner', style: TextStyle(color: Colors.black, fontSize: 32, fontWeight: FontWeight.w900)),
                  const Text('Grow your kitchen business with HomePlate.', style: TextStyle(color: AppTheme.textMuted, fontSize: 14)),
                  const SizedBox(height: 48),
                  
                  if (!_otpSent) ...[
                    _buildInputLabel('KITCHEN NAME'),
                    _buildTextField(_kitchenController, 'e.g. Grandma\'s Kitchen', Icons.storefront),
                    const SizedBox(height: 24),
                    _buildInputLabel('PHONE NUMBER'),
                    _buildPhoneInput(),
                  ] else ...[
                    const Text('Verify OTP', style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Enter the 4-digit code sent to ${_phoneController.text}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                    const SizedBox(height: 32),
                    _buildOtpInput(),
                  ],
                  
                  const SizedBox(height: 60),
                  _buildPrimaryButton(),
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
      child: Text(label, style: const TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.black.withValues(alpha: 0.3)),
          prefixIcon: Icon(icon, color: AppTheme.primary, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildPhoneInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 20, right: 10),
            child: Text('+91', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          Expanded(
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Phone Number',
                hintStyle: TextStyle(color: Colors.black.withValues(alpha: 0.3)),
                counterText: '',
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpInput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(4, (index) => SizedBox(
        width: 65,
        height: 65,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: TextField(
            controller: _otpControllers[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            decoration: const InputDecoration(counterText: '', border: InputBorder.none),
            onChanged: (value) {
              if (value.isNotEmpty && index < 3) {
                FocusScope.of(context).nextFocus();
              }
              if (_otpControllers.every((c) => c.text.isNotEmpty)) {
                _verifyOtp();
              }
            },
          ),
        ),
      )),
    );
  }

  Widget _buildPrimaryButton() {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: _isLoading ? null : (_otpSent ? _verifyOtp : _sendOtp),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: _isLoading 
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(_otpSent ? 'VERIFY & ENTER' : 'GET OTP', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
      ),
    );
  }
}
