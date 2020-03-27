import 'package:flutter/material.dart';
import 'package:kitley/pages/chat_page.dart';
import 'package:kitley/pages/inventory_page.dart';
import 'package:kitley/pages/profile_page.dart';
import 'package:kitley/pages/search_page.dart';

void main() => runApp(MaterialApp(
      title: 'Kitley',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: MyApp(),
    ));

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = <Widget>[
    SearchPage(),
    InventoryPage(),
    ChatPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kitley'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
            },
          )
        ],
      ),
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.build), title: Text('Borrow')),
          BottomNavigationBarItem(icon: Icon(Icons.work), title: Text('Inventory')),
          BottomNavigationBarItem(icon: Icon(Icons.question_answer), title: Text('Chat')),
        ],
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        currentIndex: _selectedIndex,
      ),
    );
  }
}
