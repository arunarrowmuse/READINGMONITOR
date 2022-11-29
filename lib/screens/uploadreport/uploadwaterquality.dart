import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';

class UploadWaterQuality extends StatefulWidget {
  const UploadWaterQuality({Key? key}) : super(key: key);

  @override
  State<UploadWaterQuality> createState() => _UploadWaterQualityState();
}

class _UploadWaterQualityState extends State<UploadWaterQuality>
    with AutomaticKeepAliveClientMixin<UploadWaterQuality> {
  List<TextEditingController> TDSControllers = [];
  List<TextEditingController> PHControllers = [];
  List<TextEditingController> HardnessControllers = [];
  List<TextEditingController> IDControllers = [];
  DateTime selectedDate = DateTime.now();
  bool isLoad = false;
  var uploaddata;
  var listdata;
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
        TDSControllers.clear();
        PHControllers.clear();
        HardnessControllers.clear();
        FetchWaterList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    FetchWaterList();
  }

  void FetchWaterList() async {
    TDSControllers.clear();
    PHControllers.clear();
    HardnessControllers.clear();
    IDControllers.clear();
    setState(() {
      isLoad = true;
    });
    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    final response = await http.get(
      Uri.parse(
          '${Constants.weblink}GetWaterQualityLisiting/${selectedDate.toString().split(" ")[0]}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
    );
    if (response.statusCode == 200) {
      listdata = jsonDecode(response.body);
      print("machine list");
      print(listdata.length);
      print(listdata);
      final responses = await http.get(
        Uri.parse(
            '${Constants.weblink}GetWaterQualityReportDateSearch/${selectedDate.toString().split(" ")[0]}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $tokenvalue',
        },
      );
      if (responses.statusCode == 200) {
        uploaddata = jsonDecode(responses.body);
        print(" upload data");
        print(uploaddata.length);
        print(uploaddata);
        if (uploaddata.length == 0) {
          for (int i = 0; i < listdata.length; i++) {
            var tdsController = TextEditingController(text: "");
            var phController = TextEditingController(text: "");
            var hardnessController = TextEditingController(text: "");
            var idController = TextEditingController(text: "0");
            TDSControllers.add(tdsController);
            PHControllers.add(phController);
            HardnessControllers.add(hardnessController);
            IDControllers.add(idController);
          }
        } else {
          for (int i = 0; i < listdata.length; i++) {
            var tdsController = TextEditingController(text: "");
            var phController = TextEditingController(text: "");
            var hardnessController = TextEditingController(text: "");
            var idController = TextEditingController(text: "0");
            for (int j = 0; j < uploaddata.length; j++) {
              if (listdata[i]['id'] == uploaddata[j]['machine_name_id']) {
                idController =
                    TextEditingController(text: uploaddata[j]['id'].toString());
                tdsController = TextEditingController(
                    text: uploaddata[j]['tds'].toString());
                phController =
                    TextEditingController(text: uploaddata[j]['ph'].toString());
                hardnessController = TextEditingController(
                    text: uploaddata[j]['hardness'].toString());
              }
            }
            TDSControllers.add(tdsController);
            PHControllers.add(phController);
            HardnessControllers.add(hardnessController);
            IDControllers.add(idController);
          }
        }
        setState(() {
          isLoad = false;
        });
      } else {
        print(responses.statusCode);
        print(responses.body);
        setState(() {
          isLoad = false;
        });
        Constants.showtoast("Error Fetching Data.");
      }
    } else {
      Constants.showtoast("Error Fetching Data.");
    }
  }

  void AddWaterList(int i) async {
    Utils(context).startLoading();
    // for (int i = 0; i < listdata.length; i++) {
    String tds = "0";
    String ph = "0";
    String hardness = "0";
    if (TDSControllers[i].text != "") {
      tds = TDSControllers[i].text;
    }
    if (PHControllers[i].text != "") {
      ph = PHControllers[i].text;
    }
    if (HardnessControllers[i].text != "") {
      hardness = HardnessControllers[i].text;
    }
    final response = await http.post(
      Uri.parse('${Constants.weblink}GetWaterQualityReportUploadAdd'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
      body: jsonEncode(<String, String>{
        // "id": ValueID[i].text,
        "date": selectedDate.toString().split(" ")[0],
        "machine_name_id": listdata[i]["id"].toString(),
        "tds": tds,
        "ph": ph,
        "hardness": hardness
      }),
    );
    if (response.statusCode == 200) {
      // uploaddata = jsonDecode(response.body);
      // if (i == listdata.length - 1) {
      Constants.showtoast("Report Added!");
      Utils(context).stopLoading();
      // }
    } else {
      print(response.statusCode);
      print(response.body);
      Utils(context).stopLoading();
      Constants.showtoast("Error Updating Data.");
    }
    // }
    FetchWaterList();
  }

  void UpdateWaterList(int i, String id) async {
    Utils(context).startLoading();
    // for (int i = 0; i < listdata.length; i++) {
    String tds = "0";
    String ph = "0";
    String hardness = "0";
    if (TDSControllers[i].text != "") {
      tds = TDSControllers[i].text;
    }
    if (PHControllers[i].text != "") {
      ph = PHControllers[i].text;
    }
    if (HardnessControllers[i].text != "") {
      hardness = HardnessControllers[i].text;
    }
    final response = await http.post(
      Uri.parse('${Constants.weblink}GetWaterQualityReportUploadUpdated/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
      body: jsonEncode(<String, String>{
        '_method': "PUT",
        // "date": selectedDate.toString().split(" ")[0],
        "machine_name_id": listdata[i]["id"].toString(),
        "tds": tds,
        "ph": ph,
        "hardness": hardness
      }),
    );
    if (response.statusCode == 200) {
      Constants.showtoast("Report Updated!");
      Utils(context).stopLoading();
    } else {
      print(response.statusCode);
      print(response.body);
      Utils(context).stopLoading();
      Constants.showtoast("Error Updating Data.");
    }
    // }
    FetchWaterList();
  }

  void AddUpdateWaterList() async {
    Utils(context).startLoading();
    for (int i = 0; i < IDControllers.length; i++) {
      if (IDControllers[i].text.toString() == "0") {
        if (TDSControllers[i].text != "" || PHControllers[i].text != ""|| HardnessControllers[i].text != "") {
          print('Added');
          String tds = "0";
          String ph = "0";
          String hardness = "0";
          if (TDSControllers[i].text != "") {
            tds = TDSControllers[i].text;
          }
          if (PHControllers[i].text != "") {
            ph = PHControllers[i].text;
          }
          if (HardnessControllers[i].text != "") {
            hardness = HardnessControllers[i].text;
          }
          final response = await http.post(
            Uri.parse('${Constants.weblink}GetWaterQualityReportUploadAdd'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $tokenvalue',
            },
            body: jsonEncode(<String, String>{
              // "id": ValueID[i].text,
              "date": selectedDate.toString().split(" ")[0],
              "machine_name_id": listdata[i]["id"].toString(),
              "tds": tds,
              "ph": ph,
              "hardness": hardness
            }),
          );
          if (response.statusCode == 200) {
            // Constants.showtoast("Report Added!");
          } else {
            Constants.showtoast("Error Updating Data.");
          }
        } else {
          print("skipped");
        }
      }
      else {
        print("update data");
        String tds = "0";
        String ph = "0";
        String hardness = "0";
        if (TDSControllers[i].text != "") {
          tds = TDSControllers[i].text;
        }
        if (PHControllers[i].text != "") {
          ph = PHControllers[i].text;
        }
        if (HardnessControllers[i].text != "") {
          hardness = HardnessControllers[i].text;
        }
        final response = await http.post(
          Uri.parse('${Constants.weblink}GetWaterQualityReportUploadUpdated/${IDControllers[i].text}'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $tokenvalue',
          },
          body: jsonEncode(<String, String>{
            '_method': "PUT",
            // "date": selectedDate.toString().split(" ")[0],
            "machine_name_id": listdata[i]["id"].toString(),
            "tds": tds,
            "ph": ph,
            "hardness": hardness
          }),
        );
        if (response.statusCode == 200) {
          // Constants.showtoast("Report Updated!");
          // Utils(context).stopLoading();
        } else {
          print(response.statusCode);
          print(response.body);
          // Utils(context).stopLoading();
          Constants.showtoast("Error Updating Data.");
        }
      }
    }
    // Utils(context).stopLoading();
    // Utils(context).stopLoading();
    Constants.showtoast("All Report Updated!");
    Utils(context).stopLoading();
    FetchWaterList();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    DateTime now = DateTime.now();
    var formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
    return RefreshIndicator(
      onRefresh: () {
        return Future(() => FetchWaterList());
      },
      child: Scaffold(
        body: Column(
          children: [
            const SizedBox(height: 10),
            SizedBox(
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
                          // Utils(context).startLoading();
                          // if (uploaddata.length == 0) {
                          //   AddUtilityList();
                          // } else {
                          //   UpdateUtilityList();
                          // }
                          AddUpdateWaterList();
                        },
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Constants.primaryColor)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(" Sumbit All    ",
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
            SizedBox(height: 20),
            (isLoad == true)
                ? SizedBox(
                    height: 500,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Constants.primaryColor,
                      ),
                    ),
                  )
                : (listdata.length == 0)
                    ? Container(
                        height: 300,
                        child: Center(
                          child: Text(
                            "no machines found",
                            style: TextStyle(
                                fontFamily: Constants.popins,
                                color: Constants.textColor,
                                // fontWeight: FontWeight.w600,
                                fontSize: 15),
                          ),
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount: listdata.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(15.0)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 3,
                                      offset: const Offset(
                                          0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 15),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      // crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          listdata[index]['machine_name']
                                              .toString(),
                                          style: TextStyle(
                                              fontFamily: Constants.popins,
                                              color: Constants.textColor,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15),
                                        ),
                                        Container(
                                          height: 30,
                                          padding: const EdgeInsets.only(
                                              right: 15.0),
                                          // width: 100,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              // Utils(context).startLoading();
                                              if (IDControllers[index].text ==
                                                  "0") {
                                                AddWaterList(index);
                                              } else {
                                                UpdateWaterList(index,
                                                    IDControllers[index].text);
                                              }
                                            },
                                            style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty
                                                        .all<Color>(Constants
                                                            .primaryColor)),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(" Sumbit  ",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontFamily:
                                                            Constants.popins,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12)),
                                                // Image.asset(
                                                //   "assets/icons/Edit.png",
                                                //   height: 16,
                                                // )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Container(
                                        width: w / 1,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "TDS",
                                                  style: TextStyle(
                                                      fontFamily:
                                                          Constants.popins,
                                                      // color: Constants.textColor,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 12),
                                                ),
                                                const SizedBox(width: 10),
                                                SizedBox(
                                                  height: 35,
                                                  width: w * 0.15,
                                                  child: TextFormField(
                                                    keyboardType:
                                                        TextInputType.number,
                                                    controller:
                                                        TDSControllers[index],
                                                    style: TextStyle(
                                                      fontFamily:
                                                          Constants.popins,
                                                      // color: Constants.textColor,
                                                    ),
                                                    decoration: InputDecoration(
                                                        contentPadding:
                                                            const EdgeInsets
                                                                    .only(
                                                                bottom: 10.0,
                                                                left: 10.0),
                                                        isDense: true,
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300,
                                                                  width: 1.0),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Constants
                                                                  .primaryColor,
                                                              width: 2.0),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        filled: true,
                                                        hintStyle: TextStyle(
                                                          color:
                                                              Colors.grey[400],
                                                          fontFamily:
                                                              Constants.popins,
                                                        ),
                                                        // hintText: "first name",
                                                        fillColor:
                                                            Colors.white70),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "PH",
                                                  style: TextStyle(
                                                      fontFamily:
                                                          Constants.popins,
                                                      // color: Constants.textColor,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 12),
                                                ),
                                                const SizedBox(width: 10),
                                                SizedBox(
                                                  height: 35,
                                                  width: w * 0.15,
                                                  child: TextFormField(
                                                    keyboardType:
                                                        TextInputType.number,
                                                    controller:
                                                        PHControllers[index],
                                                    style: TextStyle(
                                                      fontFamily:
                                                          Constants.popins,
                                                      // color: Constants.textColor,
                                                    ),
                                                    decoration: InputDecoration(
                                                        contentPadding:
                                                            const EdgeInsets
                                                                    .only(
                                                                bottom: 10.0,
                                                                left: 10.0),
                                                        isDense: true,
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300,
                                                                  width: 1.0),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Constants
                                                                  .primaryColor,
                                                              width: 2.0),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        filled: true,
                                                        hintStyle: TextStyle(
                                                          color:
                                                              Colors.grey[400],
                                                          fontFamily:
                                                              Constants.popins,
                                                        ),
                                                        // hintText: "first name",
                                                        fillColor:
                                                            Colors.white70),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "Hardness",
                                                  style: TextStyle(
                                                      fontFamily:
                                                          Constants.popins,
                                                      // color: Constants.textColor,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 12),
                                                ),
                                                const SizedBox(width: 10),
                                                SizedBox(
                                                  height: 35,
                                                  width: w * 0.15,
                                                  child: TextFormField(
                                                    keyboardType:
                                                        TextInputType.number,
                                                    controller:
                                                        HardnessControllers[
                                                            index],
                                                    style: TextStyle(
                                                      fontFamily:
                                                          Constants.popins,
                                                      // color: Constants.textColor,
                                                    ),
                                                    decoration: InputDecoration(
                                                        contentPadding:
                                                            const EdgeInsets
                                                                    .only(
                                                                bottom: 10.0,
                                                                left: 10.0),
                                                        isDense: true,
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300,
                                                                  width: 1.0),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Constants
                                                                  .primaryColor,
                                                              width: 2.0),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        filled: true,
                                                        hintStyle: TextStyle(
                                                          color:
                                                              Colors.grey[400],
                                                          fontFamily:
                                                              Constants.popins,
                                                        ),
                                                        // hintText: "first name",
                                                        fillColor:
                                                            Colors.white70),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ))
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
