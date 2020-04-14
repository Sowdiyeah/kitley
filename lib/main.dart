import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:kitley/pages/home_page.dart';
import 'package:kitley/pages/login_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kitley',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: Scaffold(
        body: FutureBuilder(
          future: FirebaseAuth.instance.currentUser(),
          builder: (_, AsyncSnapshot<FirebaseUser> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(child: Text('Loading....'));
              default:
                if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                if (snapshot.hasData) return HomePage();
                return LoginPage();
            }
          },
        ),
      ),
    );
  }
}
