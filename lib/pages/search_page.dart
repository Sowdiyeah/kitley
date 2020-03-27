import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  Item(this.name, this.distance);

  String name;
  int distance;
}

class SearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  Firestore db = Firestore.instance;

  @override
  Widget build(BuildContext context) {
    return RaisedButton(onPressed: () {
      db.collection('items').document().setData({'name': 'yolo', 'distance': 1337});
    });
  }
}
// TextEditingController editingController = TextEditingController();

// List<Item> allItems = List<Item>();
// List<Item> listItems = List<Item>();

// @override
// void initState() {
//   allItems.add(Item('Hammer', 100));
//   allItems.add(Item('Screwdriver', 150));
//   allItems.add(Item('Bowling ball', 350));
//   listItems.addAll(allItems);
//   super.initState();
// }

// void filterSearchResults(String query) {
//   if (query.isNotEmpty) {
//     List<Item> resultList = List<Item>();

//     allItems.forEach((item) {
//       print(item.name);
//       if (item.name.contains(query)) {
//         resultList.add(item);
//       }
//     });
//     setState(() {
//       listItems.clear();
//       listItems.addAll(resultList);
//     });
//     return;
//   } else {
//     setState(() {
//       listItems.clear();
//       listItems.addAll(allItems);
//     });
//   }
// }

// @override
// Widget build(BuildContext context) {
//   return Container(
//     child: Column(
//       children: <Widget>[
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: TextField(
//             onChanged: (value) {
//               filterSearchResults(value);
//             },
//             controller: editingController,
//             decoration: InputDecoration(
//                 labelText: "Search",
//                 hintText: "Search",
//                 prefixIcon: Icon(Icons.search),
//                 border:
//                     OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(25.0)))),
//           ),
//         ),
//         Expanded(
//           child: ListView.builder(
//             shrinkWrap: true,
//             itemCount: listItems.length,
//             itemBuilder: (context, index) {
//               return Card(
//                 child: ListTile(
//                   leading: CircleAvatar(),
//                   title: Text('${listItems[index].name}'),
//                   subtitle: Text('${listItems[index].distance}'),
//                   onTap: () {},
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     ),
//   );

// ListView(
//   children: <Widget>[
//     Card(
//       child: ListTile(
//         leading: CircleAvatar(
//           backgroundImage: AssetImage('assets/nico.png'),
//         ),
//         title: Text('Sunglasses'),
//         subtitle: Text('500 m'),
//       ),
//     ),
//     Card(
//       child: ListTile(
//         leading: CircleAvatar(
//           backgroundImage: AssetImage('assets/sean.png'),
//         ),
//         title: Text('Hammer'),
//         subtitle: Text('500 m'),
//       ),
//     ),
//     Card(
//       child: ListTile(
//         leading: CircleAvatar(
//           backgroundImage: AssetImage('assets/menno.png'),
//         ),
//         title: Text('Screwdriver'),
//         subtitle: Text('500 m'),
//       ),
//     ),
//   ],
// );
// }
