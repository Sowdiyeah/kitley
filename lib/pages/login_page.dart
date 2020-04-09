import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:kitley/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('Login Page'),
        ),
      ),
      body: Center(
        child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          color: Colors.red,
          child: Text('Login with Google'),
          onPressed: _logIn,
        ),
      ),
    );
  }

  void _logIn() async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    FirebaseUser user = (await _auth.signInWithCredential(credential)).user;

    if (user == null) return;

    // Set the values we need later in the app
    await Future.wait([
      prefs.setString('uid', user.uid),
      prefs.setString('email', user.email),
      prefs.setString('name', user.displayName),
      prefs.setString('photoUrl', user.photoUrl),
    ]);

    // Save to database if it is a new user
    List<DocumentSnapshot> documents = (await Firestore.instance
            .collection('users')
            .where('id', isEqualTo: user.uid)
            .getDocuments())
        .documents;
    if (documents.isEmpty) {
      Firestore.instance.collection('users').document(user.uid).setData({
        'name': user.displayName,
        'photoUrl': user.photoUrl,
        'uid': user.uid,
        'email': user.email,
      });
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomePage()),
    );
  }
}
