import 'package:flutter/material.dart';
import 'package:namaz_timing/cityarea_model.dart';

Widget multiLevelDropdownWidget(
    List<CityAreaM> cities, CityAreaM city, Function(CityAreaM) citySelect) {
  return StatefulBuilder(builder: (context, setState) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 30),
      child: Column(
        children: <Widget>[
          DropdownButton<CityAreaM>(
            value: city,
            items: cities.map<DropdownMenuItem<CityAreaM>>((CityAreaM? value) {
              return DropdownMenuItem<CityAreaM>(
                value: value,
                child: Text(
                  value!.city,
                  style: TextStyle(fontSize: 30),
                ),
              );
            }).toList(),
            // Step 5.
            onChanged: (CityAreaM? value) {
              citySelect(value!);
            },
          ),
        ],
      ),
    );
  });
}

String getItem(Map<String, dynamic> v) {
  String a = v.keys.toString();
  return a.substring(1, a.length - 1);
}
