import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';


class SignInDemo extends StatefulWidget {
  @override
  State createState() => SignInDemoState();
}

class SignInDemoState extends State<SignInDemo> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  GoogleSignInAccount? _currentUser;

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
      if (account != null) {
        _handleFirebaseSignIn(account);
      }
    });
    _googleSignIn.signInSilently();
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleSignOut() async {
    await FirebaseAuth.instance.signOut();
    await _googleSignIn.disconnect();
  }

  Future<void> _handleFirebaseSignIn(GoogleSignInAccount account) async {
    final GoogleSignInAuthentication googleAuth = await account.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    final User? user = userCredential.user;

    if (user != null) {
      final userData = {
        'name': user.displayName,
        'email': user.email,
        'photoUrl': user.photoURL,
        'uid': user.uid,
        'lastSignIn': DateTime.now(),
      };

      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      await userDoc.set(userData, SetOptions(merge: true));
      Navigator.pushReplacementNamed(context, '/scanner');
    }
  }

  @override
  Widget build(BuildContext context) {
    GoogleSignInAccount? user = _currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Sign-In'),
        actions: <Widget>[
          user != null
              ? IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: _handleSignOut,
                )
              : Container()
        ],
      ),
      body: ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            user != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ListTile(
                        leading: GoogleUserCircleAvatar(identity: user),
                        title: Text(user.displayName ?? ''),
                        subtitle: Text(user.email),
                      ),
                      ElevatedButton(
                        onPressed: _handleSignOut,
                        child: const Text('SIGN OUT'),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text('You are not currently signed in.'),
                      ElevatedButton(
                        onPressed: _handleSignIn,
                        child: const Text('SIGN IN'),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

