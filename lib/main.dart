import 'package:flutter/material.dart';
import 'package:kitley/pages/search_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = <Widget>[
    MapSample(),
    Text('Index 1: Business'),
    Text('Index 2: School'),
  ];

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
        body: _widgetOptions[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.search), title: Text('Search')),
            // BottomNavigationBarItem(icon: Icon(Icons.perm_identity), title: Text('Profile')),
            BottomNavigationBarItem(icon: Icon(Icons.gavel), title: Text('Borrow')),
            // BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), title: Text('Inventory')),
            BottomNavigationBarItem(icon: Icon(Icons.question_answer), title: Text('Chat')),
          ],
          onTap: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          currentIndex: _selectedIndex,
        ),
      ),
    );
  }
}
