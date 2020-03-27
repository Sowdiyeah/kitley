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
  State<StatefulWidget> createState() => MyAppState();
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
            onPressed: () {},
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Text(
                'Info',
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(),
            ListTile(
              leading: Icon(Icons.message),
              title: Text('Messages'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Profile'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
            ),
          ],
        ),
      ),
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Theme.of(context).primaryColor,
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
