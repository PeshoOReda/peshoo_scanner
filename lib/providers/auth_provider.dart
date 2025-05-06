import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:peshoo_scanner/helpers/auth_helpers.dart';
import 'package:peshoo_scanner/helpers/context_helpers.dart';

import '../constant/routes.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthHelpers _authHelpers = AuthHelpers();
  User? _user;

  User? get user => _user;

  bool get isLoggedIn => _user != null;

  AuthProvider() {
    _firebaseAuth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _user = user;
    notifyListeners();
  }

  Future<void> login(String identifier, String password, String method,
      BuildContext context) async {
    try {
      String email = identifier;

      if (method == 'username') {
        final userSnapshot = await _firestore
            .collection('users')
            .where('username', isEqualTo: identifier)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          email = userSnapshot.docs.first['email'];
        }
      } else if (method == 'phone') {
        final phoneSnapshot = await _firestore
            .collection('users')
            .where('mobile', isEqualTo: identifier)
            .get();

        if (phoneSnapshot.docs.isNotEmpty) {
          email = phoneSnapshot.docs.first['email'];
        }
      }

      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      _user = _firebaseAuth.currentUser;

      if (_user == null || !_user!.emailVerified) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please verify your email first.')));
        });
        await _firebaseAuth.signOut();
        _user = null;
      } else {
        await _checkIfVerified(context);
        notifyListeners();
      }
    } catch (error) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Login failed: $error')));
      });
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).delete();
        await user.delete();
        _user = null;
        showSuccessSnackbar(context, 'Account deleted successfully.');
        Navigator.pushReplacementNamed(context, Routes.signGoogle);
        notifyListeners();
      }
    } catch (e) {
      showErrorSnackbar(context, getFirebaseAuthExceptionMessage(e));
    }
  }

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

      await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      _user = _firebaseAuth.currentUser;

      await _firestore.collection('users').doc(_user!.uid).set({
        'email': email,
        'username': username,
        'mobile': mobile,
        'firstName': firstName,
        'lastName': lastName,
        'createdAt': FieldValue.serverTimestamp(),
      });

      final String userToken = await _user!.getIdToken() ?? '';
      await _authHelpers.saveVerificationCode(userToken);
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

  Future<void> logout(BuildContext context) async {
    await _firebaseAuth.signOut();
    _user = null;
    notifyListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Successfully logged out.')));
    });
  }

  Future<void> _checkIfVerified(BuildContext context) async {
    if (_user != null) {
      await _user!.reload();
      if (!_user!.emailVerified) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please verify your email first.')));
        });
        logout(context);
      } else {
        final userSnapshot =
            await _firestore.collection('users').doc(_user!.uid).get();
        if (userSnapshot['phoneVerified'] != true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Please verify your phone number first.')));
          });
          logout(context);
        }
      }
    }
  }

  String getFirebaseAuthExceptionMessage(dynamic exception) {
    if (exception is FirebaseAuthException) {
      switch (exception.code) {
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'user-disabled':
          return 'The user account has been disabled.';
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Incorrect password.';
        default:
          return 'An unknown error occurred.';
      }
    }
    return 'An unknown error occurred.';
  }
}
