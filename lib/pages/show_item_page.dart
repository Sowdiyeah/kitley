import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:kitley/pages/chat_page.dart';
import 'package:kitley/utils/item.dart';
import 'package:kitley/utils/user.dart';

class ShowItemPage extends StatelessWidget {
  final Item _item;

  const ShowItemPage({Key key, @required item})
      : _item = item,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_item.name)),
      body: FutureBuilder(
        future: FirebaseAuth.instance.currentUser(),
        builder: (BuildContext context, AsyncSnapshot<FirebaseUser> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: Text('Loading....'));
            default:
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');

              User myUser = User.fromFireBaseUser(snapshot.data);
              return _buildButton(context, myUser);
          }
        },
      ),
    );
  }

  Widget _buildButton(BuildContext context, User myUser) {
    return Center(
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.red,
        child: Text('Chat!'),
        onPressed: myUser.uid == _item.owner
            ? null
            : () async {
                if (myUser.uid != _item.owner) {
                  Firestore.instance
                      .collection('users')
                      .document(myUser.uid)
                      .collection('chats')
                      .document(_item.owner)
                      .setData({});
                }

                DocumentSnapshot documentSnapshot = await Firestore.instance
                    .collection('users')
                    .document(_item.owner)
                    .get();
                User otherUser = User.fromDocumentSnapshot(documentSnapshot);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChatPage(
                      myUser: myUser,
                      otherUser: otherUser,
                    ),
                  ),
                );
              },
      ),
    );
  }
}
