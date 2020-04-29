import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:kitley/pages/chat_page.dart';
import 'package:kitley/utils/user.dart';

class ChatOverviewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');

        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        } else {
          List<User> users = snapshot.data.documents
              .map<User>((snapshot) => User.fromDocumentSnapshot(snapshot))
              .toList();

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (BuildContext context, int index) {
              return _buildChatItem(context, users[index]);
            },
          );
        }
      },
    );
  }

  Widget _buildChatItem(BuildContext context, User user) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(),
        title: Text(user.name),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ChatPage(
              otherUser: user,
            ),
          ));
        },
      ),
    );
  }
}
