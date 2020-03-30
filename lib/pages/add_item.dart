import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kitley/template/item_template.dart';

class AddItemPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Item')),
      body: CustomForm(),
    );
  }
}

class CustomForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CustomFormState();
}

class CustomFormState extends State<CustomForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Item _item = Item();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        children: <Widget>[
          TextFormField(
            decoration: const InputDecoration(
              icon: Icon(Icons.build),
              hintText: 'Colloquial name for the item type',
              labelText: 'Item name *',
            ),
            validator: (String text) => text.isEmpty ? 'Please enter some text' : null,
            onSaved: (String text) => _item.name = text,
          ),
          TextFormField(
            decoration: InputDecoration(
              icon: Icon(Icons.loyalty),
              hintText: 'Brand name (if any)',
              labelText: 'Brand',
            ),
            onSaved: (String text) => _item.brand = text,
          ),
          TextFormField(
            decoration: const InputDecoration(
              icon: Icon(Icons.person),
              hintText: 'Name for the item owner',
              labelText: 'Owner name *',
            ),
            validator: (String text) => text.isEmpty ? 'Please enter some text' : null,
            onSaved: (String text) => _item.owner = text,
          ),
          TextFormField(
            decoration: const InputDecoration(
              hintText: 'Latitude of the item',
              labelText: 'Latitude *',
            ),
            keyboardType: TextInputType.number,
            validator: (String text) => text.isEmpty ? 'Please enter some number' : null,
            onSaved: (String text) => _item.latitude = double.parse(text),
          ),
          TextFormField(
            decoration: const InputDecoration(
              hintText: 'Longitude of the item',
              labelText: 'Longitude *',
            ),
            keyboardType: TextInputType.number,
            validator: (String text) => text.isEmpty ? 'Please enter some number' : null,
            onSaved: (String text) => _item.longitude = double.parse(text),
          ),
          TextFormField(
            decoration: const InputDecoration(
              hintText: 'Penalty per day in Euros',
              labelText: 'Penalty *',
            ),
            keyboardType: TextInputType.number,
            validator: (String text) => text.isEmpty ? 'Please enter some number' : null,
            onSaved: (String text) => _item.penalty = double.parse(text),
          ),
          TextFormField(
            decoration: const InputDecoration(
              hintText: 'Remarks that affect item usage',
              labelText: 'Remarks',
            ),
            onSaved: (String text) => _item.remarks = text,
          ),
          Container(
            padding: const EdgeInsets.only(left: 40.0, top: 20.0),
            child: new RaisedButton(
              child: const Text('Submit'),
              onPressed: () {
                FormState formState = _formKey.currentState;
                if (formState.validate()) {
                  Scaffold.of(context).showSnackBar(SnackBar(content: Text('Processing Data')));

                  formState.save();
                  Firestore.instance.collection('items').document().setData(_item.toMap());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
