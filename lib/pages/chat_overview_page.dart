import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:kitley/pages/chat_page.dart';

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
          return ListView.builder(
            itemCount: snapshot.data.documents.length,
            itemBuilder: (BuildContext context, int index) {
              return _buildChatItem(context, snapshot.data.documents[index]);
            },
          );
        }
      },
    );
  }

  Widget _buildChatItem(BuildContext context, DocumentSnapshot document) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(),
        title: Text('${document.data['name']}'),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ChatPage(
              contactName: '${document.data['name']}',
            ),
          ));
        },
      ),
    );
  }
}
