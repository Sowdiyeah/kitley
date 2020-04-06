import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FilterPage extends StatefulWidget {
  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  var _distance = 0.0;

  //TODO: use the enum categories
  var _categories = ['Screwdrivers', 'Hammers', 'Other'];
  var _currentCategorySelected = 'Screwdrivers';

  var _availabilities = ['Right now','Today', 'All'];
  var _currentAvailabilitySelected = 'Right now';

  @override
  void initState(){
    super.initState();
    _loadFilters();
  }

  _loadFilters() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _distance = (prefs.get('distance')??0);
      _currentCategorySelected = (prefs.get('category')??'Screwdrivers');
      _currentAvailabilitySelected = (prefs.get('availability')??'Right now');
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

    //TODO: slider exponential
    Widget distanceSection = Column(
      children: <Widget>[
        Text('Distance',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),),
        Slider(
          value: _distance,
          onChanged: (newDistance){
            setState(() {
              _distance = newDistance;
            });
          },
          min: 0,
          max: 10,
          label: "_distance",
        ),
        Text(_distance.toStringAsFixed(2) + 'km'),
      ],
    );

    //TODO: include 'ALL' in category
    Widget categorySection = Column(
      children: <Widget>[
        Text('Category',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
        DropdownButton<String>(
          items: _categories.map((String dropDownStringItem){
            return DropdownMenuItem<String>(
              value: dropDownStringItem,
              child: Text(dropDownStringItem),
            );
          }).toList(),
          onChanged: (String newCategorySelected){
            setState((){
              this._currentCategorySelected = newCategorySelected;
            });
          },
          value: _currentCategorySelected,
          icon: Icon(Icons.arrow_downward),
          iconSize: 24,
          elevation: 16,
          style: TextStyle(
            color: Colors.black, fontSize: 18
          ),
          underline: Container(
            height: 2,
            color: Colors.orange,
          )
        ),
      ],
    );

    Widget availabilitySection = Column(
      children: <Widget>[
        Text('Availability',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
        DropdownButton<String>(
            items: _availabilities.map((String dropDownStringItem){
              return DropdownMenuItem<String>(
                value: dropDownStringItem,
                child: Text(dropDownStringItem),
              );
            }).toList(),
            onChanged: (String newCategorySelected){
              setState((){
                this._currentAvailabilitySelected = newCategorySelected;
              });
            },
            value: _currentAvailabilitySelected,
            icon: Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,
            style: TextStyle(
                color: Colors.black, fontSize: 18
            ),
            underline: Container(
              height: 2,
              color: Colors.orange,
            )
        ),
      ],
    );

    Widget saveButton = FloatingActionButton(
      child: Icon(Icons.check),
      onPressed: _saveFilters(context),
    );

    return Scaffold(
      appBar: AppBar(title: Text('Filters')),
      body: ListView(
        children: [
          SizedBox(height:50),
          distanceSection,
          SizedBox(height:50),
          categorySection,
          SizedBox(height:50),
          availabilitySection,
          SizedBox(height:50),
          saveButton,
        ],
      ),
    );
  }
}
