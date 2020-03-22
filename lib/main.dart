import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kitley',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Center(child: Text('Kitley')),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.search), title: Text('Search')),
            // BottomNavigationBarItem(icon: Icon(Icons.perm_identity), title: Text('Profile')),
            BottomNavigationBarItem(icon: Icon(Icons.gavel), title: Text('Borrow')),
            // BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), title: Text('Inventory')),
            BottomNavigationBarItem(icon: Icon(Icons.question_answer), title: Text('Chat')),
          ],
        ),
      ),
    );
  }
}
