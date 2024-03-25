import 'package:flutter/material.dart';
import '../wallet/Wallet_Utils.dart';
import 'Home.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  late Wallet_Utils _wallet;
  bool _isLoading = false; // Track if wallet generation/loading is in progress

  @override
  void initState() {
    super.initState();
    _wallet = Wallet_Utils();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ethereum Wallet Generation'),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator() // Show a loading indicator while loading
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Authenticate to generate or load wallet securely.',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  _isLoading = true; // Set loading state to true
                });
                await _wallet.generateOrLoadWallet(context);
                setState(() {
                  _isLoading = false; // Set loading state to false
                });
                // Navigate to the home screen after generating the wallet
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(
                      userAddress: _wallet.userAddress, // Pass user address
                      privateKey: _wallet.userCredentials, // Pass private key
                    ),
                  ),
                );
              },
              child: Text('Authenticate and Register'),
            ),
          ],
        ),
      ),
    );
  }
}
