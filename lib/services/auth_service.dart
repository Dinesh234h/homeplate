import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  // Guarded access to FirebaseAuth to prevent [core/no-app] errors 
  // when Firebase is not initialized (e.g. missing google-services.json)
  FirebaseAuth? get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (e) {
      debugPrint("AuthService: Firebase not initialized.");
      return null;
    }
  }

  Future<void> verifyPhone({
    required String phoneNumber,
    required Function(String, int?) onCodeSent,
    required Function(FirebaseAuthException) onVerificationFailed,
    required Function(PhoneAuthCredential) onVerificationCompleted,
  }) async {
    final auth = _auth;
    if (auth == null) {
      debugPrint("Firebase Auth not available, using Mock fallback");
      onCodeSent("MOCK_VERIFICATION_ID", 123);
      return;
    }

    try {
      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: onVerificationCompleted,
        verificationFailed: onVerificationFailed,
        codeSent: onCodeSent,
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      debugPrint("Firebase verifyPhoneNumber failed: $e");
      onCodeSent("MOCK_VERIFICATION_ID", 123);
    }
  }

  Future<UserCredential?> signInWithOTP(String verificationId, String smsCode) async {
    if (verificationId == "MOCK_VERIFICATION_ID") {
      debugPrint("Using Mock OTP verification (1234)");
      return null; // Logic handled in LoginScreen for mock
    }
    
    final auth = _auth;
    if (auth == null) return null;

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint("OTP Sign-in failed: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth?.signOut();
  }

  User? get currentUser => _auth?.currentUser;
}
