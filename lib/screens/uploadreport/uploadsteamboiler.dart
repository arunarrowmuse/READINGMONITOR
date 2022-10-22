import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';

class UploadSteamBoiler extends StatefulWidget {
  const UploadSteamBoiler({Key? key}) : super(key: key);

  @override
  State<UploadSteamBoiler> createState() => _UploadSteamBoilerState();
}

class _UploadSteamBoilerState extends State<UploadSteamBoiler>
    with AutomaticKeepAliveClientMixin<UploadSteamBoiler> {
  DateTime selectedDate = DateTime.now();
  TextEditingController bfw = TextEditingController();
  TextEditingController coal1 = TextEditingController();
  TextEditingController coal2 = TextEditingController();
  TextEditingController bfwtemp = TextEditingController();
  bool isLoad = false;
  var data;
  var checkdata;
  bool islisted = true;
  late SharedPreferences prefs;
  String? tokenvalue;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2050, 1));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        print(selectedDate);
        print(selectedDate.toString().split(" ")[0]);
        FetchUploadSteamList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    FetchUploadSteamList();
    FetchSteamMachineList();
  }

  void FetchUploadSteamList() async {
    setState(() {
      isLoad = true;
    });
    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    final response = await http.get(
      Uri.parse(
          // '${Constants.weblink}GetSteamBoliersDataQuery/2022-08-22'),
          '${Constants.weblink}GetSteamBoliersDataQuery/${selectedDate.toString().split(" ")[0]}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
    );

    if (response.statusCode == 200) {
      print(response.statusCode);
      print(response.body);
      data = jsonDecode(response.body);
      print(data);

      if (data.length == 0) {
        bfw.text = "";
        coal1.text = "";
        coal2.text = "";
        bfwtemp.text = "";
      } else {
        bfw.text = data[0]['bfw'].toString();
        coal1.text = data[0]['coal_1'].toString();
        coal2.text = data[0]['coal_2'].toString();
        bfwtemp.text = data[0]['bfw_temperature'].toString();
      }
      setState(() {
        isLoad = false;
      });
    } else {
      print(response.statusCode);
      print(response.body);
      setState(() {
        isLoad = false;
      });
      Constants.showtoast("Error Fetching Data.");
    }
  }

  void AddUploadSteamList() async {
    String bfww = "0";
    String coalone = "0";
    String coaltwo = "0";
    String bfwtemperature = "0";
    if (bfw.text != "") {
      bfww = bfw.text;
    }
    if (coal1.text != "") {
      coalone = coal1.text;
    }
    if (coal2.text != "") {
      coaltwo = coal2.text;
    }
    if (bfwtemp.text != "") {
      bfwtemperature = bfwtemp.text;
    }
    final response = await http.post(
      Uri.parse('${Constants.weblink}SteamBoliersDataAdd'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
      body: jsonEncode(<String, String>{
        "date": selectedDate.toString().split(" ")[0],
        "bfw": bfww,
        "coal_1": coalone,
        "coal_2": coaltwo,
        "bfw_temperature": bfwtemperature
      }),
    );
    if (response.statusCode == 200) {
      Constants.showtoast("Machine Added!");
      Utils(context).stopLoading();
      FetchUploadSteamList();
    } else {
      print(response.statusCode);
      print(response.body);
      Utils(context).stopLoading();
      Constants.showtoast("Error Adding Data.");
    }
  }

  void UpdateUploadSteamList() async {
    String bfww = "0";
    String coalone = "0";
    String coaltwo = "0";
    String bfwtemperature = "0";
    if (bfw.text != "") {
      bfww = bfw.text;
    }
    if (coal1.text != "") {
      coalone = coal1.text;
    }
    if (coal2.text != "") {
      coaltwo = coal2.text;
    }
    if (bfwtemp.text != "") {
      bfwtemperature = bfwtemp.text;
    }

    final response = await http.post(
      Uri.parse(
          '${Constants.weblink}GetSteamBoliersDataQueryUpdated/${data[0]['id'].toString()}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
      body: jsonEncode(<String, String>{
        "_method": "PUT",
        "id": data[0]['id'].toString(),
        "date": selectedDate.toString().split(" ")[0],
        "bfw": bfww,
        "coal_1": coalone,
        "coal_2": coaltwo,
        "bfw_temperature": bfwtemperature
      }),
    );
    if (response.statusCode == 200) {
      // data = jsonDecode(response.body);
      Constants.showtoast("Machine Updated!");
      Utils(context).stopLoading();
      FetchUploadSteamList();
    } else {
      print(response.statusCode);
      print(response.body);
      Utils(context).stopLoading();
      Constants.showtoast("Error Updating Data.");
    }
  }

  /// machine list check API
  void FetchSteamMachineList() async {
    setState(() {
      isLoad = true;
    });
    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    print(tokenvalue);
    final response = await http.get(
      Uri.parse('${Constants.weblink}SteamBolierListing'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
    );
    if (response.statusCode == 200) {
      checkdata = jsonDecode(response.body);
      if (checkdata.length == 0) {
        islisted = false;
      }
      setState(() {
        isLoad = false;
      });
    } else {
      setState(() {
        isLoad = false;
      });
      Constants.showtoast("Error Fetching Data.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    DateTime now = DateTime.now();
    var formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
    final GlobalKey<FormState> _key = GlobalKey<FormState>();
    return RefreshIndicator(
      onRefresh: () {
        return Future(() => FetchUploadSteamList());
      },
      child: Scaffold(
        body: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Form(
            key: _key,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  height: 40,
                  // color: Constants.secondaryColor,
                  child: GestureDetector(
                    onTap: () {
                      _selectDate(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // Icon(Icons.calendar_month, color: Colors.white,),
                            Container(
                                padding: const EdgeInsets.all(8.0),
                                height: 40,
                                width: 40,
                                child: Image.asset(
                                  "assets/icons/calendar.png",
                                  color: Constants.primaryColor,
                                )),
                            SizedBox(
                              height: 30,
                              width: 100,
                              child: Center(
                                child: Text(
                                  formattedDate,
                                  style: TextStyle(
                                      color: Constants.secondaryColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: Constants.popins),
                                ),
                              ),
                            ),
                            Container(
                                padding: const EdgeInsets.all(8.0),
                                height: 40,
                                width: 40,
                                child: Image.asset(
                                  "assets/icons/down.png",
                                  color: Constants.primaryColor,
                                )),
                            // Icon(Icons.l, color: Colors.white,),
                          ],
                        ),
                        Container(
                          height: 30,
                          padding: const EdgeInsets.only(right: 15.0),
                          // width: 100,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                if (_key.currentState!.validate()) {
                                  _key.currentState!.save();
                                  if (islisted == false) {
                                    showDialog<String>(
                                      context: context,
                                      builder: (BuildContext context) => AlertDialog(
                                        content: const Text('Please Add Steam Boiler data to Machine List First.'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, 'OK'),
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    Utils(context).startLoading();
                                    if (data.length == 0) {
                                      AddUploadSteamList();
                                    } else {
                                      UpdateUploadSteamList();
                                    }
                                  }
                                } else {
                                  Constants.showtoast(
                                      "please fill all the fields");
                                }
                              });
                            },
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Constants.primaryColor)),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(" Sumbit  ",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: Constants.popins,
                                        fontSize: 14)),
                                Image.asset(
                                  "assets/icons/Edit.png",
                                  height: 16,
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                (isLoad == true)
                    ? SizedBox(
                        height: 500,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Constants.primaryColor,
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "BFW",
                                  style: TextStyle(
                                      fontFamily: Constants.popins,
                                      // color: Constants.textColor,
                                      // fontWeight: FontWeight.w600,
                                      fontSize: 16),
                                ),
                                SizedBox(
                                  height: 35,
                                  width: w * 0.4,
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    // validator: (value) {
                                    //   if (value == null || value.isEmpty) {
                                    //     return 'BFW is required.';
                                    //   }
                                    //   return null;
                                    // },
                                    controller: bfw,
                                    style: TextStyle(
                                      fontFamily: Constants.popins,
                                      // color: Constants.textColor,
                                    ),
                                    decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.only(
                                            bottom: 10.0, left: 10.0),
                                        isDense: true,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Constants.primaryColor,
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        filled: true,
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontFamily: Constants.popins,
                                        ),
                                        // hintText: "first name",
                                        fillColor: Colors.white70),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Coal 1",
                                  style: TextStyle(
                                      fontFamily: Constants.popins,
                                      // color: Constants.textColor,
                                      // fontWeight: FontWeight.w600,
                                      fontSize: 16),
                                ),
                                SizedBox(
                                  height: 35,
                                  width: w * 0.4,
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    // validator: (value) {
                                    //   if (value == null || value.isEmpty) {
                                    //     return 'value is required.';
                                    //   }
                                    //   return null;
                                    // },
                                    controller: coal1,
                                    style: TextStyle(
                                      fontFamily: Constants.popins,
                                      // color: Constants.textColor,
                                    ),
                                    decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.only(
                                            bottom: 10.0, left: 10.0),
                                        isDense: true,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Constants.primaryColor,
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        filled: true,
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontFamily: Constants.popins,
                                        ),
                                        // hintText: "first name",
                                        fillColor: Colors.white70),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Coal 2",
                                  style: TextStyle(
                                      fontFamily: Constants.popins,
                                      // color: Constants.textColor,
                                      // fontWeight: FontWeight.w600,
                                      fontSize: 16),
                                ),
                                SizedBox(
                                  height: 35,
                                  width: w * 0.4,
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    // validator: (value) {
                                    //   if (value == null || value.isEmpty) {
                                    //     return 'value is required.';
                                    //   }
                                    //   return null;
                                    // },
                                    controller: coal2,
                                    style: TextStyle(
                                      fontFamily: Constants.popins,
                                      // color: Constants.textColor,
                                    ),
                                    decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.only(
                                            bottom: 10.0, left: 10.0),
                                        isDense: true,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Constants.primaryColor,
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        filled: true,
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontFamily: Constants.popins,
                                        ),
                                        // hintText: "first name",
                                        fillColor: Colors.white70),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "BFW Temperature ",
                                  style: TextStyle(
                                      fontFamily: Constants.popins,
                                      // color: Constants.textColor,
                                      // fontWeight: FontWeight.w600,
                                      fontSize: 16),
                                ),
                                SizedBox(
                                  height: 35,
                                  width: w * 0.4,
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    // validator: (value) {
                                    //   if (value == null || value.isEmpty) {
                                    //     return 'temp is required.';
                                    //   }
                                    //   return null;
                                    // },
                                    controller: bfwtemp,
                                    style: TextStyle(
                                      fontFamily: Constants.popins,
                                      // color: Constants.textColor,
                                    ),
                                    decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.only(
                                            bottom: 10.0, left: 10.0),
                                        isDense: true,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Constants.primaryColor,
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        filled: true,
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontFamily: Constants.popins,
                                        ),
                                        // hintText: "first name",
                                        fillColor: Colors.white70),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Divider()
                          ],
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
