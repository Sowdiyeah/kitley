import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('items').limit(50).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));

        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(child: Text('Loading...'));
          default:
            return ListView(
              children: snapshot.data.documents.map((DocumentSnapshot document) {
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(),
                    title: Text(document['name']),
                    subtitle: Text('${document['latitude']}, ${document['longitude']}'),
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
