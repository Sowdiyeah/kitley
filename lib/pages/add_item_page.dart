import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:kitley/template/item.dart';

class AddItemPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  Future<FirebaseUser> _user = FirebaseAuth.instance.currentUser();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Item _item = Item();

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: customAppBar(), body: customForm());
  }

  Widget customAppBar() {
    return AppBar(
      title: Text('Add Item'),
      actions: <Widget>[
        Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.save),
              onPressed: () async {
                FormState formState = _formKey.currentState;
                if (formState.validate()) {
                  Scaffold.of(context).showSnackBar(
                    SnackBar(content: Text('Data Saved')),
                  );

                  formState.save();
                  _item.owner = (await _user).uid;
                  Firestore.instance
                      .collection('items')
                      .document()
                      .setData(_item.toMap());
                }
              },
            );
          },
        ),
      ],
    );
  }

  Widget customForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        children: <Widget>[
          nameField(),
          brandField(),
          LocationField(
            updateLocation: updateItem,
          ),
          penaltyField(),
          remarksField(),
        ],
      ),
    );
  }

  Widget nameField() {
    return TextFormField(
      decoration: const InputDecoration(
        icon: Icon(Icons.build),
        hintText: 'Colloquial name for the item type',
        labelText: 'Item name *',
      ),
      validator: (String text) => text.isEmpty ? 'Enter some text' : null,
      onSaved: (String text) => _item.name = text,
    );
  }

  Widget brandField() {
    return TextFormField(
      decoration: InputDecoration(
        icon: Icon(Icons.loyalty),
        hintText: 'Brand name (if any)',
        labelText: 'Brand',
      ),
      onSaved: (String text) => _item.brand = text,
    );
  }

  void updateItem(double latitude, double longitude) {
    _item.latitude = latitude;
    _item.longitude = longitude;
  }

  Widget penaltyField() {
    return TextFormField(
      decoration: const InputDecoration(
        hintText: 'Penalty per day in Euros',
        labelText: 'Penalty *',
        icon: Icon(Icons.attach_money),
      ),
      keyboardType: TextInputType.number,
      validator: (String text) {
        return (double.tryParse(text)?.isNegative ?? true)
            ? 'Enter a valid number'
            : null;
      },
      onSaved: (String text) => _item.penalty = double.parse(text),
    );
  }

  Widget remarksField() {
    return TextFormField(
      decoration: const InputDecoration(
        hintText: 'Remarks that affect item usage',
        labelText: 'Remarks',
        icon: Icon(Icons.list),
      ),
      onSaved: (String text) => _item.remarks = text,
    );
  }
}

class LocationField extends StatefulWidget {
  final Function(double latitude, double longitude) updateLocation;

  LocationField({
    Key key,
    @required this.updateLocation,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LocationFieldState();
}

class _LocationFieldState extends State<LocationField> {
  TextEditingController _controller = TextEditingController();
  double _latitude;
  double _longitude;
  String _address = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextFormField(
          decoration: InputDecoration(
            icon: Icon(_hasPosition() ? Icons.gps_fixed : Icons.gps_not_fixed),
            hintText: 'Enter the address of the item',
            labelText: 'Item address',
            suffixIcon: _controller.text.isEmpty
                ? _autofillLocation()
                : _clearLocation(),
          ),
          controller: _controller,
          onChanged: _onChangedCallback,
          validator: (String text) {
            return _hasPosition()
                ? null
                : 'Enter a valid address starting with the street';
          },
          onSaved: (String text) =>
              widget.updateLocation(_latitude, _longitude),
        ),
        _address.isNotEmpty
            ? Container(
                padding: EdgeInsets.only(left: 40),
                child: Text(_address),
              )
            : Container(),
      ],
    );
  }

  void _onChangedCallback(String text) async {
    if (text.length < 5) return;

    List<Placemark> places;
    try {
      places = await Geolocator().placemarkFromAddress(text);
    } catch (e) {
      print(e);
    }

    if (places != null && places.isNotEmpty) {
      Placemark place = places.first;

      String street = place.thoroughfare;
      String number = place.subThoroughfare;
      String postal = place.postalCode;
      String city =
          place.locality.isNotEmpty ? place.locality : place.subLocality;
      String country = place.isoCountryCode;
      setState(() {
        _address = '$street $number, $postal $city, $country';
        _latitude = places.first.position.latitude;
        _longitude = places.first.position.longitude;
      });
    } else {
      setState(() {
        _latitude = null;
        _longitude = null;
      });
    }
  }

  bool _hasPosition() => _latitude != null && _longitude != null;

  IconButton _clearLocation() {
    return IconButton(
      icon: Icon(Icons.clear),
      onPressed: () {
        _controller.clear();
        setState(() {
          _latitude = null;
          _longitude = null;
          _address = '';
        });
      },
    );
  }

  IconButton _autofillLocation() {
    return IconButton(
      icon: Icon(Icons.edit_location),
      onPressed: () async {
        bool locationEnabled = await Geolocator().isLocationServiceEnabled();
        if (!locationEnabled) return;

        Position position = await Geolocator().getCurrentPosition();
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _address = '';
        });

        List<Placemark> places = await Geolocator().placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (places != null && places.isNotEmpty) {
          String street = places.first.thoroughfare;
          String streetNumber = places.first.subThoroughfare;
          String locality = places.first.locality;
          _controller.text = street + ' ' + streetNumber + ', ' + locality;
        }
      },
    );
  }
}
