import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:kitley/pages/chat_page.dart';
import 'package:kitley/utils/item.dart';
import 'package:kitley/utils/user.dart';

class ShowItemPage extends StatefulWidget {
  final Item item;

  const ShowItemPage({Key key, this.item}) : super(key: key);

  @override
  _ShowItemPageState createState() => _ShowItemPageState();
}

class _ShowItemPageState extends State<ShowItemPage> {
  Item _item;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_item.name)),
      body: FutureBuilder(
        future: FirebaseAuth.instance.currentUser(),
        builder: (BuildContext context, AsyncSnapshot<FirebaseUser> snapshot) {
          if (!snapshot.hasData) return Container();

          User myUser = User.fromFireBaseUser(snapshot.data);
          return _buildButtons(context, myUser);
        },
      ),
    );
  }

  Widget _buildButtons(BuildContext context, User myUser) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _buildChatButton(context, myUser),
          _buildBorrowButton(context, myUser),
        ],
      ),
    );
  }

  Widget _buildChatButton(BuildContext context, User myUser) {
    return RaisedButton(
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
    );
  }

  Widget _buildBorrowButton(BuildContext context, User myUser) {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      color: Colors.red,
      child: Text('Borrow!'),
      onPressed: myUser.uid == _item.owner || _item.possessor != null
          ? null
          : () {
              setState(() {
                _item.possessor = myUser.uid;
              });
              _item.update();
            },
    );
  }
}
