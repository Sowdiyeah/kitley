import 'package:flutter/material.dart';
import 'package:kitley/pages/add_item.dart';

class InventoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: RaisedButton(
        child: Text('Add item'),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddItemPage()));
        },
      ),
    );
  }
}
