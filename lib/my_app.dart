import 'package:flutter/material.dart';
import 'package:peshoo_scanner/constant/routes.dart';
import 'package:peshoo_scanner/ui/scanner_screen.dart';
import 'package:peshoo_scanner/welcome/log.dart';
import 'package:peshoo_scanner/welcome/sign.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ScannerScreen(),
        routes: {
          Routes.signGoogle: (context) => LoginScreen(),
          Routes.signUpRoute: (context) => SignUpScreen(),
          Routes.scannerRoute: (context) => ScannerScreen()
        });
  }
}
//
// class AuthenticationWrapper extends StatelessWidget {
//   const AuthenticationWrapper({super.key});
//
//   Future<bool> checkIfLoggedIn() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getBool('is_logged_in') ?? false;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<bool>(
//       future: checkIfLoggedIn(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(child: CircularProgressIndicator());
//         } else {
//           if (snapshot.hasData && snapshot.data!) {
//             return ScannerScreen();
//           } else {
//             return LoginScreen();
//           }
//         }
//       },
//     );
//   }
// }
