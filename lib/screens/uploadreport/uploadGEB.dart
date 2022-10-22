import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';

class UploadGEB extends StatefulWidget {
  const UploadGEB({Key? key}) : super(key: key);

  @override
  State<UploadGEB> createState() => _UploadGEBState();
}

class _UploadGEBState extends State<UploadGEB>
    with AutomaticKeepAliveClientMixin<UploadGEB> {
  DateTime selectedDate = DateTime.now();
  bool isLoad = false;
  var data;
  var checkdata;
  bool islisting = true;
  TextEditingController kwh = TextEditingController();
  TextEditingController kvarh = TextEditingController();
  TextEditingController kvah = TextEditingController();
  TextEditingController md = TextEditingController();
  TextEditingController turbine = TextEditingController();
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
        print(selectedDate.toString().split(" ")[0]);
        FetchUploadGEBList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    FetchUploadGEBList();
    FetchGEBMachineList();
  }

  void FetchUploadGEBList() async {
    setState(() {
      isLoad = true;
    });
    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    final response = await http.get(
      Uri.parse(
          '${Constants.weblink}UploadReportGebSharch/${selectedDate.toString().split(" ")[0]}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
    );

    if (response.statusCode == 200) {
      data = jsonDecode(response.body);
      print(data);
      if (data.length == 0) {
        kwh.text = "";
        kvarh.text = "";
        kvah.text = "";
        md.text = "";
        turbine.text = "";
      } else {
        kwh.text = data[0]['kwh'].toString();
        kvarh.text = data[0]['kvarh'].toString();
        kvah.text = data[0]['kevah'].toString();
        md.text = data[0]['md'].toString();
        turbine.text = data[0]['turbine'].toString();
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

  void AddGEBList() async {
    String kwhh = "0";
    String kvarhh = "0";
    String kvahh = "0";
    String mdd = "0";
    String turbinee = "0";
    if (kwh.text != "") {
      kwhh = kwh.text;
    }
    if (kvarh.text != "") {
      kvarhh = kvarh.text;
    }
    if (kvah.text != "") {
      kvahh = kvah.text;
    }
    if (md.text != "") {
      mdd = md.text;
    }
    if (turbine.text != "") {
      turbinee = turbine.text;
    }
    final response = await http.post(
      Uri.parse('${Constants.weblink}UploadReportGebAdd'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
      body: jsonEncode(<String, String>{
        // "id": data[0]['id'].toString(),
        "date": selectedDate.toString().split(" ")[0],
        "kwh": kwhh,
        "kvarh": kvarhh,
        "kevah": kvahh,
        "md": mdd,
        "turbine": turbinee,
        // "geb_id":"1"
      }),
    );
    if (response.statusCode == 200) {
      // data = jsonDecode(response.body);
      Constants.showtoast("Machine Added!");
      Utils(context).stopLoading();
      FetchUploadGEBList();
    } else {
      print(response.statusCode);
      print(response.body);
      Utils(context).stopLoading();
      Constants.showtoast("Error Updating Data.");
    }
  }

  void UpdateGEBList(String id) async {
    String kwhh = "0";
    String kvarhh = "0";
    String kvahh = "0";
    String mdd = "0";
    String turbinee = "0";
    if (kwh.text != "") {
      kwhh = kwh.text;
    }
    if (kvarh.text != "") {
      kvarhh = kvarh.text;
    }
    if (kvah.text != "") {
      kvahh = kvah.text;
    }
    if (md.text != "") {
      mdd = md.text;
    }
    if (turbine.text != "") {
      turbinee = turbine.text;
    }
    final response = await http.post(
      Uri.parse(
          '${Constants.weblink}UploadReportGebUpdate/${data[0]['id'].toString()}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
      body: jsonEncode(<String, String>{
        "_method": "PUT",
        "kwh": kwhh,
        "kvarh": kvarhh,
        "kevah": kvahh,
        "md": mdd,
        "turbine": turbinee
      }),
    );
    if (response.statusCode == 200) {
      Constants.showtoast("Machine Updated!");
      Utils(context).stopLoading();
      FetchUploadGEBList();
    } else {
      print(response.statusCode);
      print(response.body);
      Utils(context).stopLoading();
      Constants.showtoast("Error Updating Data.");
    }
  }

  /// machinelist API
  void FetchGEBMachineList() async {
    setState(() {
      isLoad = true;
    });
    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    print(tokenvalue);
    final response = await http.get(
      Uri.parse('${Constants.weblink}GetGebListing'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
    );
    if (response.statusCode == 200) {
      checkdata = jsonDecode(response.body);
      if (checkdata.length == 0) {
        islisting = false;
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

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    DateTime now = DateTime.now();
    var formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
    final GlobalKey<FormState> _key = GlobalKey<FormState>();
    return RefreshIndicator(
      onRefresh: () {
        return Future(() => FetchUploadGEBList());
      },
      child: RefreshIndicator(
        onRefresh: () {
          return Future(() => FetchUploadGEBList());
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
                            ],
                          ),
                          Container(
                            height: 30,
                            padding: const EdgeInsets.only(right: 15.0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  if (_key.currentState!.validate()) {
                                    _key.currentState!.save();
                                    if (islisting == false) {
                                      showDialog<String>(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            AlertDialog(
                                          content: const Text(
                                              'Please Add GEB data to Machine List First.'),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, 'OK'),
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      Utils(context).startLoading();
                                      if (data.length == 0) {
                                        AddGEBList();
                                      } else {
                                        UpdateGEBList(data[0]["id"].toString());
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "KWH",
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
                                      controller: kwh,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "KVARH",
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
                                      controller: kvarh,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "KVAH",
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
                                      controller: kvah,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "MD",
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
                                      controller: md,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Turbine",
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
                                      controller: turbine,
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
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
