import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:kitley/search/filters_page.dart';

class CustomSearchDelegate extends SearchDelegate {
  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.filter_list),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FilterPage()),
          );
        },
      ),
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          if (query.isEmpty) close(context, null);
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('items')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .limit(50)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError)
          return Center(child: Text('Error: ${snapshot.error}'));

        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(child: Text('Loading...'));
          default:
            return ListView(
              children:
                  snapshot.data.documents.map((DocumentSnapshot document) {
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(),
                    title: Text(document['name']),
                    subtitle: Text(
                        '${document['latitude']}, ${document['longitude']}'),
                    onTap: () {},
                  ),
                );
              }).toList(),
            );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('items')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .limit(50)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError)
          return Center(child: Text('Error: ${snapshot.error}'));

        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Container();
          default:
            return ListView(
              children:
                  snapshot.data.documents.map((DocumentSnapshot document) {
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(),
                    title: Text(document['name']),
                    subtitle: Text(
                        '${document['latitude']}, ${document['longitude']}'),
                    onTap: () {},
                  ),
                );
              }).toList(),
            );
        }
      },
    );
  }
}