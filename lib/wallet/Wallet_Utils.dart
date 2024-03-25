import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';


class Wallet_Utils {
  late String _userCredentials;
  late String _userAddress;
  bool _walletLoaded = false;

  String get userCredentials => _userCredentials;

  String get userAddress => _userAddress;



  final storage = FlutterSecureStorage();
  final localAuth = LocalAuthentication();

  Future<void> generateOrLoadWallet(BuildContext context) async {
    if (await _authenticateUser()) {
      if (!_walletLoaded) {
        String? storedPrivateKey = await storage.read(key: 'privateKey');
        String? storedAddress = await storage.read(key: 'address');

        if (storedPrivateKey != null && storedAddress != null) {
          _userCredentials = storedPrivateKey;
          _userAddress = storedAddress;
          _walletLoaded = true;
        } else {
          await _registerAndStoreWallet(context);
        }
      }
    }else{
      Fluttertoast.showToast(
        msg: "User Authentication Failed ! Try Again !",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black.withOpacity(0.8),
        textColor: Colors.white,
        fontSize: 16.0,
      );

    }
  }

  Future<void> _registerAndStoreWallet(BuildContext context) async {
    try {
      var response = await http.get(
        Uri.parse('https://dapp-backend.onrender.com/dapp_server/register-user'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        _userAddress = responseData['userAddress'];
        _userCredentials = responseData['privateKey'];

        await _storeWalletInSecureStorage();
      } else {
        throw Exception('Failed to register user');
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed To Register User",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black.withOpacity(0.8),
        textColor: Colors.white,
        fontSize: 16.0,
      );

      throw Exception('Failed to register user');
    }
  }

  Future<void> _storeWalletInSecureStorage() async {
    if (await _authenticateUser()) {
      await storage.write(key: 'privateKey', value: _userCredentials);
      await storage.write(key: 'address', value: _userAddress);
    }else{
      Fluttertoast.showToast(
        msg: "Failed To Authenticate User ! Try Again !",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black.withOpacity(0.8),
        textColor: Colors.white,
        fontSize: 16.0,
      );

    }
  }

  Future<bool> _authenticateUser() async {
    try {
      return await localAuth.authenticate(
        localizedReason: 'Authenticate to store your private key securely.',
      );
    } catch (e) {
      print('Error during authentication: $e');
      return false;
    }
  }
}
