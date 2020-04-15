import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class Item {
  Item() {
    timestamp = Timestamp.now();
  }

  Item.fromDocumentSnapshot(DocumentSnapshot document) {
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

  Future<String> distanceToItem() async {
    bool locationEnabled = await Geolocator().isLocationServiceEnabled();
    if (!locationEnabled) return 'Enable your location service';

    Position position;
    try {
      position = await Geolocator().getLastKnownPosition();
      position = position ?? await Geolocator().getCurrentPosition();
    } catch (e) {
      print('Error: $e');
    }

    if (position == null) return 'Check your location permissions';
    double distance = await Geolocator().distanceBetween(
      position.latitude,
      position.longitude,
      latitude,
      longitude,
    );

    // distance is in meters
    if (distance < 1000) return '${distance.toStringAsFixed(0)} meter';
    distance /= 1000;
    // distance is now in kilometers
    if (distance < 20) return '${(distance).toStringAsFixed(1)} km';
    return '${(distance).toStringAsFixed(0)} km';
  }

  Widget toWidget(void Function() onTap) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(),
        title: Text(name),
        subtitle: FutureBuilder(
          initialData: 'Loading...',
          future: distanceToItem(),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');

            return Text(snapshot.data);
          },
        ),
        onTap: onTap,
      ),
    );
  }
}
