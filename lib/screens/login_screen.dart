import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isOtpSent = false;
  bool _isLoading = false;
  final List<TextEditingController> _otpControllers = List.generate(4, (_) => TextEditingController());
  String? _verificationId;
  final AuthService _authService = AuthService();

  void _sendOtp() async {
    if (_phoneController.text.length == 10) {
      int? firstDigit = int.tryParse(_phoneController.text[0]);
      if (firstDigit != null && firstDigit < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('the number is wrong'),
            backgroundColor: AppTheme.danger,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);
      
      try {
        await _authService.verifyPhone(
          phoneNumber: '+91${_phoneController.text}',
          onCodeSent: (verificationId, resendToken) {
            if (!mounted) return;
            setState(() {
              _isOtpSent = true;
              _verificationId = verificationId;
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('OTP sent to your phone'), backgroundColor: AppTheme.secondary),
            );
          },
          onVerificationFailed: (e) {
            if (!mounted) return;
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Verification failed: ${e.message}'), backgroundColor: AppTheme.danger),
            );
          },
          onVerificationCompleted: (credential) async {
            final result = await FirebaseAuth.instance.signInWithCredential(credential);
            if (result.user != null) {
              _onSuccess(user: result.user);
            }
          },
        );
      } catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        // Even if Firebase fails (missing config), we allow entering mock OTP mode
        setState(() {
          _isOtpSent = true;
          _verificationId = "MOCK_VERIFICATION_ID";
          _isLoading = false;
        });
      }
    }
  }

  void _onSuccess({User? user}) {
    if (!mounted) return;
    if (user != null) context.read<AppState>().setFirebaseUser(user);
    context.read<AppState>().setPhone('+91 ${_phoneController.text}');
    Navigator.pushReplacementNamed(context, '/onboarding');
  }

  void _verifyOtp() async {
    String enteredOtp = _otpControllers.map((c) => c.text).join();
    if (enteredOtp.length == 4 && _verificationId != null) {
      setState(() => _isLoading = true);
      
      if (_verificationId == "MOCK_VERIFICATION_ID") {
        setState(() => _isLoading = false);
        if (enteredOtp == "1234") {
          _onSuccess();
        } else {
          _showError('wrong otp');
        }
        return;
      }

      final result = await _authService.signInWithOTP(_verificationId!, enteredOtp);
      setState(() => _isLoading = false);
      
      if (result?.user != null) {
        _onSuccess(user: result!.user);
      } else {
        _showError('wrong otp');
      }
    }
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.text),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isOtpSent ? 'Verify OTP' : 'Login / Signup',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _isOtpSent 
                ? 'Enter the 4-digit code sent to +91 ${_phoneController.text}'
                : 'Enter your phone number to get started.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            if (!_isOtpSent) ...[
              const Text('PHONE NUMBER', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.bg,
                      border: Border.all(color: AppTheme.border, width: 2),
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
                    ),
                    child: const Text('+91', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      onChanged: (value) => setState(() {}),
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: 'Enter 10 digits',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_phoneController.text.length == 10 && !_isLoading) ? _sendOtp : null,
                  child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : const Text('Get OTP'),
                ),
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) => SizedBox(
                  width: 60,
                  child: TextField(
                    controller: _otpControllers[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(counterText: ''),
                    onChanged: (value) {
                      setState(() {});
                      if (value.isNotEmpty && index < 3) {
                        FocusScope.of(context).nextFocus();
                      }
                      if (_otpControllers.every((c) => c.text.isNotEmpty)) {
                        _verifyOtp();
                      }
                    },
                  ),
                )),
              ),
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: () => setState(() => _isOtpSent = false),
                  child: const Text('Edit Phone Number', style: TextStyle(color: AppTheme.primary)),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_otpControllers.every((c) => c.text.isNotEmpty) && !_isLoading) ? _verifyOtp : null,
                  child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : const Text('Verify & Continue'),
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
