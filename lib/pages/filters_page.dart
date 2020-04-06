import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class FilterPage extends StatefulWidget {
  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  double _distance = 0.0;
  double _sliderValue = 0.0;
  String _distanceString = '0 km';

  //TODO: use the enum categories
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
  String _currentCategorySelected = 'All';

  List<String> _availabilities = ['Right now', 'Today', 'All'];
  String _currentAvailabilitySelected = 'Right now';

  @override
  void initState() {
    super.initState();
    //_loadFilters();
  }

  _loadFilters() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _distance = (prefs.get('distance') ?? 0);
      _currentCategorySelected = (prefs.get('category') ?? 'Screwdrivers');
      _currentAvailabilitySelected = (prefs.get('availability') ?? 'Right now');
    });
  }

  _saveFilters(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('distance', _distance);
    await prefs.setString('category', _currentCategorySelected);
    await prefs.setString('availability', _currentAvailabilitySelected);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Filters')),
      body: ListView(
        children: [
          SizedBox(height: 50),
          distanceSection(),
          SizedBox(height: 50),
          categorySection(),
          SizedBox(height: 50),
          availabilitySection(),
          SizedBox(height: 50),
        ],
      ),
      floatingActionButton: saveButton(),
    );
  }

  //TODO: slider exponential
  Widget distanceSection() {
    return Column(
      children: <Widget>[
        Text(
          'Distance',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
        Slider(
          value: _sliderValue,
          onChanged: (newValue) {
            setState(() {
              _sliderValue = newValue;
              _distance = exp(pow((_sliderValue / 60), 2)) - 1;
              if (_distance > 15.0) {
                _distanceString = '15km+';
              } else {
                _distanceString = _distance.toStringAsFixed(2) + 'km';
              }
            });
          },
          min: 0,
          max: 100,
        ),
        Text(_distanceString),
      ],
    );
  }

  Widget categorySection() {
    return Column(
      children: <Widget>[
        Text('Category',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
        DropdownButton<String>(
            items: _categories.map((String dropDownStringItem) {
              return DropdownMenuItem<String>(
                value: dropDownStringItem,
                child: Text(dropDownStringItem),
              );
            }).toList(),
            onChanged: (String newCategorySelected) {
              setState(() {
                this._currentCategorySelected = newCategorySelected;
              });
            },
            value: _currentCategorySelected,
            icon: Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,
            style: TextStyle(color: Colors.black, fontSize: 18),
            underline: Container(
              height: 2,
              color: Colors.orange,
            )),
      ],
    );
  }

  Widget availabilitySection() {
    return Column(
      children: <Widget>[
        Text('Availability',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
        DropdownButton<String>(
            items: _availabilities.map((String dropDownStringItem) {
              return DropdownMenuItem<String>(
                value: dropDownStringItem,
                child: Text(dropDownStringItem),
              );
            }).toList(),
            onChanged: (String newCategorySelected) {
              setState(() {
                this._currentAvailabilitySelected = newCategorySelected;
              });
            },
            value: _currentAvailabilitySelected,
            icon: Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,
            style: TextStyle(color: Colors.black, fontSize: 18),
            underline: Container(
              height: 2,
              color: Colors.orange,
            )),
      ],
    );
  }

  Widget saveButton() {
    return FloatingActionButton(
      child: Icon(Icons.check),
      onPressed: () {
        _saveFilters(context);
      },
    );
  }
}
