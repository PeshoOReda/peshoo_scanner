import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthHelpers {
  Future<void> sendVerificationEmail(User user) async {
    try {
      await user.sendEmailVerification();
    } catch (e) {
      if (kDebugMode) {
        print("Error sending email verification: $e");
      }
    }
  }

  Future<void> sendSMSVerification(String mobile, FirebaseAuth auth) async {
    try {
      await auth.verifyPhoneNumber(
        phoneNumber: mobile,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          if (kDebugMode) {
            print("Error sending SMS verification: $e");
          }
        },
        codeSent: (String verificationId, int? resendToken) {},
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error sending SMS verification: $e");
      }
    }
  }

  Future<void> saveVerificationCode(String verificationCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('verification_code', verificationCode);
  }
}
