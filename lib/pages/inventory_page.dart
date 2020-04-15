import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

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
            return _itemList(snapshot.data.uid);
        }
      },
    );
  }

  Widget _itemList(String uid) {
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

        return StreamBuilder(
          stream: Firestore.instance
              .collection('items')
              .where('possessor', isEqualTo: uid)
              .limit(50)
              .snapshots(),
          builder: (_, AsyncSnapshot possessorSnapshot) {
            if (possessorSnapshot.hasError)
              return Text('Error : ${possessorSnapshot.error}');

            if (possessorSnapshot.connectionState == ConnectionState.waiting)
              return Center(child: CircularProgressIndicator());

            return _itemListView(
                uid, ownerSnapshot.data, possessorSnapshot.data);
          },
        );
      },
    );
  }

  Widget _itemListView(
      String uid, QuerySnapshot owner, QuerySnapshot possesor) {
    List<Widget> ownerList = owner.documents.map(documentToWidget).toList();
    List<Widget> possessorList =
        possesor.documents.map(documentToWidget).toList();

    return ListView.builder(
      itemCount: ownerList.length + possessorList.length + 2,
      itemBuilder: (_, int index) {
        if (index == 0) {
          return Center(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Your items', style: TextStyle(fontSize: 32)),
                ),
                ownerList.isEmpty
                    ? Text('You do not own any items.')
                    : Container()
              ],
            ),
          );
        }

        // index >= 1
        if (index <= ownerList.length) {
          return ownerList[index - 1];
        }

        // index >= ownerList.length + 1
        if (index == ownerList.length + 1) {
          return Center(
            child: Column(
              children: <Widget>[
                Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Loaned items', style: TextStyle(fontSize: 32)),
                ),
                possessorList.isEmpty
                    ? Text('You have no loaned items.')
                    : Container()
              ],
            ),
          );
        }

        // index >= ownerlist.length + 2
        return possessorList[index - ownerList.length - 2];
      },
    );
  }

  Widget documentToWidget(DocumentSnapshot document) {
    return Dismissible(
      key: Key(document.documentID),
      background: Container(color: Colors.red),
      onDismissed: (DismissDirection direction) {
        Firestore.instance
            .collection('items')
            .document(document.documentID)
            .delete();
      },
      child: Card(
        child: ListTile(
          leading: CircleAvatar(),
          title: Text(document['name']),
          subtitle: FutureBuilder(
            initialData: 'Loading...',
            future: _distanceToDocument(document),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');

              return Text(snapshot.data);
            },
          ),
          onTap: () {},
        ),
      ),
    );
  }

  Future<String> _distanceToDocument(DocumentSnapshot document) async {
    bool locationEnabled = await Geolocator().isLocationServiceEnabled();
    if (!locationEnabled) return 'Enable your location service';

    bool permissionGranted = GeolocationStatus.granted ==
        await Geolocator().checkGeolocationPermissionStatus();
    if (!permissionGranted) return 'Check your location permissions';

    Position position = await Geolocator().getCurrentPosition();
    double distance = await Geolocator().distanceBetween(
      position.latitude,
      position.longitude,
      document['item_position'].latitude,
      document['item_position'].longitude,
    );

    // distance is in meters
    if (distance < 1000) return '${distance.toStringAsFixed(0)} meter';
    distance /= 1000;
    // distance is now in kilometers
    if (distance < 20) return '${(distance).toStringAsFixed(1)} km';
    return '${(distance).toStringAsFixed(0)} km';
  }
}
