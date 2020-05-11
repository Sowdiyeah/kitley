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
        if (!snapshot.hasData) return Container();

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
    return StreamBuilder(
      stream: Firestore.instance
          .collection('items')
          .where('owner', isEqualTo: uid)
          .limit(50)
          .snapshots(),
      builder: (_, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());

        List<Widget> ownedItems = snapshot.data.documents
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
                      ? 'loaned to: ${item.possessor.substring(0, 15)}'
                      : 'not loaned out'),
                ))
            .toList();

        return StreamBuilder(
          stream: Firestore.instance
              .collection('items')
              .where('possessor', isEqualTo: uid)
              .limit(50)
              .snapshots(),
          builder: (_, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) return Text('Error : ${snapshot.error}');
            if (!snapshot.hasData)
              return Center(child: CircularProgressIndicator());

            List<Widget> possessedItems = snapshot.data.documents
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
    if (ownedItems.isEmpty && possessedItems.isEmpty) return _infoView();

    return ListView.builder(
      itemCount: ownedItems.length + possessedItems.length + 2,
      itemBuilder: (_, int index) {
        if (index == 0) {
          return Center(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Your items', style: TextStyle(fontSize: 24)),
                ),
                ownedItems.isEmpty
                    ? Text(
                        'You have not added any items in Kitley yet.\n' +
                            'Press the "+" icon in the top right corner to' +
                            ' add an item.',
                        textAlign: TextAlign.center,
                      )
                    : Container()
              ],
            ),
          );
        }

        // index >= 1
        if (index <= ownedItems.length) return ownedItems[index - 1];

        // index >= ownedItems.length + 1
        if (index == ownedItems.length + 1) {
          return Center(
            child: Column(
              children: <Widget>[
                Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Borrowed items', style: TextStyle(fontSize: 24)),
                ),
                possessedItems.isEmpty
                    ? Text(
                        'You have no loaned items.\n' +
                            'Go to the "Borrow" section to start ' +
                            'borrowing items.',
                        textAlign: TextAlign.center,
                      )
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

  Widget _infoView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'No items in inventory.',
            style: TextStyle(fontSize: 24),
            textAlign: TextAlign.center,
          ),
          Text(
            'Borrow an item in the "Borrow" section\n' +
                'or press the "+" icon in the top right corner to add an item.',
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
