import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('items').limit(50).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView(children: snapshot.data.documents.map(documentToWidget).toList());
      },
    );
  }

  Widget documentToWidget(DocumentSnapshot document) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(),
        title: Text(document['name']),
        subtitle: FutureBuilder(
          future: Geolocator().distanceBetween(
            0,
            0,
            document['item_position'].latitude,
            document['item_position'].longitude,
          ),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');

            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Text('Loading...');
              default:
                return snapshot.data > 1000
                    ? Text('${(snapshot.data / 1000).toStringAsFixed(0)} km')
                    : Text('${snapshot.data.toStringAsFixed(0)} meter');
            }
          },
        ),
        onTap: () {},
      ),
    );
  }
}
