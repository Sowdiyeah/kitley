import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class User {
  String name;
  String email;
  String photoUrl;
  String uid;

  User.fromFireBaseUser(FirebaseUser firebaseUser) {
    name = firebaseUser.displayName;
    email = firebaseUser.email;
    photoUrl = firebaseUser.photoUrl;
    uid = firebaseUser.uid;
  }

  User.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    name = documentSnapshot['name'];
    email = documentSnapshot['email'];
    photoUrl = documentSnapshot['photoUrl'];
    uid = documentSnapshot['uid'];
  }

  Map<String, String> toMap() {
    return {
      'name': name,
      'photoUrl': photoUrl,
      'uid': uid,
      'email': email,
    };
  }
}
