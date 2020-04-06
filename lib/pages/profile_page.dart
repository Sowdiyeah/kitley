import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // TODO: Do not use global keys. BAD.
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text('My Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text('Log-in'),
              onPressed: () {
                _handleSignIn();
              },
            ),
            RaisedButton(
              child: Text('Log-Out'),
              onPressed: () {
                _handleSignOut();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleSignIn() async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    FirebaseUser user = (await _auth.signInWithCredential(credential)).user;

    _scaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text('Welcome, ${user.displayName}.')),
    );

    if (user == null) return;
    List<DocumentSnapshot> documents = (await Firestore.instance
            .collection('users')
            .where('id', isEqualTo: user.uid)
            .getDocuments())
        .documents;

    if (documents.isEmpty) {
      // Update data to server if new user
      Firestore.instance.collection('users').document(user.uid).setData({
        'nickname': user.displayName,
        'photoUrl': user.photoUrl,
        'id': user.uid
      });
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', user.displayName);
  }

  void _handleSignOut() {
    _googleSignIn.signOut();
  }
}
