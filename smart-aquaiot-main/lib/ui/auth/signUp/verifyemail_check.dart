import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_login_screen/ui/auth/login/login_screen.dart'; // Import the login screen

class VerifyEmailCheckScreen extends StatefulWidget {
  @override
  _VerifyEmailCheckScreenState createState() =>
      _VerifyEmailCheckScreenState();
}

class _VerifyEmailCheckScreenState extends State<VerifyEmailCheckScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String verificationStatus = '';

  @override
  void initState() {
    super.initState();
    checkEmailVerificationStatus();
  }

  Future<void> checkEmailVerificationStatus() async {
    var user = _auth.currentUser;
    if (user != null) {
      await user.reload(); // Reload the user to get the latest email verification status.
      user = _auth.currentUser; // Refresh the user data

      final userData = await _firestore.collection('users').doc(user?.uid).get();
      if (userData.exists) {
        final verifyEmailStatus = userData.data()?['verifyemailstatus'];
        if (verifyEmailStatus == 'false' && user!.emailVerified) {
          setState(() {
            verificationStatus = 'Verify, you may log in';
          });

          // Update Firestore field 'verifyemailstatus' to "true"
          await _firestore
              .collection('users')
              .doc(user.uid)
              .update({'verifyemailstatus': 'true'});
        } else {
          setState(() {
            verificationStatus = 'Not verified yet. Please verify your email';
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Email Verification'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Please check your email to verify your account.',
              style: TextStyle(fontSize: 18.0),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                // Check the email verification status
                await checkEmailVerificationStatus();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(verificationStatus),
                  ),
                );
              },
              child: Text('Check Verify Email Status'),
            ),
            SizedBox(height: 20.0),
            Text(
              'If you already verify your email, please proceed to log in',
              style: TextStyle(fontSize: 18.0),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                // Navigate to the login screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LoginScreen(),
                  ),
                );
              },
              child: Text('Go to Log In Page'),
            ),
          ],
        ),
      ),
    );
  }
}
