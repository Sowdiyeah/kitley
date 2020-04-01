import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  Item() {
    timestamp = Timestamp.now();
  }

  String brand;
  String category;
  double latitude;
  double longitude;
  String name;
  String owner;
  double penalty;
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
      'remarks': remarks,
      'timestamp': timestamp,
    };
  }
}
