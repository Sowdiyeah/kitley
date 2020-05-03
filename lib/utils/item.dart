import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class Item {
  String brand;
  String category;
  double latitude;
  double longitude;
  String name;
  String owner;
  double penalty;
  String possessor;
  String remarks;
  Timestamp timestamp;

  Item() {
    timestamp = Timestamp.now();
  }

  Item.fromDocumentSnapshot(DocumentSnapshot document) {
    itemId = document.documentID;
    name = document['name'];
    brand = document['brand'];
    category = document['category'];
    owner = document['owner'];
    latitude = document['item_position'].latitude;
    longitude = document['item_position'].longitude;
    penalty = document['penalty'];
    possessor = document['possessor'];
    remarks = document['remarks'];
    timestamp = document['timestamp'];
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'brand': brand,
      'category': category,
      'owner': owner,
      'item_position': GeoPoint(latitude, longitude),
      'penalty': penalty,
      'possessor': possessor,
      'remarks': remarks,
      'timestamp': timestamp,
    };
  }

  Future<double> distanceTo(Position position) async {
    if (position == null) return null;
    return await Geolocator().distanceBetween(
      position.latitude,
      position.longitude,
      latitude,
      longitude,
    );
  }

  Widget toWidget(Position myPosition, void Function() onTap, Widget trailing) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(),
        title: Text(name),
        subtitle: FutureBuilder(
          initialData: -1.0,
          future: distanceTo(myPosition),
          builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');

            double distance = snapshot.data;
            if (distance == null) return Text('Enable location services');
            if (distance == -1.0) return Container();
            // distance is in meters
            if (distance < 1000)
              return Text('${distance.toStringAsFixed(0)} meter');
            distance /= 1000;
            // distance is now in kilometers
            if (distance < 20) return Text('${distance.toStringAsFixed(1)} km');
            return Text('${distance.toStringAsFixed(0)} km');
          },
        ),
        onTap: onTap,
        trailing: trailing,
      ),
    );
  }

  void update() async {
    await Firestore.instance
        .collection('items')
        .document(itemId)
        .setData(toMap());
  }
}
