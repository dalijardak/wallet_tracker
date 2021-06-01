import 'package:flutter/material.dart';
import 'package:wallet_tracket/view/home.dart';
import 'package:wallet_tracket/view/welcomePage.dart';
import 'package:wallet_tracket/view/authentication.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallet Tracker',
      theme: ThemeData.dark(),
      routes: {
        "/": (context) => Authentication(),
        "/welcome": (context) => Welcome(),
        "/home": (context) => Home(),
      },
    );
  }
}
