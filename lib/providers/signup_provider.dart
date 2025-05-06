import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:peshoo_scanner/helpers/auth_helpers.dart';

class SignUpProvider with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  final AuthHelpers _authHelpers = AuthHelpers();

  Future<void> signUp(
    String email,
    String password,
    String confirmPassword, {
    required BuildContext context,
    required String mobile,
    required String username,
    required String firstName,
    required String lastName,
  }) async {
    if (password != confirmPassword) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Passwords do not match.')));
      });
      throw FirebaseAuthException(
        message: 'Passwords do not match.',
        code: 'passwords-do-not-match',
      );
    }

    try {
      final emailCheck = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      final usernameCheck = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();
      final mobileCheck = await _firestore
          .collection('users')
          .where('mobile', isEqualTo: mobile)
          .get();

      if (emailCheck.docs.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Email is already in use.')));
        });
        throw FirebaseAuthException(
          message: 'Email already in use. Please use a different email.',
          code: 'email-already-in-use',
        );
      }

      if (usernameCheck.docs.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Username already exists.')));
        });
        throw FirebaseAuthException(
          message: 'Username already exists. Please use a different username.',
          code: 'username-already-in-use',
        );
      }

      if (mobileCheck.docs.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Mobile number already exists.')));
        });
        throw FirebaseAuthException(
          message:
              'Mobile number already exists. Please use a different mobile number.',
          code: 'mobile-already-in-use',
        );
      }

      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      _user = userCredential.user;

      await _firestore.collection('users').doc(_user!.uid).set({
        'uid': _user!.uid,
        'email': email,
        'username': username,
        'mobile': mobile,
        'firstName': firstName,
        'lastName': lastName,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _authHelpers.sendVerificationEmail(_user!);
      await _authHelpers.sendSMSVerification(mobile, _firebaseAuth);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Successfully registered! A verification code has been sent to your email.')));
      });
    } catch (e) {
      final String errorMessage = (e is FirebaseAuthException)
          ? e.message ?? 'An error occurred'
          : 'An unknown error occurred';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessage)));
      });
    }
  }
}
