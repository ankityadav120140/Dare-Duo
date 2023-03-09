// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dareduo/pages/home.dart';
import 'package:dareduo/utilities/global.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class PhoneAuthScreen extends StatefulWidget {
  @override
  _PhoneAuthScreenState createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _auth = FirebaseAuth.instance;

  late String _phoneNumber;
  late String _verificationCode;

  Future<void> _verifyPhoneNumber() async {
    print("Phone Number : $_phoneNumber");
    await _auth.verifyPhoneNumber(
      phoneNumber: _phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Automatically sign in the user on Android devices that support automatic verification
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        // Handle verification failed errors
        print(e);
      },
      codeSent: (String verificationId, int? resendToken) {
        // Save the verification ID and show the SMS verification code UI
        print("verificationId : $verificationId");
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Enter OTP"),
            content: TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _verificationCode = value;
              },
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("CANCEL"),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Create a PhoneAuthCredential with the verification ID and SMS code
                  PhoneAuthCredential credential = PhoneAuthProvider.credential(
                      verificationId: verificationId,
                      smsCode: _verificationCode);

                  // Sign in the user with the credential
                  await _auth.signInWithCredential(credential);

                  // Close the dialog and navigate to the home screen
                  Navigator.of(context).pop();
                  DocumentReference ref = FirebaseFirestore.instance
                      .collection('users')
                      .doc(_phoneNumber);
                  // .doc();
                  FirebaseFirestore.instance
                      .runTransaction((transaction) async {
                    DocumentSnapshot snapshot = await transaction.get(ref);
                    if (!snapshot.exists) {
                      ref.set({
                        'phone': _phoneNumber,
                      }).then((value) {
                        const snackBar = SnackBar(
                          backgroundColor: Colors.green,
                          content: Text('Registered successfully'),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        Get.offAll(Home());
                        // showAlertDialog(context);
                      });
                    } else {
                      ref.update({
                        'phone': _phoneNumber,
                      }).then((value) {
                        const snackBar = SnackBar(
                          backgroundColor: Colors.green,
                          content: Text('Updated successfully'),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        Get.offAll(Home());
                      });
                    }
                  });
                  preferences.setString("phone", _phoneNumber);
                  Get.off(Home());
                },
                child: Text("VERIFY"),
              ),
            ],
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Handle timeout errors
        print("Auto retrieval timed out");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Phone Authentication"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                onChanged: (value) {
                  _phoneNumber = value;
                  _phoneNumber = "+91${_phoneNumber}";
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _verifyPhoneNumber();
              },
              child: Text("SEND OTP"),
            ),
          ],
        ),
      ),
    );
  }
}
