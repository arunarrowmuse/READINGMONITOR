import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../constants.dart';

class VIewMachines extends StatefulWidget {
  const VIewMachines({Key? key}) : super(key: key);

  @override
  State<VIewMachines> createState() => _VIewMachinesState();
}

class _VIewMachinesState extends State<VIewMachines>
    with AutomaticKeepAliveClientMixin<VIewMachines> {
  DateTime selectedDate = DateTime.now();
  bool isLoad = false;
  var data;
  var sdata;
  var machinedata;
  var submachinedata;
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
        FetchMachinesReport();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    FetchMachinesReport();
  }

  void FetchMachinesReport() async {
    setState(() {
      isLoad = true;
    });
    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    final response = await http.get(
      Uri.parse(
          '${Constants.weblink}ViewReportMachineDateSearchMainCategories/${selectedDate.toString().split(" ")[0]}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      print("mAIN macinhweeeeeeee");
      print(response.body);
      data = jsonDecode(response.body);
      print(data);
      if (data.length != 0) {
        FetchSubMachinesReport();
      } else {
        FetchMachinesMachineList();
      }
    } else {
      print(response.statusCode);
      print(response.body);
      setState(() {
        isLoad = false;
      });
      Constants.showtoast("Error Fetching Data.");
    }
  }

  void FetchSubMachinesReport() async {
    // setState(() {
    //   isLoad = true;
    // });
    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    final response = await http.get(
      Uri.parse(
          '${Constants.weblink}ViewReportMachineDateSearch/${selectedDate.toString().split(" ")[0]}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      print("ViewReportMachineDateSearch");
      // print(response.body);
      sdata = jsonDecode(response.body);
      print(sdata);
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

  void FetchMachinesMachineList() async {
    // setState(() {
    //   isLoad = true;
    // });
    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    final response = await http.get(
      Uri.parse(
          '${Constants.weblink}GetMachineCategoriesListing/${selectedDate.toString().split(" ")[0]}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
    );
    if (response.statusCode == 200) {
      print(response.statusCode);
      print(response.body);
      machinedata = jsonDecode(response.body);
      print("Main Machine Data");
      print(machinedata);
      FetchSubMachineList();
      // setState(() {
      //   isLoad = false;
      // });
    } else {
      setState(() {
        isLoad = false;
      });
      Constants.showtoast("Error Fetching Data.");
    }
  }

  void FetchSubMachineList() async {
    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    final response = await http.get(
      Uri.parse(
          '${Constants.weblink}GetMachineSubCategoriesListing/${selectedDate.toString().split(" ")[0]}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
    );
    if (response.statusCode == 200) {
      submachinedata = jsonDecode(response.body);
      print("SUB MACHINE DATA");
      print(submachinedata);
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
    return RefreshIndicator(
      onRefresh: () {
        return Future(() => FetchMachinesReport());
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
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
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
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
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
                                padding: const EdgeInsets.only(
                                    bottom: 5.0, left: 5, right: 5),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Constants.primaryColor,
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
                                      vertical: 2, horizontal: 15),
                                  child: ExpansionTile(
                                    title: Container(),
                                    subtitle: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          // crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              data[index]['categories'],
                                              style: TextStyle(
                                                  fontFamily: Constants.popins,
                                                  color: Colors.white,
                                                  // fontWeight: FontWeight.w600,
                                                  fontSize: 25),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        // Container(color: Colors.blue,width: w,height: 1,),
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
                                                          "EM",
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  Constants
                                                                      .popins,
                                                              color:
                                                                  Colors.white,
                                                              // color: Constants.textColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 12),
                                                        ),
                                                        Text(
                                                          num.parse(data[index]
                                                                      ['em']
                                                                  .toString())
                                                              .toStringAsFixed(
                                                                  2),
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  Constants
                                                                      .popins,
                                                              decoration:
                                                                  TextDecoration
                                                                      .underline,
                                                              color:
                                                                  Colors.white,
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
                                                          "HM",
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  Constants
                                                                      .popins,
                                                              color:
                                                                  Colors.white,
                                                              // color: Constants.textColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 12),
                                                        ),
                                                        Text(
                                                          num.parse(data[index]
                                                                      ['hm']
                                                                  .toString())
                                                              .toStringAsFixed(
                                                                  2),
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  Constants
                                                                      .popins,
                                                              decoration:
                                                                  TextDecoration
                                                                      .underline,
                                                              color:
                                                                  Colors.white,
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
                                                          "EM/HM",
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  Constants
                                                                      .popins,
                                                              color:
                                                                  Colors.white,
                                                              // color: Constants.textColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 12),
                                                        ),
                                                        Text(
                                                          (data[index]['dev'] ??
                                                                  0)
                                                              .toStringAsFixed(2),
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  Constants
                                                                      .popins,
                                                              decoration:
                                                                  TextDecoration
                                                                      .underline,
                                                              color:
                                                                  Colors.white,
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
                                                          "%",
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  Constants
                                                                      .popins,
                                                              color:
                                                                  Colors.white,
                                                              // color: Constants.textColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 12),
                                                        ),
                                                        (num.parse((data[index]["average"] ??
                                                                            0)
                                                                        .toString()) <
                                                                    num.parse(data[index][
                                                                            "em_hm_percentage"]
                                                                        .toString()) &&
                                                                num.parse((data[index]["average"] ??
                                                                            0)
                                                                        .toString()) >
                                                                    num.parse(data[index]["em_hm_percentage"]
                                                                            .toString()) *
                                                                        -1)
                                                            ? Text(
                                                                num.parse((data[index]['average'] ??
                                                                                0)
                                                                            .toString())
                                                                        .toStringAsFixed(
                                                                            2) +
                                                                    " %",
                                                                style: TextStyle(
                                                                    fontFamily: Constants.popins,
                                                                    decoration: TextDecoration.underline,
                                                                    color: Colors.white,
                                                                    // color: Constants.textColor,
                                                                    // fontWeight: FontWeight.w600,
                                                                    fontSize: 12),
                                                              )
                                                            : Text(
                                                                num.parse((data[index]['average'] ??
                                                                                0)
                                                                            .toString())
                                                                        .toStringAsFixed(
                                                                            2) +
                                                                    " %",
                                                                style:
                                                                    TextStyle(
                                                                        fontFamily:
                                                                            Constants
                                                                                .popins,
                                                                        decoration:
                                                                            TextDecoration
                                                                                .underline,
                                                                        color: Colors
                                                                            .red,
                                                                        // color: Constants.textColor,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w600,
                                                                        fontSize:
                                                                            12),
                                                              ),
                                                      ],
                                                    ),
                                                  ],
                                                )),
                                            // SizedBox(width: 10),
                                            Container(
                                              color: Colors.white,
                                              width: 1,
                                              height: h / 15,
                                            ),
                                            // SizedBox(width: 10),
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
                                                          "Water",
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  Constants
                                                                      .popins,
                                                              color:
                                                                  Colors.white,
                                                              // color: Constants.textColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 12),
                                                        ),
                                                        Text(
                                                          data[index]['water']
                                                              .toStringAsFixed(2),
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  Constants
                                                                      .popins,
                                                              decoration:
                                                                  TextDecoration
                                                                      .underline,
                                                              color:
                                                                  Colors.white,
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
                                                          "Batch",
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  Constants
                                                                      .popins,
                                                              color:
                                                                  Colors.white,
                                                              // color: Constants.textColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 12),
                                                        ),
                                                        Text(
                                                          data[index]['batch'].toStringAsFixed(2),
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  Constants
                                                                      .popins,
                                                              decoration:
                                                                  TextDecoration
                                                                      .underline,
                                                              color:
                                                                  Colors.white,
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
                                                          "Water/Batch",
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  Constants
                                                                      .popins,
                                                              color:
                                                                  Colors.white,
                                                              // color: Constants.textColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 12),
                                                        ),
                                                        Text(
                                                          (data[index][
                                                                      'waterbatch'].toStringAsFixed(2) ??
                                                                  0)
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  Constants
                                                                      .popins,
                                                              decoration:
                                                                  TextDecoration
                                                                      .underline,
                                                              color:
                                                                  Colors.white,
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
                                                          "%",
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  Constants
                                                                      .popins,
                                                              color:
                                                                  Colors.white,
                                                              // color: Constants.textColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 12),
                                                        ),
                                                        (num.parse((data[index]["weterper"] ??
                                                                            0)
                                                                        .toString()) <
                                                                    num.parse(data[index][
                                                                            "temp_percentage"]
                                                                        .toString()) &&
                                                                num.parse(((data[index]["weterper"]) ??
                                                                            0)
                                                                        .toString()) >
                                                                    num.parse(data[index]["temp_percentage"]
                                                                            .toString()) *
                                                                        -1)
                                                            ? Text(
                                                                num.parse((data[index]['weterper'] ??
                                                                                0)
                                                                            .toString())
                                                                        .toStringAsFixed(
                                                                            2) +
                                                                    " %",
                                                                style: TextStyle(
                                                                    fontFamily: Constants.popins,
                                                                    decoration: TextDecoration.underline,
                                                                    color: Colors.white,
                                                                    // color: Constants.textColor,
                                                                    // fontWeight: FontWeight.w600,
                                                                    fontSize: 12),
                                                              )
                                                            : Text(
                                                                num.parse((data[index]['weterper'] ??
                                                                                0)
                                                                            .toString())
                                                                        .toStringAsFixed(
                                                                            2) +
                                                                    " %",
                                                                style:
                                                                    TextStyle(
                                                                        fontFamily:
                                                                            Constants
                                                                                .popins,
                                                                        decoration:
                                                                            TextDecoration
                                                                                .underline,
                                                                        color: Colors
                                                                            .red,
                                                                        // color: Constants.textColor,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w600,
                                                                        fontSize:
                                                                            12),
                                                              ),
                                                      ],
                                                    ),
                                                  ],
                                                )),
                                          ],
                                        )
                                      ],
                                    ),
                                    children: <Widget>[
                                      ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemCount: sdata.length,
                                          itemBuilder: (context, sindex) {
                                            return (data[index]['categories'] ==
                                                    sdata[sindex]
                                                        ['CategoryName'])
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 5.0,
                                                            left: 5,
                                                            right: 5),
                                                    child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              const BorderRadius
                                                                      .all(
                                                                  Radius
                                                                      .circular(
                                                                          15.0)),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors.grey
                                                                  .withOpacity(
                                                                      0.2),
                                                              spreadRadius: 2,
                                                              blurRadius: 3,
                                                              offset: const Offset(
                                                                  0,
                                                                  3), // changes position of shadow
                                                            ),
                                                          ],
                                                        ),
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 2,
                                                                horizontal: 15),
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              // crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text(
                                                                  sdata[sindex][
                                                                          'SubCategoryName']
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                      fontFamily: Constants.popins,
                                                                      color: Colors.black,
                                                                      // fontWeight: FontWeight.w600,
                                                                      fontSize: 20),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                                height: 10),
                                                            // Container(color: Colors.blue,width: w,height: 1,),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Container(
                                                                    width:
                                                                        w / 3,
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Text(
                                                                              "EM",
                                                                              style: TextStyle(
                                                                                  fontFamily: Constants.popins,
                                                                                  color: Colors.black,
                                                                                  // color: Constants.textColor,
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontSize: 12),
                                                                            ),
                                                                            Text(
                                                                              sdata[sindex]['em'].toString(),
                                                                              style: TextStyle(
                                                                                  fontFamily: Constants.popins,
                                                                                  decoration: TextDecoration.underline,
                                                                                  color: Colors.black,
                                                                                  // color: Constants.textColor,
                                                                                  // fontWeight: FontWeight.w600,
                                                                                  fontSize: 12),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Text(
                                                                              "HM",
                                                                              style: TextStyle(
                                                                                  fontFamily: Constants.popins,
                                                                                  color: Colors.black,
                                                                                  // color: Constants.textColor,
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontSize: 12),
                                                                            ),
                                                                            Text(
                                                                              sdata[sindex]['hm'].toString(),
                                                                              style: TextStyle(
                                                                                  fontFamily: Constants.popins,
                                                                                  decoration: TextDecoration.underline,
                                                                                  color: Colors.black,
                                                                                  // color: Constants.textColor,
                                                                                  // fontWeight: FontWeight.w600,
                                                                                  fontSize: 12),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Text(
                                                                              "EM/HM",
                                                                              style: TextStyle(
                                                                                  fontFamily: Constants.popins,
                                                                                  color: Colors.black,
                                                                                  // color: Constants.textColor,
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontSize: 12),
                                                                            ),
                                                                            Text(
                                                                              (sdata[sindex]['dev'] ?? 0).toString(),
                                                                              style: TextStyle(
                                                                                  fontFamily: Constants.popins,
                                                                                  decoration: TextDecoration.underline,
                                                                                  color: Colors.black,
                                                                                  // color: Constants.textColor,
                                                                                  // fontWeight: FontWeight.w600,
                                                                                  fontSize: 12),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Text(
                                                                              "%",
                                                                              style: TextStyle(
                                                                                  fontFamily: Constants.popins,
                                                                                  color: Colors.black,
                                                                                  // color: Constants.textColor,
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontSize: 12),
                                                                            ),
                                                                            (num.parse((sdata[sindex]["average"] ?? 0).toString()) < num.parse((sdata[sindex]["em_hm_percentage"]).toString()) && num.parse((sdata[sindex]["average"] ?? 0).toString()) > num.parse((sdata[sindex]["em_hm_percentage"]).toString()) * -1)
                                                                                ? Text(
                                                                                    num.parse((sdata[sindex]['average'] ?? 0).toString()).toStringAsFixed(2) + " %",
                                                                                    style: TextStyle(
                                                                                        fontFamily: Constants.popins,
                                                                                        decoration: TextDecoration.underline,
                                                                                        color: Colors.black,
                                                                                        // color: Constants.textColor,
                                                                                        // fontWeight: FontWeight.w600,
                                                                                        fontSize: 12),
                                                                                  )
                                                                                : Text(
                                                                                    num.parse((sdata[sindex]['average'] ?? 0).toString()).toStringAsFixed(2) + " %",
                                                                                    style: TextStyle(fontFamily: Constants.popins, decoration: TextDecoration.underline, color: Colors.red, fontWeight: FontWeight.w600, fontSize: 12),
                                                                                  ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    )),
                                                                Container(
                                                                  color: Colors
                                                                      .black,
                                                                  width: 1,
                                                                  height:
                                                                      h / 15,
                                                                ),
                                                                Container(
                                                                    width:
                                                                        w / 3,
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Text(
                                                                              "Water",
                                                                              style: TextStyle(
                                                                                  fontFamily: Constants.popins,
                                                                                  color: Colors.black,
                                                                                  // color: Constants.textColor,
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontSize: 12),
                                                                            ),
                                                                            Text(
                                                                              sdata[sindex]['water'].toString(),
                                                                              style: TextStyle(
                                                                                  fontFamily: Constants.popins,
                                                                                  decoration: TextDecoration.underline,
                                                                                  color: Colors.black,
                                                                                  // color: Constants.textColor,
                                                                                  // fontWeight: FontWeight.w600,
                                                                                  fontSize: 12),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Text(
                                                                              "Batch",
                                                                              style: TextStyle(
                                                                                  fontFamily: Constants.popins,
                                                                                  color: Colors.black,
                                                                                  // color: Constants.textColor,
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontSize: 12),
                                                                            ),
                                                                            Text(
                                                                              sdata[sindex]['batch'].toString(),
                                                                              style: TextStyle(
                                                                                  fontFamily: Constants.popins,
                                                                                  decoration: TextDecoration.underline,
                                                                                  color: Colors.black,
                                                                                  // color: Constants.textColor,
                                                                                  // fontWeight: FontWeight.w600,
                                                                                  fontSize: 12),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Text(
                                                                              "Water/Batch",
                                                                              style: TextStyle(
                                                                                  fontFamily: Constants.popins,
                                                                                  color: Colors.black,
                                                                                  // color: Constants.textColor,
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontSize: 12),
                                                                            ),
                                                                            Text(
                                                                              num.parse((sdata[sindex]['waterbatch'] ?? 0).toString()).toStringAsFixed(2),
                                                                              style: TextStyle(
                                                                                  fontFamily: Constants.popins,
                                                                                  decoration: TextDecoration.underline,
                                                                                  color: Colors.black,
                                                                                  // color: Constants.textColor,
                                                                                  // fontWeight: FontWeight.w600,
                                                                                  fontSize: 12),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Text(
                                                                              "%",
                                                                              style: TextStyle(
                                                                                  fontFamily: Constants.popins,
                                                                                  color: Colors.black,
                                                                                  // color: Constants.textColor,
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontSize: 12),
                                                                            ),
                                                                            (num.parse((sdata[index]["weterper"] ?? 0).toString()) < num.parse((sdata[index]["temp_percentage"]).toString()) && num.parse((sdata[index]["weterper"] ?? 0).toString()) > num.parse((sdata[index]["temp_percentage"]).toString()) * -1)
                                                                                ? Text(
                                                                                    num.parse((sdata[sindex]['weterper'] ?? 0).toString()).toStringAsFixed(2) + " %",
                                                                                    style: TextStyle(
                                                                                        fontFamily: Constants.popins,
                                                                                        decoration: TextDecoration.underline,
                                                                                        color: Colors.black,
                                                                                        // color: Constants.textColor,
                                                                                        // fontWeight: FontWeight.w600,
                                                                                        fontSize: 12),
                                                                                  )
                                                                                : Text(
                                                                                    num.parse((sdata[sindex]['weterper'] ?? 0).toString()).toStringAsFixed(2) + " %",
                                                                                    style: TextStyle(
                                                                                        fontFamily: Constants.popins,
                                                                                        decoration: TextDecoration.underline,
                                                                                        color: Colors.red,
                                                                                        // color: Constants.textColor,
                                                                                        fontWeight: FontWeight.w600,
                                                                                        fontSize: 12),
                                                                                  ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    )),
                                                              ],
                                                            )
                                                          ],
                                                        )),
                                                  )
                                                : Container();
                                          }),
                                    ],
                                  ),
                                ),
                              );
                            }))
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
                        : Expanded(
                            child: ListView.builder(
                                itemCount: machinedata.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 5.0, left: 5, right: 5),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Constants.primaryColor,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(15.0)),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.2),
                                            spreadRadius: 2,
                                            blurRadius: 3,
                                            offset: const Offset(0,
                                                3), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 2, horizontal: 15),
                                      child: ExpansionTile(
                                        title: Container(),
                                        subtitle: Container(
                                          // color: Constants.secondaryColor,
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                // crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    machinedata[index]
                                                        ['categories'],
                                                    style: TextStyle(
                                                        fontFamily:
                                                            Constants.popins,
                                                        color: Colors.white,
                                                        // fontWeight: FontWeight.w600,
                                                        fontSize: 25),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10),
                                              // Container(color: Colors.blue,width: w,height: 1,),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
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
                                                                "EM",
                                                                style: TextStyle(
                                                                    fontFamily: Constants.popins,
                                                                    color: Colors.white,
                                                                    // color: Constants.textColor,
                                                                    fontWeight: FontWeight.w600,
                                                                    fontSize: 12),
                                                              ),
                                                              Text(
                                                                "0",
                                                                style: TextStyle(
                                                                    fontFamily: Constants.popins,
                                                                    decoration: TextDecoration.underline,
                                                                    color: Colors.white,
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
                                                                "HM",
                                                                style: TextStyle(
                                                                    fontFamily: Constants.popins,
                                                                    color: Colors.white,
                                                                    // color: Constants.textColor,
                                                                    fontWeight: FontWeight.w600,
                                                                    fontSize: 12),
                                                              ),
                                                              Text(
                                                                "0",
                                                                style: TextStyle(
                                                                    fontFamily: Constants.popins,
                                                                    decoration: TextDecoration.underline,
                                                                    color: Colors.white,
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
                                                                "EM/HM",
                                                                style: TextStyle(
                                                                    fontFamily: Constants.popins,
                                                                    color: Colors.white,
                                                                    // color: Constants.textColor,
                                                                    fontWeight: FontWeight.w600,
                                                                    fontSize: 12),
                                                              ),
                                                              Text(
                                                                "0.00",
                                                                style: TextStyle(
                                                                    fontFamily: Constants.popins,
                                                                    decoration: TextDecoration.underline,
                                                                    color: Colors.white,
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
                                                                "%",
                                                                style: TextStyle(
                                                                    fontFamily: Constants.popins,
                                                                    color: Colors.white,
                                                                    // color: Constants.textColor,
                                                                    fontWeight: FontWeight.w600,
                                                                    fontSize: 12),
                                                              ),
                                                              Text(
                                                                "0.00 %",
                                                                style: TextStyle(
                                                                    fontFamily: Constants.popins,
                                                                    decoration: TextDecoration.underline,
                                                                    color: Colors.white,
                                                                    // color: Constants.textColor,
                                                                    // fontWeight: FontWeight.w600,
                                                                    fontSize: 12),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      )),
                                                  // SizedBox(width: 10),
                                                  Container(
                                                    color: Colors.white,
                                                    width: 1,
                                                    height: h / 15,
                                                  ),
                                                  // SizedBox(width: 10),
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
                                                                "Water",
                                                                style: TextStyle(
                                                                    fontFamily: Constants.popins,
                                                                    color: Colors.white,
                                                                    // color: Constants.textColor,
                                                                    fontWeight: FontWeight.w600,
                                                                    fontSize: 12),
                                                              ),
                                                              Text(
                                                                "0",
                                                                style: TextStyle(
                                                                    fontFamily: Constants.popins,
                                                                    decoration: TextDecoration.underline,
                                                                    color: Colors.white,
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
                                                                "Batch",
                                                                style: TextStyle(
                                                                    fontFamily: Constants.popins,
                                                                    color: Colors.white,
                                                                    // color: Constants.textColor,
                                                                    fontWeight: FontWeight.w600,
                                                                    fontSize: 12),
                                                              ),
                                                              Text(
                                                                "0",
                                                                style: TextStyle(
                                                                    fontFamily: Constants.popins,
                                                                    decoration: TextDecoration.underline,
                                                                    color: Colors.white,
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
                                                                "Water/Batch",
                                                                style: TextStyle(
                                                                    fontFamily: Constants.popins,
                                                                    color: Colors.white,
                                                                    // color: Constants.textColor,
                                                                    fontWeight: FontWeight.w600,
                                                                    fontSize: 12),
                                                              ),
                                                              Text(
                                                                "0.00",
                                                                style: TextStyle(
                                                                    fontFamily: Constants.popins,
                                                                    decoration: TextDecoration.underline,
                                                                    color: Colors.white,
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
                                                                "%",
                                                                style: TextStyle(
                                                                    fontFamily: Constants.popins,
                                                                    color: Colors.white,
                                                                    // color: Constants.textColor,
                                                                    fontWeight: FontWeight.w600,
                                                                    fontSize: 12),
                                                              ),
                                                              Text(
                                                                "0.00 %",
                                                                style: TextStyle(
                                                                    fontFamily: Constants.popins,
                                                                    decoration: TextDecoration.underline,
                                                                    color: Colors.white,
                                                                    // color: Constants.textColor,
                                                                    // fontWeight: FontWeight.w600,
                                                                    fontSize: 12),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      )),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                        children: <Widget>[
                                          ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              itemCount: submachinedata.length,
                                              itemBuilder: (context, sindex) {
                                                return (machinedata[index]
                                                            ['id'] ==
                                                        submachinedata[sindex]
                                                            ['categories_id'])
                                                    ? Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                bottom: 5.0,
                                                                left: 5,
                                                                right: 5),
                                                        child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  const BorderRadius
                                                                          .all(
                                                                      Radius.circular(
                                                                          15.0)),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors
                                                                      .grey
                                                                      .withOpacity(
                                                                          0.2),
                                                                  spreadRadius:
                                                                      2,
                                                                  blurRadius: 3,
                                                                  offset: const Offset(
                                                                      0,
                                                                      3), // changes position of shadow
                                                                ),
                                                              ],
                                                            ),
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    vertical: 2,
                                                                    horizontal:
                                                                        15),
                                                            child: Column(
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  // crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Text(
                                                                      submachinedata[sindex]
                                                                              [
                                                                              'sub_name']
                                                                          .toString(),
                                                                      style: TextStyle(
                                                                          fontFamily: Constants.popins,
                                                                          color: Colors.black,
                                                                          // fontWeight: FontWeight.w600,
                                                                          fontSize: 20),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                    height: 10),
                                                                // Container(color: Colors.blue,width: w,height: 1,),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Container(
                                                                        width: w /
                                                                            3,
                                                                        child:
                                                                            Column(
                                                                          children: [
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: [
                                                                                Text(
                                                                                  "EM",
                                                                                  style: TextStyle(
                                                                                      fontFamily: Constants.popins,
                                                                                      color: Colors.black,
                                                                                      // color: Constants.textColor,
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontSize: 12),
                                                                                ),
                                                                                Text(
                                                                                  "0",
                                                                                  style: TextStyle(
                                                                                      fontFamily: Constants.popins,
                                                                                      decoration: TextDecoration.underline,
                                                                                      color: Colors.black,
                                                                                      // color: Constants.textColor,
                                                                                      // fontWeight: FontWeight.w600,
                                                                                      fontSize: 12),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: [
                                                                                Text(
                                                                                  "HM",
                                                                                  style: TextStyle(
                                                                                      fontFamily: Constants.popins,
                                                                                      color: Colors.black,
                                                                                      // color: Constants.textColor,
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontSize: 12),
                                                                                ),
                                                                                Text(
                                                                                  "0",
                                                                                  style: TextStyle(
                                                                                      fontFamily: Constants.popins,
                                                                                      decoration: TextDecoration.underline,
                                                                                      color: Colors.black,
                                                                                      // color: Constants.textColor,
                                                                                      // fontWeight: FontWeight.w600,
                                                                                      fontSize: 12),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: [
                                                                                Text(
                                                                                  "EM/HM",
                                                                                  style: TextStyle(
                                                                                      fontFamily: Constants.popins,
                                                                                      color: Colors.black,
                                                                                      // color: Constants.textColor,
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontSize: 12),
                                                                                ),
                                                                                Text(
                                                                                  "0.00",
                                                                                  style: TextStyle(
                                                                                      fontFamily: Constants.popins,
                                                                                      decoration: TextDecoration.underline,
                                                                                      color: Colors.black,
                                                                                      // color: Constants.textColor,
                                                                                      // fontWeight: FontWeight.w600,
                                                                                      fontSize: 12),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: [
                                                                                Text(
                                                                                  "%",
                                                                                  style: TextStyle(
                                                                                      fontFamily: Constants.popins,
                                                                                      color: Colors.black,
                                                                                      // color: Constants.textColor,
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontSize: 12),
                                                                                ),
                                                                                Text(
                                                                                  "0.00 %",
                                                                                  style: TextStyle(
                                                                                      fontFamily: Constants.popins,
                                                                                      decoration: TextDecoration.underline,
                                                                                      color: Colors.black,
                                                                                      // color: Constants.textColor,
                                                                                      // fontWeight: FontWeight.w600,
                                                                                      fontSize: 12),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        )),
                                                                    Container(
                                                                      color: Colors
                                                                          .black,
                                                                      width: 1,
                                                                      height:
                                                                          h / 15,
                                                                    ),
                                                                    Container(
                                                                        width: w /
                                                                            3,
                                                                        child:
                                                                            Column(
                                                                          children: [
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: [
                                                                                Text(
                                                                                  "Water",
                                                                                  style: TextStyle(
                                                                                      fontFamily: Constants.popins,
                                                                                      color: Colors.black,
                                                                                      // color: Constants.textColor,
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontSize: 12),
                                                                                ),
                                                                                Text(
                                                                                  "0",
                                                                                  style: TextStyle(
                                                                                      fontFamily: Constants.popins,
                                                                                      decoration: TextDecoration.underline,
                                                                                      color: Colors.black,
                                                                                      // color: Constants.textColor,
                                                                                      // fontWeight: FontWeight.w600,
                                                                                      fontSize: 12),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: [
                                                                                Text(
                                                                                  "Batch",
                                                                                  style: TextStyle(
                                                                                      fontFamily: Constants.popins,
                                                                                      color: Colors.black,
                                                                                      // color: Constants.textColor,
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontSize: 12),
                                                                                ),
                                                                                Text(
                                                                                  "0",
                                                                                  style: TextStyle(
                                                                                      fontFamily: Constants.popins,
                                                                                      decoration: TextDecoration.underline,
                                                                                      color: Colors.black,
                                                                                      // color: Constants.textColor,
                                                                                      // fontWeight: FontWeight.w600,
                                                                                      fontSize: 12),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: [
                                                                                Text(
                                                                                  "Water/Batch",
                                                                                  style: TextStyle(
                                                                                      fontFamily: Constants.popins,
                                                                                      color: Colors.black,
                                                                                      // color: Constants.textColor,
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontSize: 12),
                                                                                ),
                                                                                Text(
                                                                                  "0",
                                                                                  style: TextStyle(
                                                                                      fontFamily: Constants.popins,
                                                                                      decoration: TextDecoration.underline,
                                                                                      color: Colors.black,
                                                                                      // color: Constants.textColor,
                                                                                      // fontWeight: FontWeight.w600,
                                                                                      fontSize: 12),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: [
                                                                                Text(
                                                                                  "%",
                                                                                  style: TextStyle(
                                                                                      fontFamily: Constants.popins,
                                                                                      color: Colors.black,
                                                                                      // color: Constants.textColor,
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontSize: 12),
                                                                                ),
                                                                                Text(
                                                                                  "0.00 %",
                                                                                  style: TextStyle(
                                                                                      fontFamily: Constants.popins,
                                                                                      decoration: TextDecoration.underline,
                                                                                      color: Colors.black,
                                                                                      // color: Constants.textColor,
                                                                                      // fontWeight: FontWeight.w600,
                                                                                      fontSize: 12),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        )),
                                                                  ],
                                                                )
                                                              ],
                                                            )),
                                                      )
                                                    : Container();
                                              }),
                                        ],
                                      ),
                                    ),
                                  );
                                }))
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
