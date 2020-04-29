import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  int idFrom;
  int idTo;
  int timestamp; // milisecondsSinceEpoch
  String content;

  Message() {
    timestamp = DateTime.now().millisecondsSinceEpoch;
  }

  Message.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    idFrom = documentSnapshot['idFrom'];
    idTo = documentSnapshot['idTo'];
    timestamp = documentSnapshot['timestamp'];
    content = documentSnapshot['content'];
  }

  Map<String, dynamic> toMap() {
    return {
      'idFrom': idFrom,
      'idTo': idTo,
      'timestamp': timestamp,
      'content': content,
    };
  }

  upload() {
    Firestore.instance
        .collection('chats')
        .document('${idFrom + idTo}')
        .collection('messages')
        .document()
        .setData(toMap());
  }
}
