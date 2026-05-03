import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/app_models.dart';

class CookLoginScreen extends StatefulWidget {
  const CookLoginScreen({super.key});

  @override
  State<CookLoginScreen> createState() => _CookLoginScreenState();
}

class _CookLoginScreenState extends State<CookLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final otpController = TextEditingController();
  bool showOtp = false;

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    
    if (!showOtp) {
      int? firstDigit = int.tryParse(phoneController.text[0]);
      if (firstDigit != null && firstDigit < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('the number is wrong'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      setState(() => showOtp = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP sent to your number')),
      );
    } else {
      if (otpController.text != "1234") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('wrong otp'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      context.read<AppState>().setRole(UserRole.cook);
      if (context.mounted) {
        context.read<AppState>().setPhone(phoneController.text);
        context.read<AppState>().setUserInfo(nameController.text, addressController.text);
        Navigator.pushReplacementNamed(context, '/cook-home');
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 80),
                const Text('Chef Partner', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange, letterSpacing: 2)),
                const SizedBox(height: 8),
                const Text('Welcome to\nHomePlate', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.black, height: 1.1)),
                const SizedBox(height: 48),
                
                // Name Field
                _buildLabel('KITCHEN NAME'),
                TextFormField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  decoration: _inputDecoration(Icons.restaurant_outlined, 'e.g. Grandma\'s Kitchen'),
                  validator: (v) => v!.isEmpty ? 'Please enter kitchen name' : null,
                ),
                const SizedBox(height: 24),

                // Phone Field
                _buildLabel('MOBILE NUMBER'),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  decoration: _inputDecoration(Icons.phone_android_outlined, '10-digit number'),
                  validator: (v) => (v == null || v.length != 10) ? 'Enter valid 10-digit number' : null,
                ),
                const SizedBox(height: 24),

                // Address Field
                _buildLabel('KITCHEN ADDRESS'),
                TextFormField(
                  controller: addressController,
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  decoration: _inputDecoration(Icons.location_on_outlined, 'Full address for deliveries'),
                  validator: (v) => v!.isEmpty ? 'Please enter address' : null,
                ),
                const SizedBox(height: 24),

                if (showOtp) ...[
                  _buildLabel('ENTER OTP'),
                  TextFormField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 8),
                    textAlign: TextAlign.center,
                    decoration: _inputDecoration(Icons.lock_outline, 'XXXX'),
                    validator: (v) => (v == null || v.length != 4) ? 'Enter 4-digit OTP' : null,
                  ),
                  const SizedBox(height: 32),
                ],

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(showOtp ? 'START COOKING' : 'SEND OTP', style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black54, letterSpacing: 1.5)),
    );
  }

  InputDecoration _inputDecoration(IconData icon, String hint) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.black, size: 20),
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black26, fontWeight: FontWeight.normal),
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.black, width: 1)),
    );
  }
}
