import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:kitley/utils/item.dart';
import 'package:kitley/pages/show_item_page.dart';
import 'package:kitley/utils/item_util.dart';

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ItemBuilder(
      stream: Firestore.instance
          .collection('items')
          .where('possessor', isNull: true)
          .limit(50)
          .snapshots(),
      onItemTap: onItemTap,
    );
  }

  void onItemTap(BuildContext context, Item item) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ShowItemPage(item: item),
    ));
  }
}
