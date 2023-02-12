import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:flutter_animator/widgets/fading_entrances/fade_in_down.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:namaz_timing/responsive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';
import 'multi_level_dropdown.dart';
import 'multiselect/repository.dart';
import 'navbar.dart';
import 'services.dart';

class NamazTimingScreen extends StatefulWidget {
  const NamazTimingScreen({Key? key}) : super(key: key);

  @override
  State<NamazTimingScreen> createState() => _NamazTimingScreenState();
}

dynamic namaz_timing = {
  "timing": [
    {
      "name": "fajr",
      "start": "2022-11-05T05:26:28.331000",
      "end": "2022-11-05T06:40:28.331000",
      "city": "surat"
    },
    {
      "name": "sunrise",
      "start": "2022-11-05T06:41:28.331000",
      "end": "2022-11-05T07:01:28.331000",
      "city": "surat"
    },
    {
      "name": "zawal",
      "start": "2022-11-05T12:00:28.331000",
      "end": "2022-11-05T12:22:28.331000",
      "city": "surat"
    },
    {
      "name": "zohr",
      "start": "2022-11-05T12:23:28.331000",
      "end": "2022-11-05T16:27:28.331000",
      "city": "surat"
    },
    {
      "name": "asr",
      "start": "2022-11-05T16:28:28.331000",
      "end": "2022-11-05T18:03:28.331000",
      "city": "surat"
    },
    {
      "name": "sunset",
      "start": "2022-11-05T17:43:28.331000",
      "end": "2022-11-05T18:02:28.331000",
      "city": "surat"
    },
    {
      "name": "magrib",
      "start": "2022-11-05T18:03:28.331000",
      "end": "2022-11-05T19:18:28.331000",
      "city": "surat"
    },
    {
      "name": "isha",
      "start": "2022-11-05T19:19:28.331000",
      "end": "2022-11-05T05:25:28.331000",
      "city": "surat"
    }
  ]
};
bool _showSpiner = true;

class _NamazTimingScreenState extends State<NamazTimingScreen> {
  SharedPreferences? sp;
  String? city;
  String? area;
  Repository repo = Repository();
  List<String> _states = ["Choose City"];
  List<String> _lgas = ["Choose Area"];
  String _selectedState = "Choose City";
  String _selectedLGA = "Choose Area";
  List? cities;
  bool isLoading = true;
  locationDialog(context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SimpleDialog(
              backgroundColor: Color(0xFF1E1E1E),
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.center,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Location',
                    style: TextStyle(
                      color: Color(0xFF77B255),
                    ),
                  ),
                ],
              ),
              children: <Widget>[
                DropdownButton<String>(
                  dropdownColor: Color(0xFF1E1E1E),
                  style: TextStyle(color: Colors.white, fontSize: 14),
                  isExpanded: true,
                  items: _states.map((String dropDownStringItem) {
                    return DropdownMenuItem<String>(
                      value: dropDownStringItem,
                      child: Text(dropDownStringItem),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedLGA = "Choose Area";
                      _lgas = ["Choose Area"];
                      _selectedState = value!;
                      _lgas = List.from(_lgas)
                        ..addAll(repo.getLocalByState(value, cities!));
                    });
                  },
                  value: _selectedState,
                ),
                DropdownButton<String>(
                  isExpanded: true,
                  dropdownColor: Color(0xFF1E1E1E),
                  style: TextStyle(color: Colors.white, fontSize: 14),
                  items: _lgas.map((String dropDownStringItem) {
                    return DropdownMenuItem<String>(
                      value: dropDownStringItem,
                      child: Text(
                        dropDownStringItem,
                        // style: TextStyle(color: Color(0xFF1E1E1E)),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedLGA = value!);
                  },
                  value: _selectedLGA,
                ),
                SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    print(_selectedLGA);
                    print(_selectedState);
                    if (_selectedLGA == 'Choose Area') {
                      return;
                    }
                    if (_selectedState == 'Choose City') {
                      return;
                    }

                    sp!.setString(citySP, _selectedState);
                    sp!.setString(areaSP, _selectedLGA);
                    setState(
                      () {
                        city = _selectedState;
                        area = _selectedLGA;
                      },
                    );
                    Get.back();
                    getData();
                  },
                  child: Text('set location'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF77B255),
                      foregroundColor: Color(0xFF1E1E1E),
                      fixedSize: Size(double.infinity, 40),
                      shape: StadiumBorder()),
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            );
          },
        );
      },
    );
  }

  getData() async {
    var response = await http
        .get(Uri.parse('https://api.namaz.co.in/v2/$city/getNamazTiming'));
    print(response.body);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      setState(() {
        namaz_timing = json.decode(response.body);
        _showSpiner = false;
      });
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load namaz');
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getCityArea();
    });
  }

  getCityArea() {
    Services.getCityArea().then((value) {
      isLoading = false;
      setState(() {});
      cities = [];
      List list = value['data'];
      for (var l in list) {
        String city = getItem(l);
        var map = {"state": city, "alias": city, "lgas": l[city]};
        cities!.add(map);
      }
      _states = List.from(_states)..addAll(repo.getStates(cities!));
      getSP();
    });
  }

  getSP() async {
    sp = await SharedPreferences.getInstance();
    city = sp!.getString(citySP);
    area = sp!.getString(areaSP);
    setState(() {});
    if (city == null && area == null) {
      locationDialog(context);
    } else {
      getData();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFF1E1E1E),
        body:
            // isLoading
            //     ? Center(
            //         child: CircularProgressIndicator(),
            //       )
            //     : city == null || area == null
            //         ? Center(
            //             child: Column(
            //               mainAxisAlignment: MainAxisAlignment.center,
            //               children: [
            //                 Text(
            //                   'Select location',
            //                   style: TextStyle(color: Colors.white, fontSize: 20),
            //                 ),
            //                 SizedBox(
            //                   height: 20,
            //                 ),
            //                 ElevatedButton(
            //                   onPressed: () {
            //                     locationDialog(context);
            //                   },
            //                   child: Text('set location'),
            //                   style: ElevatedButton.styleFrom(
            //                       backgroundColor: Color(0xFF77B255),
            //                       foregroundColor: Color(0xFF1E1E1E),
            //                       fixedSize: Size(double.infinity, 40),
            //                       shape: StadiumBorder()),
            //                 ),
            //               ],
            //             ),
            //           )
            //         :
            ModalProgressHUD(
          inAsyncCall: _showSpiner,
          child: Column(
            children: [
              Container(
                height: responsiveHeight(100, context),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/tab_design.png'),
                    fit: BoxFit.fill,
                  ),
                  color: Color(0xFF77B255),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    top: responsiveHeight(55, context),
                    left: responsiveWidth(15, context),
                    right: responsiveWidth(15, context),
                    bottom: responsiveHeight(18, context),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        color: Colors.white,
                        size: responsiveHeight(25, context),
                      ),
                      FadeInDown(
                        child: Center(
                          child: AutoSizeText(
                            'Namaz Timing',
                            maxLines: 1,
                            style: GoogleFonts.inter(
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: responsiveText(18, context),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.event,
                        color: Colors.white,
                        size: responsiveHeight(25, context),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => getData(),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    children: [
                      Column(
                        children: [
                          SizedBox(
                            height: responsiveHeight(20, context),
                          ),
                          SizedBox(
                            width: responsiveWidth(200, context),
                            child: Center(
                              child: AutoSizeText(
                                'Know The Namaz Timing',
                                maxLines: 1,
                                style: GoogleFonts.inter(
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: responsiveText(16, context),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: responsiveHeight(20, context),
                          ),
                          GridView.count(
                            physics: ScrollPhysics(),
                            padding: EdgeInsets.only(
                              left: responsiveWidth(16.5, context),
                              right: responsiveWidth(16.5, context),
                            ),
                            crossAxisSpacing: responsiveWidth(12, context),
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            children: [
                              for (var namaz in namaz_timing['timing']!)
                                NamazTimingCard(
                                  name: namaz['name'].toString().toUpperCase(),
                                  time: TimeOfDay.fromDateTime(
                                        DateTime.parse(
                                          namaz["start"]!,
                                        ),
                                      ).format(context).toString() +
                                      ' - ' +
                                      TimeOfDay.fromDateTime(
                                        DateTime.parse(
                                          namaz["end"]!,
                                        ),
                                      ).format(context).toString(),
                                ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              NavBar(
                currentPage: 'Timing',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NamazTimingCard extends StatelessWidget {
  const NamazTimingCard({
    Key? key,
    required this.name,
    required this.time,
  }) : super(key: key);

  final String name;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: responsiveHeight(12, context),
      ),
      child: Container(
        width: responsiveWidth(165, context),
        height: responsiveHeight(145, context),
        decoration: BoxDecoration(
          color: black,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            SizedBox(
              height: responsiveHeight(20, context),
            ),
            Image.asset(
              'assets/cloud.png',
              width: responsiveText(42, context),
              height: responsiveText(42, context),
            ),
            SizedBox(
              height: responsiveHeight(29, context),
            ),
            SizedBox(
              width: responsiveWidth(50, context),
              child: Center(
                child: AutoSizeText(
                  name,
                  maxLines: 1,
                  style: GoogleFonts.inter(
                    textStyle: TextStyle(
                      color: Color(0xFFDADADA),
                      fontSize: responsiveText(16, context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: responsiveHeight(3, context),
            ),
            SizedBox(
              width: responsiveWidth(150, context),
              child: Center(
                child: AutoSizeText(
                  time,
                  maxLines: 1,
                  style: GoogleFonts.inter(
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: responsiveText(16, context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
