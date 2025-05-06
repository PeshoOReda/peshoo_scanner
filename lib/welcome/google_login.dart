import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleLogin {
  static Future<GoogleLoginModal?> signInWithGoogle() async {
    return null;
  }
}

class GoogleLoginModal {
  User? user;
  GoogleSignInAuthentication googleSignInAuthentication;
  GoogleLoginModal({required this.googleSignInAuthentication, this.user});
}
