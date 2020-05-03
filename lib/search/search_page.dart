import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

import 'package:kitley/utils/item.dart';
import 'package:kitley/pages/show_item_page.dart';
import 'package:kitley/utils/location_util.dart';

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ItemBuilder(
      stream: Firestore.instance
          .collection('items')
          .where('possessor', isNull: true)
          .limit(50)
          .snapshots(),
    );
  }
}

class ItemBuilder extends StatelessWidget {
  final Stream<QuerySnapshot> stream;

  const ItemBuilder({Key key, @required this.stream}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());

        if (snapshot.data.documents.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'No items listed.',
                  style: TextStyle(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Go to the "Inventory" section to add an item.',
                  textAlign: TextAlign.center,
                )
              ],
            ),
          );
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
            return _itemListView(
              snapshot.data.documents,
              positionSnapshot.data,
              onItemTap,
            );
          },
        );
      },
    );
  }

  ListView _itemListView(List<DocumentSnapshot> documentList,
      Position myPosition, void Function(BuildContext, Item) onTap) {
    return ListView.builder(
      itemCount: documentList.length,
      itemBuilder: (BuildContext context, int index) {
        DocumentSnapshot document = documentList[index];
        Item item = Item.fromDocumentSnapshot(document);
        return item.toWidget(
          myPosition,
          () => onTap(context, item),
          null,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              Random().nextInt(4) + 2,
              (index) => Icon(Icons.star),
            ),
          ),
        );
      },
    );
  }

  void onItemTap(BuildContext context, Item item) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ShowItemPage(item: item),
    ));
  }
}
