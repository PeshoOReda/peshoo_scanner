import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:peshoo_scanner/firebase_options.dart';
import 'package:peshoo_scanner/my_app.dart';
import 'package:peshoo_scanner/providers/auth_provider.dart';
import 'package:peshoo_scanner/providers/barcode_provider.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => BarcodeProvider(context)),
      ChangeNotifierProvider(create: (_) => AuthProvider()),
    ], child: MyApp()),
  );
}