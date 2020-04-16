import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

import 'package:kitley/item.dart';
import 'package:kitley/pages/show_item_page.dart';
import 'package:kitley/utils/location_util.dart';

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('items')
          .where('possessor', isNull: true)
          .limit(50)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        return FutureBuilder(
          future: getLocation(),
          builder: (_, AsyncSnapshot<Position> positionSnapshot) {
            switch (positionSnapshot.connectionState) {
              case ConnectionState.waiting:
                return Container();
              default:
                if (positionSnapshot.hasError) return Container();
            }
            return ListView(
              children: snapshot.data.documents
                  .map((document) => Item.fromDocumentSnapshot(document))
                  .map((item) => item.toWidget(positionSnapshot.data, () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => ShowItemPage(item: item),
                        ));
                      }))
                  .toList(),
            );
          },
        );
      },
    );
  }
}
