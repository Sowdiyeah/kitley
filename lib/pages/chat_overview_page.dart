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
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(child: Text('Loading....'));
          default:
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');

            User myUser = User.fromFireBaseUser(snapshot.data);
            return _buildChatList(context, myUser);
        }
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

        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.data.documents.isEmpty) {
          return Center(
            child: Text(
              'No active chats yet.',
              style: TextStyle(fontSize: 32),
              textAlign: TextAlign.center,
            ),
          );
        } else {
          List<User> users = snapshot.data.documents
              .map<User>((snapshot) => User.fromDocumentSnapshot(snapshot))
              .toList();

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (BuildContext context, int index) {
              return _buildChatItem(context, myUser, users[index]);
            },
          );
        }
      },
    );
  }

  Widget _buildChatItem(BuildContext context, User myUser, User otherUser) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(),
        title: Text(otherUser.name),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ChatPage(
              myUser: myUser,
              otherUser: otherUser,
            ),
          ));
        },
      ),
    );
  }
}
