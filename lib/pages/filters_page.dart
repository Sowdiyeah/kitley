import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FilterPage extends StatefulWidget {
  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  double _distance = 0.0;
  String _distanceString = '0 km';
  double _sliderValue = 0.0;

  List<String> _categories = [
    'All',
    'Kitchen',
    'Tools',
    'Food',
    'Electronics',
    'Clothing',
    'Consumable maintenance',
    'Other',
  ];
  String _categorySelected = 'All';

  List<String> _availabilities = ['Right now', 'Today', 'All'];
  String _availabilitySelected = 'Right now';

  @override
  void initState() {
    super.initState();
    _loadFilters();
  }

  void _loadFilters() async {
    SharedPreferences prefs = await _prefs;
    setState(() {
      _setDistance(sqrt(log((prefs.getDouble('distance') ?? 0) + 1)) * 60);
      _categorySelected = prefs.getString('category') ?? 'All';
      _availabilitySelected = prefs.getString('availability') ?? 'Right now';
    });
  }

  void _saveFilters(BuildContext context) async {
    SharedPreferences prefs = await _prefs;
    await prefs.setDouble('distance', _distance);
    await prefs.setString('category', _categorySelected);
    await prefs.setString('availability', _availabilitySelected);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filters'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () => _saveFilters(context),
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _distanceSection(),
          _categorySection(),
          _availabilitySection(),
        ],
      ),
    );
  }

  Widget _distanceSection() {
    return Column(
      children: <Widget>[
        Text(
          'Distance',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
        Slider(
          value: sqrt(log(_distance + 1)) * 60,
          onChanged: _setDistance,
          min: 0,
          max: 100,
        ),
        Text(_distanceString),
      ],
    );
  }

  void _setDistance(double value) {
    setState(() {
      _distance = exp(pow((value / 60), 2)) - 1;
      if (_distance > 15.0) {
        _distanceString = '15 km +';
      } else {
        _distanceString = _distance.toStringAsFixed(2) + ' km';
      }
    });
  }

  Widget _categorySection() {
    return Column(
      children: <Widget>[
        Text(
          'Category',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
        DropdownButton<String>(
          items: _categories.map(_itemToWidgetItem).toList(),
          onChanged: (newCategorySelected) {
            setState(() => _categorySelected = newCategorySelected);
          },
          value: _categorySelected,
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
      ],
    );
  }

  Widget _availabilitySection() {
    return Column(
      children: <Widget>[
        Text(
          'Availability',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
        DropdownButton<String>(
          items: _availabilities.map(_itemToWidgetItem).toList(),
          onChanged: (newCategorySelected) {
            setState(() => _availabilitySelected = newCategorySelected);
          },
          value: _availabilitySelected,
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
      ],
    );
  }

  DropdownMenuItem<String> _itemToWidgetItem(String item) {
    return DropdownMenuItem<String>(
      value: item,
      child: Center(child: Text(item)),
    );
  }
}
