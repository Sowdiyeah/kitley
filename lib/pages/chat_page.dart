import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:kitley/utils/message.dart';
import 'package:kitley/utils/user.dart';

class ChatPage extends StatelessWidget {
  final User myUser;
  final User otherUser;

  const ChatPage({
    Key key,
    @required this.myUser,
    @required this.otherUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(otherUser.name)),
      body: Column(
        children: <Widget>[
          _buildMessageList(context, myUser, otherUser),
          Divider(height: 1.0),
          Composer(myUser: myUser, otherUser: otherUser),
        ],
      ),
    );
  }

  Widget _buildMessageList(BuildContext context, User myUser, User otherUser) {
    String chatId = '${myUser.uid.hashCode + otherUser.uid.hashCode}';

    return Flexible(
      child: StreamBuilder(
        stream: Firestore.instance
            .collection('chats')
            .document(chatId)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .limit(20)
            .snapshots(),
        builder: (_, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) return Text('Error: ${snapshot.error}');
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          List<Message> messages = snapshot.data.documents
              .map<Message>(
                  (snapshot) => Message.fromDocumentSnapshot(snapshot))
              .toList();

          return ListView.builder(
            padding: EdgeInsets.all(8.0),
            reverse: true,
            itemBuilder: (_, int index) => _messageBuilder(
              context,
              index,
              messages[index],
              myUser.uid.hashCode,
            ),
            itemCount: messages.length,
          );
        },
      ),
    );
  }

  Widget _messageBuilder(
      BuildContext context, int index, Message message, int myHash) {
    bool isMyMessage = message.idFrom == myHash;
    return Row(
      mainAxisAlignment:
          isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        Container(
          child: Text(
            message.content,
          ),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
          decoration: BoxDecoration(
            color: isMyMessage ? Colors.blue[200] : Colors.grey[200],
            borderRadius: BorderRadius.circular(8.0),
          ),
          margin: EdgeInsets.only(
            bottom: index == 0 ? 10.0 : 20.0,
            right: 10.0,
            left: 10.0,
          ),
        ),
      ],
    );
  }
}

class Composer extends StatefulWidget {
  final User myUser;
  final User otherUser;

  const Composer({Key key, @required this.myUser, @required this.otherUser})
      : super(key: key);

  @override
  _ComposerState createState() => _ComposerState();
}

class _ComposerState extends State<Composer> {
  TextEditingController _textController = TextEditingController();
  bool _isComposing = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: <Widget>[
          Flexible(
            child: TextField(
              controller: _textController,
              onChanged: (String text) {
                setState(() => _isComposing = text.length > 0);
              },
              onSubmitted: _handleSubmitted,
              decoration: InputDecoration.collapsed(hintText: "Send a message"),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _isComposing
                      ? () => _handleSubmitted(_textController.text)
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleSubmitted(String text) {
    _textController.clear();

    Firestore.instance
        .collection('users')
        .document(widget.otherUser.uid)
        .collection('chats')
        .document(widget.myUser.uid)
        .setData({});

    Message message = Message()
      ..idFrom = widget.myUser.uid.hashCode
      ..idTo = widget.otherUser.uid.hashCode
      ..content = text;

    message.upload();
  }
}
