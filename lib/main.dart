// main.dart
import 'package:flutter/material.dart';
import 'package:dapp_mfa/screens/Registration.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ethereum Wallet App',
      home: RegistrationScreen(),
    );
  }
}
