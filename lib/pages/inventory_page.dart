import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:kitley/utils/item.dart';
import 'package:kitley/utils/location_util.dart';

class InventoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseAuth.instance.currentUser(),
      builder: (_, AsyncSnapshot<FirebaseUser> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(child: Text('Loading....'));
          default:
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        }

        return FutureBuilder(
          future: getLocation(),
          builder: (_, AsyncSnapshot<Position> positionSnapshot) {
            switch (positionSnapshot.connectionState) {
              case ConnectionState.waiting:
                return _itemList(snapshot.data.uid, null);
              default:
                if (snapshot.hasError)
                  return _itemList(snapshot.data.uid, null);
            }
            return _itemList(snapshot.data.uid, positionSnapshot.data);
          },
        );
      },
    );
  }

  Widget _itemList(String uid, Position myPosition) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('items')
          .where('owner', isEqualTo: uid)
          .limit(50)
          .snapshots(),
      builder: (_, AsyncSnapshot<QuerySnapshot> ownerSnapshot) {
        if (ownerSnapshot.hasError)
          return Text('Error: ${ownerSnapshot.error}');

        if (ownerSnapshot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator());

        List<Widget> ownedItems = ownerSnapshot.data.documents
            .map((document) => Item.fromDocumentSnapshot(document))
            .map((item) => item.toWidget(
                  myPosition,
                  () {},
                  (_) {
                    Firestore.instance
                        .collection('items')
                        .document(item.itemId)
                        .delete();
                  },
                  Text(item.possessor != null
                      ? 'loaned to: ${item.possessor}'
                      : 'not loaned out'),
                ))
            .toList();

        return StreamBuilder(
          stream: Firestore.instance
              .collection('items')
              .where('possessor', isEqualTo: uid)
              .limit(50)
              .snapshots(),
          builder: (_, AsyncSnapshot<QuerySnapshot> possessorSnapshot) {
            if (possessorSnapshot.hasError)
              return Text('Error : ${possessorSnapshot.error}');

            if (possessorSnapshot.connectionState == ConnectionState.waiting)
              return Center(child: CircularProgressIndicator());

            List<Widget> possessedItems = possessorSnapshot.data.documents
                .map((document) => Item.fromDocumentSnapshot(document))
                .map((item) => item.toWidget(
                      myPosition,
                      () {},
                      (_) {
                        Item newItem = item..possessor = null;
                        newItem.update();
                      },
                      Text('from: ${item.owner.substring(0, 15)}'),
                    ))
                .toList();

            return _itemListView(ownedItems, possessedItems);
          },
        );
      },
    );
  }

  Widget _itemListView(List<Widget> ownedItems, List<Widget> possessedItems) {
    return ListView.builder(
      itemCount: ownedItems.length + possessedItems.length + 2,
      itemBuilder: (_, int index) {
        if (index == 0) {
          return Center(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Your items', style: TextStyle(fontSize: 32)),
                ),
                ownedItems.isEmpty
                    ? Text('You do not own any items.')
                    : Container()
              ],
            ),
          );
        }

        // index >= 1
        if (index <= ownedItems.length) {
          return ownedItems[index - 1];
        }

        // index >= ownedItems.length + 1
        if (index == ownedItems.length + 1) {
          return Center(
            child: Column(
              children: <Widget>[
                Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Loaned items', style: TextStyle(fontSize: 32)),
                ),
                possessedItems.isEmpty
                    ? Text('You have no loaned items.')
                    : Container()
              ],
            ),
          );
        }

        // index >= ownedItems.length + 2
        return possessedItems[index - ownedItems.length - 2];
      },
    );
  }
}
