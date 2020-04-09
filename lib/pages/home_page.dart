import 'package:flutter/material.dart';
import 'package:kitley/pages/add_item_page.dart';

import 'package:kitley/pages/chat_page.dart';
import 'package:kitley/pages/inventory_page.dart';
import 'package:kitley/pages/profile_page.dart';
import 'package:kitley/pages/search_page.dart';
import 'package:kitley/template/search_delegate.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
          _selectedIndex == 0
              ? IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: CustomSearchDelegate(),
                    );
                  },
                )
              : _selectedIndex == 1
                  ? IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddItemPage(),
                          ),
                        );
                      },
                    )
                  : Container(),
        ],
      ),
      drawer: _Drawer(),
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.build),
          title: Text('Borrow'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.work),
          title: Text('Inventory'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.question_answer),
          title: Text('Chat'),
        ),
      ],
      onTap: (int index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      currentIndex: _selectedIndex,
    );
  }
}

class _Drawer extends StatefulWidget {
  @override
  _DrawerState createState() => _DrawerState();
}

class _DrawerState extends State<_Drawer> {
  bool _showUserDetails = false;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          _buildDrawerHeader(context),
          Expanded(
            child: _showUserDetails ? _buildUserDetail() : _buildDrawerList(),
          ),
        ],
      ),
    );
  }

  ListView _buildUserDetail() {
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.exit_to_app),
          title: Text('Log in'),
        ),
      ],
    );
  }

  ListView _buildDrawerList() {
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.build),
          title: Text('Borrow'),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(Icons.work),
          title: Text('Inventory'),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(Icons.question_answer),
          title: Text('Chat'),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(Icons.account_circle),
          title: Text('Profile'),
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ProfilePage()));
          },
        ),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Settings'),
        ),
      ],
    );
  }

  UserAccountsDrawerHeader _buildDrawerHeader(BuildContext context) {
    return _anonymousDrawerHeader();
  }

  UserAccountsDrawerHeader _anonymousDrawerHeader() {
    return UserAccountsDrawerHeader(
      arrowColor: Colors.black,
      accountName: Text('Anonymous'),
      accountEmail: Text(''),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.brown.shade800,
        child: Text('A', style: TextStyle(fontSize: 36)),
      ),
      onDetailsPressed: () {
        setState(() {
          _showUserDetails = !_showUserDetails;
        });
      },
    );
  }
}
