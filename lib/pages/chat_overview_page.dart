import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:kitley/pages/chat_page.dart';
import 'package:kitley/utils/user.dart';

class ChatOverviewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseAuth.instance.currentUser(),
      builder: (_, AsyncSnapshot<FirebaseUser> snapshot) {
        if (!snapshot.hasData) return Container();

        User myUser = User.fromFireBaseUser(snapshot.data);
        return _buildChatList(context, myUser);
      },
    );
  }

  Widget _buildChatList(BuildContext context, User myUser) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('users')
          .document(myUser.uid)
          .collection('chats')
          .snapshots(),
      builder: (_, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());

        if (snapshot.data.documents.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'No active chats.',
                  style: TextStyle(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Click on an item in the "Borrow"' +
                      ' section to start chatting!',
                  textAlign: TextAlign.center,
                )
              ],
            ),
          );
        } else {
          List<String> userIds = snapshot.data.documents
              .map((snapshot) => snapshot.documentID)
              .toList();

          return ListView.builder(
            itemCount: userIds.length,
            itemBuilder: (_, int index) {
              return _buildChatItem(myUser, userIds[index]);
            },
          );
        }
      },
    );
  }

  Widget _buildChatItem(User myUser, String userId) {
    return FutureBuilder(
      future: Firestore.instance.collection('users').document(userId).get(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (!snapshot.hasData) return Container();

        User otherUser = User.fromDocumentSnapshot(snapshot.data);
        return Dismissible(
          key: Key(userId),
          background: Container(color: Colors.red),
          child: Card(
            child: ListTile(
              leading: CircleAvatar(),
              title: Text(otherUser.name),
              onTap: () {
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
          ),
          onDismissed: (DismissDirection direction) {
            Firestore.instance
                .collection('users')
                .document(myUser.uid)
                .collection('chats')
                .document(userId)
                .delete();
          },
        );
      },
    );
  }
}
