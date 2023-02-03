import 'dart:convert';

import 'package:http/http.dart' as http;

class Services {
  static Future getCityArea() async {
    var data;
    final response =
        await http.get(Uri.parse('https://api.namaz.co.in/cityandarea'));

    if (response.statusCode == 200) {
      data = jsonDecode(response.body);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
    return data;
  }
}
