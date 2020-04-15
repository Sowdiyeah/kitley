import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:kitley/pages/add_item_page.dart';
import 'package:kitley/pages/chat_page.dart';
import 'package:kitley/pages/inventory_page.dart';
import 'package:kitley/pages/login_page.dart';
import 'package:kitley/search/search_page.dart';
import 'package:kitley/search/search_delegate.dart';

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
  Future<FirebaseUser> _user = FirebaseAuth.instance.currentUser();
  bool _showUserDetails = false;

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
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            _buildDrawerHeader(),
            Expanded(
              child: _showUserDetails ? _buildUserDetail() : _buildDrawerList(),
            ),
          ],
        ),
      ),
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
      onTap: _setIndex,
      currentIndex: _selectedIndex,
    );
  }

  Widget _buildDrawerHeader() {
    return FutureBuilder(
      future: _user,
      builder: (_, AsyncSnapshot<FirebaseUser> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(child: Text('Loading....'));
          default:
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');
            return UserAccountsDrawerHeader(
              arrowColor: Colors.black,
              accountName: Text(snapshot.data.displayName),
              accountEmail: Text(snapshot.data.email),
              currentAccountPicture: CircleAvatar(
                backgroundImage:
                    CachedNetworkImageProvider(snapshot.data.photoUrl),
              ),
              onDetailsPressed: () {
                setState(() {
                  _showUserDetails = !_showUserDetails;
                });
              },
            );
        }
      },
    );
  }

  ListView _buildUserDetail() {
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        ListTile(
          leading: FaIcon(FontAwesomeIcons.signOutAlt),
          title: Text('Log out'),
          onTap: () async {
            await FirebaseAuth.instance.signOut();
            await GoogleSignIn().signOut();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
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
          onTap: () {
            Navigator.pop(context);
            _setIndex(0);
          },
        ),
        ListTile(
          leading: Icon(Icons.work),
          title: Text('Inventory'),
          onTap: () {
            Navigator.pop(context);
            _setIndex(1);
          },
        ),
        ListTile(
          leading: Icon(Icons.question_answer),
          title: Text('Chat'),
          onTap: () {
            Navigator.pop(context);
            _setIndex(2);
          },
        ),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Settings'),
        ),
      ],
    );
  }

  void _setIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
