import 'package:flutter/material.dart';
import 'package:kitley/pages/login_page.dart';

void main() => runApp(MaterialApp(
      title: 'Kitley',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: LoginPage(),
    ));
