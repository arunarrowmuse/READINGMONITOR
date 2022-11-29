import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../constants.dart';

class ViewGEB extends StatefulWidget {
  const ViewGEB({Key? key}) : super(key: key);

  @override
  State<ViewGEB> createState() => _ViewGEBState();
}

class _ViewGEBState extends State<ViewGEB>
    with AutomaticKeepAliveClientMixin<ViewGEB> {
  DateTime selectedDate = DateTime.now();
  bool isLoad = false;
  var data;
  late SharedPreferences prefs;
  String? tokenvalue;
  var machinedata;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2050, 1));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        FetchGEBReport();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    FetchGEBReport();
  }

  void FetchGEBReport() async {
    setState(() {
      isLoad = true;
    });
    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    final response = await http.get(
      Uri.parse(
          '${Constants.weblink}ViewReportGebDateSearch/${selectedDate.toString()
              .split(" ")[0]}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      print("VIEW GEB");
      // print(response.body);
      data = jsonDecode(response.body);
      print(data);
      if (data.length == 0) {
        print("i called");
        FetchGEBMachineList();
      } else {
        setState(() {
          isLoad = false;
        });
      }
      // setState(() {
      //   isLoad = false;
      // });
    } else {
      print(response.statusCode);
      print(response.body);
      setState(() {
        isLoad = false;
      });
      Constants.showtoast("Error Fetching Data.");
    }
  }

  void FetchGEBMachineList() async {
    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    final response = await http.get(
      Uri.parse(
          '${Constants.weblink}GetGebListing'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
    );
    if (response.statusCode == 200) {
      machinedata = jsonDecode(response.body);
      print("machinedata");
      print(machinedata);
      setState(() {
        isLoad = false;
      });
    } else {
      print('error');
      print(response.body);
      setState(() {
        isLoad = false;
      });
      Constants.showtoast("Error Fetching Data.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery
        .of(context)
        .size
        .height;
    final w = MediaQuery
        .of(context)
        .size
        .width;
    DateTime now = DateTime.now();
    var formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
    return RefreshIndicator(
      onRefresh: () {
        return Future(() => FetchGEBReport());
      },
      child: Scaffold(
          body: Column(
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
                      Row(
                        children: [
                          SizedBox(
                            height: 40,
                            // width: 100,
                            child: FittedBox(
                              fit: BoxFit.fitHeight,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<
                                        Color>(
                                        const Color(0xFFE1DFDD))),
                                child: Text(" SMS ",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontFamily: Constants.popins,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            height: 40,
                            // width: 100,
                            child: FittedBox(
                              fit: BoxFit.fitHeight,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<
                                        Color>(
                                        const Color(0xFFE1DFDD))),
                                child: Text(" E-Mail ",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontFamily: Constants.popins,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              (isLoad == true)
                  ? SizedBox(
                height: 500,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Constants.primaryColor,
                  ),
                ),
              )
                  : (data.length != 0)
                  ? Expanded(
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
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
                                  data[index]['machine_name'],
                                  style: TextStyle(
                                      fontFamily: Constants.popins,
                                      color: Constants.textColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                    width: w / 3,
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Text(
                                              "KWH",
                                              style: TextStyle(
                                                  fontFamily:
                                                  Constants.popins,
                                                  // color: Constants.textColor,
                                                  fontWeight:
                                                  FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                            Text(
                                              (data[index]['kwh']??0)
                                                  .toStringAsFixed(2),
                                              style: TextStyle(
                                                  fontFamily:
                                                  Constants.popins,
                                                  decoration:
                                                  TextDecoration
                                                      .underline,
                                                  // color: Constants.textColor,
                                                  // fontWeight: FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Text(
                                              "PF",
                                              style: TextStyle(
                                                  fontFamily:
                                                  Constants.popins,
                                                  // color: Constants.textColor,
                                                  fontWeight:
                                                  FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                            Text(
                                              (data[index]['pf']??0)
                                                  .toStringAsFixed(2),
                                              style: TextStyle(
                                                  fontFamily:
                                                  Constants.popins,
                                                  decoration:
                                                  TextDecoration
                                                      .underline,
                                                  // color: Constants.textColor,
                                                  // fontWeight: FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Text(
                                              "KVARH",
                                              style: TextStyle(
                                                  fontFamily:
                                                  Constants.popins,
                                                  // color: Constants.textColor,
                                                  fontWeight:
                                                  FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                            Text(
                                              (data[index]['kvarh']??0)
                                                  .toStringAsFixed(2),
                                              style: TextStyle(
                                                  fontFamily:
                                                  Constants.popins,
                                                  decoration:
                                                  TextDecoration
                                                      .underline,
                                                  // color: Constants.textColor,
                                                  // fontWeight: FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Text(
                                              "MD",
                                              style: TextStyle(
                                                  fontFamily:
                                                  Constants.popins,
                                                  // color: Constants.textColor,
                                                  fontWeight:
                                                  FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                            Text(
                                              (data[index]['mdTotal']??0)
                                                  .toStringAsFixed(2),
                                              style: TextStyle(
                                                  fontFamily:
                                                  Constants.popins,
                                                  decoration:
                                                  TextDecoration
                                                      .underline,
                                                  // color: Constants.textColor,
                                                  // fontWeight: FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Text(
                                              "KVAH",
                                              style: TextStyle(
                                                  fontFamily:
                                                  Constants.popins,
                                                  // color: Constants.textColor,
                                                  fontWeight:
                                                  FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                            Text(
                                              (data[index]['kevah']??0)
                                                  .toStringAsFixed(2),
                                              style: TextStyle(
                                                  fontFamily:
                                                  Constants.popins,
                                                  decoration:
                                                  TextDecoration
                                                      .underline,
                                                  // color: Constants.textColor,
                                                  // fontWeight: FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Text(
                                              "Turbine",
                                              style: TextStyle(
                                                  fontFamily:
                                                  Constants.popins,
                                                  // color: Constants.textColor,
                                                  fontWeight:
                                                  FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                            Text(
                                              (data[index]['turbine']??0)
                                                  .toStringAsFixed(2),
                                              style: TextStyle(
                                                  fontFamily:
                                                  Constants.popins,
                                                  decoration:
                                                  TextDecoration
                                                      .underline,
                                                  // color: Constants.textColor,
                                                  // fontWeight: FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),

                                      ],
                                    )),
                                Container(
                                  color: Constants.secondaryColor
                                      .withOpacity(0.2),
                                  width: 1,
                                  height: h / 8,
                                ),
                                Container(
                                    width: w / 2,
                                    // color: Collors.red,
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Text(
                                              "KWH Deviation",
                                              style: TextStyle(
                                                  fontFamily:
                                                  Constants.popins,
                                                  // color: Constants.textColor,
                                                  fontWeight:
                                                  FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                            ((num.parse(
                                                (data[index]["kwhtotalper"] ?? 0)
                                                    .toString()) <
                                                num.parse(
                                                    (data[index]["kwm_deviation"] ??
                                                        0).toString()) &&
                                                num.parse(
                                                    (data[index]["kwhtotalper"] ??
                                                        0).toString()) >
                                                    num.parse(
                                                        (data[index]["kwm_deviation"] ??
                                                            0).toString()) *
                                                        -1))
                                                ? Text(
                                                num.parse(
                                                    (data[index]['kwhtotalper'] ??
                                                        0).toString())
                                                    .toStringAsFixed(2) +
                                                    " %",
                                                style: TextStyle(
                                                  // color: Colors.grey,
                                                    fontFamily:
                                                    Constants.popins,
                                                    fontSize: 12))
                                                : Text(
                                                num.parse(
                                                    (data[index]['kwhtotalper'] ??
                                                        0).toString())
                                                    .toStringAsFixed(2) +
                                                    " %",
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    fontFamily:
                                                    Constants.popins,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12)),

                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Text(
                                              "PF Deviation",
                                              style: TextStyle(
                                                  fontFamily:
                                                  Constants.popins,
                                                  // color: Constants.textColor,
                                                  fontWeight:
                                                  FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                            ((num.parse((data[index]["pfper"] ?? 0)
                                                .toString()) <
                                                num.parse(
                                                    (data[index]["pf_deviation"] ??
                                                        0).toString()) &&
                                                num.parse(
                                                    (data[index]["pfper"] ?? 0)
                                                        .toString()) >
                                                    num.parse(
                                                        (data[index]["pf_deviation"] ??
                                                            0).toString()) *
                                                        -1))
                                                ? Text(
                                                num.parse(
                                                    (data[index]['pfper'] ?? 0)
                                                        .toString())
                                                    .toStringAsFixed(2) +
                                                    " %",
                                                style: TextStyle(
                                                  // color: Colors.grey,
                                                    fontFamily:
                                                    Constants.popins,
                                                    fontSize: 12))
                                                : Text(
                                                num.parse(
                                                    (data[index]['pfper'] ?? 0)
                                                        .toString())
                                                    .toStringAsFixed(2) +
                                                    " %",
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    fontFamily:
                                                    Constants.popins,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12)),


                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Text(
                                              "KVARH Deviation",
                                              style: TextStyle(
                                                  fontFamily:
                                                  Constants.popins,
                                                  // color: Constants.textColor,
                                                  fontWeight:
                                                  FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                            ((num.parse(
                                                (data[index]["kvarhper"] ?? 0)
                                                    .toString()) <
                                                num.parse((data[index]
                                                ["kvarsh_deviation"] ?? 0)
                                                    .toString()) &&
                                                num.parse(
                                                    (data[index]["kvarhper"] ?? 0)
                                                        .toString()) >
                                                    num.parse((data[index]
                                                    ["kvarsh_deviation"] ?? 0)
                                                        .toString()) *
                                                        -1))
                                                ? Text(
                                                num.parse(
                                                    (data[index]['kvarhper'] ?? 0)
                                                        .toString())
                                                    .toStringAsFixed(2) +
                                                    " %",
                                                style: TextStyle(
                                                  // color: Colors.grey,
                                                    fontFamily:
                                                    Constants.popins,
                                                    fontSize: 12))
                                                : Text(
                                                num.parse(
                                                    (data[index]['kvarhper'] ?? 0)
                                                        .toString())
                                                    .toStringAsFixed(2) +
                                                    " %",
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    fontFamily:
                                                    Constants.popins,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12)),


                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Text(
                                              "MD Deviation",
                                              style: TextStyle(
                                                  fontFamily:
                                                  Constants.popins,
                                                  // color: Constants.textColor,
                                                  fontWeight:
                                                  FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                            ((num.parse((data[index]["mdper"] ?? 0).toString()) <
                                                num.parse((data[index]["md_deviation"]??0).toString()) &&
                                                num.parse((data[index]["mdper"] ?? 0).toString()) >
                                                    num.parse((data[index]["md_deviation"]??0).toString()) *
                                                        -1))
                                                ? Text(
                                                num.parse((data[index]['mdper'] ?? 0).toString())
                                                    .toStringAsFixed(2) +
                                                    " %",
                                                style: TextStyle(
                                                  // color: Colors.grey,
                                                    fontFamily:
                                                    Constants.popins,
                                                    fontSize: 12))
                                                : Text(
                                                num.parse((data[index]['mdper'] ?? 0).toString())
                                                    .toStringAsFixed(2) +
                                                    " %",
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    fontWeight: FontWeight.w600,
                                                    fontFamily:
                                                    Constants.popins,
                                                    fontSize: 12)),


                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Text(
                                              "KVAH Deviation",
                                              style: TextStyle(
                                                  fontFamily:
                                                  Constants.popins,
                                                  // color: Constants.textColor,
                                                  fontWeight:
                                                  FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                            ((num.parse((data[index]["kvahper"] ?? 0).toString()) <
                                                num.parse((data[index]
                                                ["kevah_deviation"]??0).toString()) &&
                                                num.parse((data[index]["kvahper"] ?? 0).toString()) >
                                                    num.parse((data[index]
                                                    ["kevah_deviation"]??0).toString()) *
                                                        -1))
                                                ? Text(
                                                num.parse((data[index]['kvahper'] ?? 0).toString())
                                                    .toStringAsFixed(2) +
                                                    " %",
                                                style: TextStyle(
                                                  // color: Colors.grey,
                                                    fontFamily:
                                                    Constants.popins,
                                                    fontSize: 12))
                                                : Text(
                                                num.parse((data[index]['kvahper'] ?? 0).toString())
                                                    .toStringAsFixed(2) +
                                                    " %",
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    fontFamily:
                                                    Constants.popins,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12)),


                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Text(
                                              "Turbine Deviation",
                                              style: TextStyle(
                                                  fontFamily:
                                                  Constants.popins,
                                                  // color: Constants.textColor,
                                                  fontWeight:
                                                  FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                            ((num.parse((data[index]["turbineper"] ?? 0).toString()) <
                                                num.parse((data[index]["turbine_deviation"] ??
                                                    0).toString()) &&
                                                num.parse((data[index]["turbineper"] ?? 0).toString()) >
                                                    num.parse((data[index]["turbine_deviation"] ??
                                                        0).toString()) *
                                                        -1))
                                                ? Text(
                                                num.parse((data[index]['turbineper'] ?? 0).toString())
                                                    .toStringAsFixed(2) +
                                                    " %",
                                                style: TextStyle(
                                                  // color: Colors.grey,
                                                    fontFamily:
                                                    Constants.popins,
                                                    fontSize: 12))
                                                : Text(
                                                num.parse((data[index]['turbineper'] ?? 0).toString())
                                                    .toStringAsFixed(2) +
                                                    " %",
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    fontFamily:
                                                    Constants.popins,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12)),


                                          ],
                                        ),
                                      ],
                                    )),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
                  : (machinedata.length == 0)
                  ? Container(
                height: 500,
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
                  :  Expanded(
                child: ListView.builder(
                  itemCount: machinedata.length,
                  itemBuilder: (context, index) {
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
                                  machinedata[index]['machine_name'],
                                  style: TextStyle(
                                      fontFamily: Constants.popins,
                                      color: Constants.textColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                    width: w / 3,
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Text(
                                              "KWH",
                                              style: TextStyle(
                                                  fontFamily:
                                                  Constants.popins,
                                                  // color: Constants.textColor,
                                                  fontWeight:
                                                  FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                            Text(
                                              (0)
                                                  .toStringAsFixed(2),
                                              style: TextStyle(
                                                  fontFamily:
                                                  Constants.popins,
                                                  decoration:
                                                  TextDecoration
                                                      .underline,
                                                  // color: Constants.textColor,
                                                  // fontWeight: FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Text(
                                              "PF",
                                              style: TextStyle(
                                                  fontFamily:
                                                  Constants.popins,
                                                  // color: Constants.textColor,
                                                  fontWeight:
                                                  FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                            Text(
                                              (0)
                                                  .toStringAsFixed(2),
                                              style: TextStyle(
                                                  fontFamily:
                                                  Constants.popins,
                                                  decoration:
                                                  TextDecoration
                                                      .underline,
                                                  // color: Constants.textColor,
                                                  // fontWeight: FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Text(
                                              "KVARH",
                                              style: TextStyle(
                                                  fontFamily:
                                                  Constants.popins,
                                                  // color: Constants.textColor,
                                                  fontWeight:
                                                  FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                            Text(
                                              (0)
                                                  .toStringAsFixed(2),
                                              style: TextStyle(
                                                  fontFamily:
                                                  Constants.popins,
                                                  decoration:
                                                  TextDecoration
                                                      .underline,
                                                  // color: Constants.textColor,
                                                  // fontWeight: FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Text(
                                              "MD",
                                              style: TextStyle(
                                                  fontFamily:
                                                  Constants.popins,
                                                  // color: Constants.textColor,
                                                  fontWeight:
                                                  FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                            Text(
                                              (0)
                                                  .toStringAsFixed(2),
                                              style: TextStyle(
                                                  fontFamily:
                                                  Constants.popins,
                                                  decoration:
                                                  TextDecoration
                                                      .underline,
                                                  // color: Constants.textColor,
                                                  // fontWeight: FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Text(
                                              "KVAH",
                                              style: TextStyle(
                                                  fontFamily:
                                                  Constants.popins,
                                                  // color: Constants.textColor,
                                                  fontWeight:
                                                  FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                            Text(
                                              (0)
                                                  .toStringAsFixed(2),
                                              style: TextStyle(
                                                  fontFamily:
                                                  Constants.popins,
                                                  decoration:
                                                  TextDecoration
                                                      .underline,
                                                  // color: Constants.textColor,
                                                  // fontWeight: FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Text(
                                              "Turbine",
                                              style: TextStyle(
                                                  fontFamily:
                                                  Constants.popins,
                                                  // color: Constants.textColor,
                                                  fontWeight:
                                                  FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                            Text(
                                              (0)
                                                  .toStringAsFixed(2),
                                              style: TextStyle(
                                                  fontFamily:
                                                  Constants.popins,
                                                  decoration:
                                                  TextDecoration
                                                      .underline,
                                                  // color: Constants.textColor,
                                                  // fontWeight: FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),

                                      ],
                                    )),
                                Container(
                                  color: Constants.secondaryColor
                                      .withOpacity(0.2),
                                  width: 1,
                                  height: h / 8,
                                ),
                                Container(
                                    width: w / 2,
                                    // color: Collors.red,
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Text(
                                              "KWH Deviation",
                                              style: TextStyle(
                                                  fontFamily:
                                                  Constants.popins,
                                                  // color: Constants.textColor,
                                                  fontWeight:
                                                  FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                            Text(
                                                num.parse(
                                                    (
                                                        0).toString())
                                                    .toStringAsFixed(2) +
                                                    " %",
                                                style: TextStyle(
                                                  // color: Colors.grey,
                                                    fontFamily:
                                                    Constants.popins,
                                                    fontSize: 12))

                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Text(
                                              "PF Deviation",
                                              style: TextStyle(
                                                  fontFamily:
                                                  Constants.popins,
                                                  // color: Constants.textColor,
                                                  fontWeight:
                                                  FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                            Text(
                                                num.parse(
                                                    ( 0)
                                                        .toString())
                                                    .toStringAsFixed(2) +
                                                    " %",
                                                style: TextStyle(
                                                  // color: Colors.grey,
                                                    fontFamily:
                                                    Constants.popins,
                                                    fontSize: 12))


                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Text(
                                              "KVARH Deviation",
                                              style: TextStyle(
                                                  fontFamily:
                                                  Constants.popins,
                                                  // color: Constants.textColor,
                                                  fontWeight:
                                                  FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                            Text(
                                                num.parse(
                                                    ( 0)
                                                        .toString())
                                                    .toStringAsFixed(2) +
                                                    " %",
                                                style: TextStyle(
                                                  // color: Colors.grey,
                                                    fontFamily:
                                                    Constants.popins,
                                                    fontSize: 12))


                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Text(
                                              "MD Deviation",
                                              style: TextStyle(
                                                  fontFamily:
                                                  Constants.popins,
                                                  // color: Constants.textColor,
                                                  fontWeight:
                                                  FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                            Text(
                                                num.parse(( 0).toString())
                                                    .toStringAsFixed(2) +
                                                    " %",
                                                style: TextStyle(
                                                  // color: Colors.grey,
                                                    fontFamily:
                                                    Constants.popins,
                                                    fontSize: 12))


                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Text(
                                              "KVAH Deviation",
                                              style: TextStyle(
                                                  fontFamily:
                                                  Constants.popins,
                                                  // color: Constants.textColor,
                                                  fontWeight:
                                                  FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                            Text(
                                                num.parse(( 0).toString())
                                                    .toStringAsFixed(2) +
                                                    " %",
                                                style: TextStyle(
                                                  // color: Colors.grey,
                                                    fontFamily:
                                                    Constants.popins,
                                                    fontSize: 12))


                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Text(
                                              "Turbine Deviation",
                                              style: TextStyle(
                                                  fontFamily:
                                                  Constants.popins,
                                                  // color: Constants.textColor,
                                                  fontWeight:
                                                  FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                            Text(
                                                num.parse(( 0).toString())
                                                    .toStringAsFixed(2) +
                                                    " %",
                                                style: TextStyle(
                                                  // color: Colors.grey,
                                                    fontFamily:
                                                    Constants.popins,
                                                    fontSize: 12))


                                          ],
                                        ),
                                      ],
                                    )),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          )),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
