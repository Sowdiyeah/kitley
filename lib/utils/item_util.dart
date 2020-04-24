import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

import 'package:kitley/utils/item.dart';
import 'package:kitley/utils/location_util.dart';

class ItemBuilder extends StatelessWidget {
  final Stream<QuerySnapshot> stream;
  final void Function(BuildContext, Item) onItemTap;

  const ItemBuilder({
    Key key,
    @required this.stream,
    @required this.onItemTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
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
        return item.toWidget(myPosition, () => onTap(context, item));
      },
    );
  }
}
