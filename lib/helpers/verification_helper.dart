// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:peshoo_scanner/helpers/context_helpers.dart';

class VerificationHelper {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> checkIfVerified(BuildContext context) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.reload();
      if (!user.emailVerified) {
        await _firebaseAuth.signOut();
        showErrorSnackbar(context, 'Please verify your email first.');
      } else {
        final userSnapshot =
            await _firestore.collection('users').doc(user.uid).get();
        if (userSnapshot['phoneVerified'] != true) {
          await _firebaseAuth.signOut();
          showErrorSnackbar(context, 'Please verify your phone number first.');
        }
      }
    }
  }
}
