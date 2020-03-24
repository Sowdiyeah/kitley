import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage('assets/nico.png'),
            ),
            title: Text('Sunglasses'),
            subtitle: Text('500 m'),
          ),
        ),
        Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage('assets/sean.png'),
            ),
            title: Text('Hammer'),
            subtitle: Text('500 m'),
          ),
        ),
        Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage('assets/menno.png'),
            ),
            title: Text('Screwdriver'),
            subtitle: Text('500 m'),
          ),
        ),
      ],
    );
  }
}
