import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:peshoo_scanner/welcome/google_login.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

FirebaseAuth auth = FirebaseAuth.instance;
GoogleLoginModal? googleLoginModal;
final GoogleSignIn googleSignIn = GoogleSignIn();

class _LoginScreenState extends State<LoginScreen> {
  static Future<GoogleLoginModal?> signInWithGoogle() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    GoogleLoginModal? googleLoginModal;
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();
    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      try {
        final UserCredential userCredential =
            await auth.signInWithCredential(credential);
        googleLoginModal = GoogleLoginModal(
            googleSignInAuthentication: googleSignInAuthentication,
            user: userCredential.user);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          if (kDebugMode) {
            print("Account exists with different credential");
          }
        } else if (e.code == 'invalid-credential') {
          if (kDebugMode) {
            print("Invalid Credential");
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print(e.toString());
        }
      }
    }
    return googleLoginModal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text(
          "Login!",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: signInWithGoogleUI(),
        ),
      ),
    );
  }

  signInWithGoogleUI() {
    return InkWell(
      onTap: () {
        signInWithGoogle();
        GoogleLogin.signInWithGoogle().then((data) {
          if (kDebugMode) {
            print(data?.googleSignInAuthentication.accessToken);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 30,
              width: 30,
              child: Image.network(
                "https://cdn.iconscout.com/icon/free/png-256/free-google-1772223-1507807.png",
                height: 40,
                width: 40,
              ),
            ),
            const SizedBox(
              width: 10.0,
            ),
            const Text(
              "Sign In With Google",
              style: TextStyle(
                  color: Colors.black, fontWeight: FontWeight.w600, height: 0),
            )
          ],
        ),
      ),
    );
  }
}
