import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:kitley/pages/home_page.dart';
import 'package:kitley/utils/user.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isButtonDisabled = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/intro.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: _isButtonDisabled ? 0 : 4,
          sigmaY: _isButtonDisabled ? 0 : 4,
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Builder(builder: (BuildContext context) {
              return RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                color: Colors.red,
                child: _isButtonDisabled
                    ? Text('Logging in...')
                    : Text('Login with Google'),
                onPressed: _isButtonDisabled ? null : () => _logIn(context),
              );
            }),
          ),
        ),
      ),
    );
  }

  void _logIn(BuildContext context) async {
    setState(() {
      _isButtonDisabled = true;
    });
    GoogleSignInAccount googleUser;
    try {
      googleUser = await _googleSignIn.signIn();
    } catch (e) {
      _errorHandle(context, 'An error occurred signing in to Google.');
      return;
    }

    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    AuthResult result;
    try {
      result = await _auth.signInWithCredential(credential);
    } catch (e) {
      _errorHandle(context, 'An error occurred signing in to the server.');
      return;
    }

    if (result.user == null) {
      _errorHandle(context, 'Something went wrong.');
      return;
    }

    User user = User.fromFireBaseUser(result.user);

    // Save to database if it is a new user
    List<DocumentSnapshot> documents = (await Firestore.instance
            .collection('users')
            .where('id', isEqualTo: user.uid)
            .getDocuments())
        .documents;
    if (documents.isEmpty) {
      Firestore.instance
          .collection('users')
          .document(user.uid)
          .setData(user.toMap());
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomePage()),
    );
  }

  void _errorHandle(BuildContext context, String msg) {
    String checkConnection = 'Check your internet connection and try again.';
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text('$msg\n$checkConnection'),
    ));

    setState(() {
      _isButtonDisabled = false;
    });
  }
}
