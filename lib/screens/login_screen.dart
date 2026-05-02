import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isOtpSent = false;
  final List<TextEditingController> _otpControllers = List.generate(4, (_) => TextEditingController());
  String? _generatedOtp;

  void _sendOtp() {
    if (_phoneController.text.length == 10) {
      setState(() {
        _isOtpSent = true;
        _generatedOtp = (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Your OTP is: $_generatedOtp'),
          backgroundColor: AppTheme.secondary,
        ),
      );
    }
  }

  void _verifyOtp() {
    String enteredOtp = _otpControllers.map((c) => c.text).join();
    if (enteredOtp == _generatedOtp) {
      context.read<AppState>().setPhone('+91 ${_phoneController.text}');
      Navigator.pushReplacementNamed(context, '/onboarding');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wrong OTP. Please try again.')),
      );
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
                  onPressed: _phoneController.text.length == 10 ? _sendOtp : null,
                  child: const Text('Get OTP'),
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
                  onPressed: _otpControllers.every((c) => c.text.isNotEmpty) ? _verifyOtp : null,
                  child: const Text('Verify & Continue'),
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
