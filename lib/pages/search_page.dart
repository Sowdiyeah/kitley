import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('items').limit(50).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView(
          children: snapshot.data.documents.map(documentToWidget).toList(),
        );
      },
    );
  }

  Widget documentToWidget(DocumentSnapshot document) {
    return Dismissible(
      key: Key(document.documentID),
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
