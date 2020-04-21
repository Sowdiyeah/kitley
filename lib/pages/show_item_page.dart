import 'package:flutter/material.dart';

import 'package:kitley/utils/item.dart';

class ShowItemPage extends StatelessWidget {
  final Item _item;

  const ShowItemPage({Key key, @required item})
      : _item = item,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_item.name),
      ),
    );
  }
}
