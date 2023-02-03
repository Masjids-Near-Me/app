import 'package:flutter/material.dart';
import 'package:namaz_timing/multi_level_dropdown.dart';
import 'package:namaz_timing/services.dart';

import 'repository.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Repository repo = Repository();

  List<String> _states = ["Choose a city"];
  List<String> _lgas = ["Choose .."];
  String _selectedState = "Choose a city";
  String _selectedLGA = "Choose ..";
  List? cities;
  @override
  void initState() {
    Services.getCityArea().then((value) {
      cities = [];
      List list = value['data'];
      for (var l in list) {
        String city = getItem(l);
        var map = {"state": city, "alias": city, "lgas": l[city]};
        cities!.add(map);
      }
      _states = List.from(_states)..addAll(repo.getStates(cities!));
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("STATES MULTI DROPDOWN"),
        elevation: 0.1,
      ),
      body: cities == null
          ? Center()
          : SafeArea(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 30),
                child: Column(
                  children: <Widget>[
                    DropdownButton<String>(
                      isExpanded: true,
                      items: _states.map((String dropDownStringItem) {
                        return DropdownMenuItem<String>(
                          value: dropDownStringItem,
                          child: Text(dropDownStringItem),
                        );
                      }).toList(),
                      onChanged: (value) => _onSelectedState(value!),
                      value: _selectedState,
                    ),
                    DropdownButton<String>(
                      isExpanded: true,
                      items: _lgas.map((String dropDownStringItem) {
                        return DropdownMenuItem<String>(
                          value: dropDownStringItem,
                          child: Text(dropDownStringItem),
                        );
                      }).toList(),
                      // onChanged: (value) => print(value),
                      onChanged: (value) => _onSelectedLGA(value!),
                      value: _selectedLGA,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _onSelectedState(String value) {
    setState(() {
      _selectedLGA = "Choose ..";
      _lgas = ["Choose .."];
      _selectedState = value;
      _lgas = List.from(_lgas)..addAll(repo.getLocalByState(value, cities!));
    });
  }

  void _onSelectedLGA(String value) {
    setState(() => _selectedLGA = value);
  }
}
