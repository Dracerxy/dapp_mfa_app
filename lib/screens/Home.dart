import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomeScreen extends StatefulWidget {
  final String userAddress;
  final String privateKey;
  HomeScreen({required this.userAddress, required this.privateKey});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<MFARequest> mfaRequests = [];
  final localAuth = LocalAuthentication();
  @override
  void initState() {
    super.initState();
    _fetchMFANotifications();
  }

  Future<void> _fetchMFANotifications() async {
    try {
      final response = await http.post(
        Uri.parse('https://dapp-backend.onrender.com/dapp_server/MFANotification'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'userAddress': widget.userAddress,
          'privateKey': widget.privateKey,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          mfaRequests.add(MFARequest(
            user: widget.userAddress,
            dappAddress: data['dappAddress'],
            transactionId: data['transactionId'],
          ));
        });
      } else {
        throw Exception('Failed to fetch MFA notifications');
      }
    } catch (error) {
      // print('Error fetching MFA notifications: $error');
      Fluttertoast.showToast(
        msg: "Error fetching MFA notifications:",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black.withOpacity(0.8),
        textColor: Colors.white,
        fontSize: 16.0,
      );

    }
  }
  Future<void> _verifyMFA(MFARequest request) async {
    if (await _authenticateUser()) {
      try {
        final response = await http.post(
          Uri.parse(
              'https://dapp-backend.onrender.com/dapp_server/MFAVerification'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            'userAddress': widget.userAddress,
            'privateKey': widget.privateKey,
            'transactionId': request.transactionId,
          }),
        );
        if (response.statusCode == 200) {
          // If the server responds with 200, remove the corresponding request from the list
          setState(() {
            mfaRequests.remove(request);
          });
        } else {
          throw Exception('Failed to verify MFA');
        }
      } catch (error) {
        Fluttertoast.showToast(
          msg: "Failed to verify MFA",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black.withOpacity(0.8),
          textColor: Colors.white,
          fontSize: 16.0,
        );

      }
    } else {
      Fluttertoast.showToast(
        msg: "User Authentication Failed! Retry Again!",
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: ListView.builder(
        itemCount: mfaRequests.length,
        itemBuilder: (context, index) {
          final request = mfaRequests[index];
          return GestureDetector(
            onTap: () => _verifyMFA(request),
            child: ListTile(
              title: Text('MFA Request from ${request.user}'),
              subtitle: Text('DApp Address: ${request.dappAddress}\nTransaction ID: ${request.transactionId}'),
            ),
          );
        },
      ),
    );
  }
}



class MFARequest {
  final String user;
  final String dappAddress;
  final String transactionId;

  MFARequest({required this.user, required this.dappAddress, required this.transactionId});
}
