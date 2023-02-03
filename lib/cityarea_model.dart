// To parse this JSON data, do
//
//     final cityAreaM = cityAreaMFromJson(jsonString);

import 'dart:convert';

import 'multi_level_dropdown.dart';

List<CityAreaM> cityAreaMFromJson(List data) =>
    List<CityAreaM>.from(data.map((x) => CityAreaM.fromJson(x)));

class CityAreaM {
  CityAreaM({
    required this.items,
    required this.city,
  });

  List<String> items;
  String city;
  factory CityAreaM.fromJson(Map<String, dynamic> json) => CityAreaM(
        city: getItem(json),
        items: List<String>.from(json[getItem(json)].map((x) => x)),
      );
}
