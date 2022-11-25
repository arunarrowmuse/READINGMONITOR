import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../constants.dart';

class ViewUtility extends StatefulWidget {
  const ViewUtility({Key? key}) : super(key: key);

  @override
  State<ViewUtility> createState() => _ViewUtilityState();
}

class _ViewUtilityState extends State<ViewUtility>
    with AutomaticKeepAliveClientMixin<ViewUtility> {
  bool isLoad = false;
  var data;
  var sdata;
  var machinedata;
  var submachinedata;
  String submachinedeviation = "";
  late SharedPreferences prefs;
  String? tokenvalue;
  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2050, 1));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        FetchUtilityReport();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    FetchUtilityReport();
  }

  void FetchUtilityReport() async {
    setState(() {
      isLoad = true;
    });
    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    final response = await http.get(
      Uri.parse(
          '${Constants.weblink}ViewReportUtilityDateSerchMainCategories/${selectedDate.toString().split(" ")[0]}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
    );
    if (response.statusCode == 200) {
      print("Main Machine");
      data = jsonDecode(response.body);
      print(data);
      if (data.length != 0) {
        FetchSubUtilityReport();
      } else {
        FetchUtilityMachineList();
      }
    } else {
      setState(() {
        isLoad = false;
      });
      Constants.showtoast("Error Fetching Data.");
    }
  }

  void FetchSubUtilityReport() async {
    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    final response = await http.get(
      Uri.parse(
          '${Constants.weblink}ViewReportUtilityDateSerch/${selectedDate.toString().split(" ")[0]}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
    );

    if (response.statusCode == 200) {
      print("Sub Machine");
      sdata = jsonDecode(response.body);
      print(sdata);
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

  void FetchUtilityMachineList() async {
    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    final response = await http.get(
      Uri.parse(
          '${Constants.weblink}GetUtilityLisiting/${selectedDate.toString().split(" ")[0]}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
    );

    if (response.statusCode == 200) {
      machinedata = jsonDecode(response.body);
      FetchSubMachineList();
    } else {
      setState(() {
        isLoad = false;
      });
      Constants.showtoast("Error Fetching Data this .");
    }
  }

  void FetchSubMachineList() async {
    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    final response = await http.get(
      Uri.parse(
          '${Constants.weblink}GetUtiltiSubCategoriesList/${selectedDate.toString().split(" ")[0]}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
    );
    if (response.statusCode == 200) {
      submachinedata = jsonDecode(response.body);
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
    return RefreshIndicator(
      onRefresh: () {
        return Future(() => FetchUtilityReport());
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
                                          Color(0xFFE1DFDD))),
                              child: Text(" SMS ",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontFamily: Constants.popins,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
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
                                          Color(0xFFE1DFDD))),
                              child: Text(" E-Mail ",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontFamily: Constants.popins,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
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
                                    subtitle: Container(
                                      // color: Constants.secondaryColor,
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            // crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                data[index]
                                                        ['uitility_categories']
                                                    .toString(),
                                                style: TextStyle(
                                                    fontFamily:
                                                        Constants.popins,
                                                    color: Colors.white,
                                                    // fontWeight: FontWeight.w600,
                                                    fontSize: 25),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
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
                                                                color: Colors
                                                                    .white,
                                                                // color: Constants.textColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 12),
                                                          ),
                                                          Text(
                                                            num.parse((data[index]
                                                                        ["mf"] ?? 0)
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
                                                                color: Colors
                                                                    .white,
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
                                                                color: Colors
                                                                    .white,
                                                                // color: Constants.textColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 12),
                                                          ),
                                                          Text(
                                                            num.parse((data[index]
                                                                            [
                                                                            "dev"] ??
                                                                        0)
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
                                                                color: Colors
                                                                    .white,
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
                                                height: h / 15,
                                              ),
                                              SizedBox(
                                                  width: w / 3,
                                                  child: Column(
                                                    children: [
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
                                                                color: Colors
                                                                    .white,
                                                                // color: Constants.textColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 12),
                                                          ),
                                                          Text(
                                                            num.parse(data[index]
                                                                        ["hm"]
                                                                    .toString())
                                                                .toStringAsFixed(
                                                                    2),
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    Constants
                                                                        .popins,
                                                                color: Colors
                                                                    .white,
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
                                                            "Deviation",
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    Constants
                                                                        .popins,
                                                                color: Colors
                                                                    .white,
                                                                // color: Constants.textColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 12),
                                                          ),
                                                          (num.parse((data[index]["average"] ??
                                                                              0)
                                                                          .toString()) <
                                                                      num.parse(data[index]
                                                                              [
                                                                              "devation"]
                                                                          .toString()) &&
                                                                  num.parse((data[index]["average"] ??
                                                                              0)
                                                                          .toString()) >
                                                                      num.parse(
                                                                              data[index]["devation"].toString()) *
                                                                          -1)
                                                              ? Text(
                                                                  num.parse((data[index]["average"] ?? 0)
                                                                              .toString())
                                                                          .toStringAsFixed(
                                                                              2) +
                                                                      " %",
                                                                  style: TextStyle(
                                                                      fontFamily: Constants.popins,
                                                                      color: Colors.white,
                                                                      decoration: TextDecoration.underline,
                                                                      // color: Constants.textColor,
                                                                      // fontWeight: FontWeight.w600,
                                                                      fontSize: 12),
                                                                )
                                                              : Text(
                                                                  num.parse((data[index]["average"] ?? 0)
                                                                              .toString())
                                                                          .toStringAsFixed(
                                                                              2) +
                                                                      " %",
                                                                  style: TextStyle(
                                                                      fontFamily: Constants.popins,
                                                                      color: Colors.red,
                                                                      decoration: TextDecoration.underline,
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
                                      ),
                                    ),
                                    children: <Widget>[
                                      ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemCount: sdata.length,
                                          itemBuilder: (context, sindex) {
                                            if (sdata[sindex]['dev'] == null) {
                                              submachinedeviation = "0";
                                            } else {
                                              submachinedeviation =
                                                  sdata[sindex]['dev']
                                                      .toString();
                                            }
                                            return (data[index][
                                                        'uitility_categories'] ==
                                                    sdata[sindex]
                                                        ['CategoryName'])
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 5.0,
                                                            left: 5,
                                                            right: 5),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            const BorderRadius
                                                                    .all(
                                                                Radius.circular(
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
                                                      padding: const EdgeInsets
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
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              SizedBox(
                                                                  width: w / 3,
                                                                  child: Column(
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
                                                                            (sdata[sindex]["mfem"]??0).toString(),
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
                                                                            num.parse((sdata[sindex]["average"] ?? 0).toString()).toStringAsFixed(2),
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
                                                                color: Constants
                                                                    .secondaryColor
                                                                    .withOpacity(
                                                                        0.2),
                                                                width: 1,
                                                                height: h / 15,
                                                              ),
                                                              SizedBox(
                                                                  width: w / 3,
                                                                  child: Column(
                                                                    children: [
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
                                                                            sdata[sindex]["hm"].toString(),
                                                                            style: TextStyle(
                                                                                fontFamily: Constants.popins,
                                                                                color: Colors.black,
                                                                                decoration: TextDecoration.underline,
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
                                                                            "Deviation",
                                                                            style: TextStyle(
                                                                                fontFamily: Constants.popins,
                                                                                color: Colors.black,
                                                                                // color: Constants.textColor,
                                                                                fontWeight: FontWeight.w600,
                                                                                fontSize: 12),
                                                                          ),
                                                                          (num.parse(submachinedeviation.toString()) < num.parse((sdata[index]["deviation"]??0).toString()) && num.parse(submachinedeviation.toString()) > num.parse((sdata[index]["deviation"]??0).toString()) * -1)
                                                                              ? Text(
                                                                                  num.parse((sdata[sindex]["dev"] ?? 0).toString()).toStringAsFixed(2) + " %",
                                                                                  style: TextStyle(
                                                                                      fontFamily: Constants.popins,
                                                                                      color: Colors.black,
                                                                                      decoration: TextDecoration.underline,
                                                                                      // color: Constants.textColor,
                                                                                      // fontWeight: FontWeight.w600,
                                                                                      fontSize: 12),
                                                                                )
                                                                              : Text(
                                                                                  num.parse((sdata[sindex]["dev"] ?? 0).toString()).toStringAsFixed(2) + " %",
                                                                                  style: TextStyle(
                                                                                      fontFamily: Constants.popins,
                                                                                      color: Colors.red,
                                                                                      decoration: TextDecoration.underline,
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
                                                      ),
                                                    ),
                                                  )
                                                : Container();
                                          }),
                                    ],
                                  ),
                                ),
                              );
                            }),
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
                                        subtitle: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              // crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  machinedata[index][
                                                          'uitility_categories']
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontFamily:
                                                          Constants.popins,
                                                      color: Colors.white,
                                                      // fontWeight: FontWeight.w600,
                                                      fontSize: 25),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                SizedBox(
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
                                                                  color: Colors
                                                                      .white,
                                                                  // color: Constants.textColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 12),
                                                            ),
                                                            Text(
                                                              "0",
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      Constants
                                                                          .popins,
                                                                  decoration:
                                                                      TextDecoration
                                                                          .underline,
                                                                  color: Colors
                                                                      .white,
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
                                                                  color: Colors
                                                                      .white,
                                                                  // color: Constants.textColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 12),
                                                            ),
                                                            Text(
                                                              "0.00",
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      Constants
                                                                          .popins,
                                                                  decoration:
                                                                      TextDecoration
                                                                          .underline,
                                                                  color: Colors
                                                                      .white,
                                                                  // color: Constants.textColor,
                                                                  // fontWeight: FontWeight.w600,
                                                                  fontSize: 12),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    )),
                                                Container(
                                                  color: Constants
                                                      .secondaryColor
                                                      .withOpacity(0.2),
                                                  width: 1,
                                                  height: h / 15,
                                                ),
                                                SizedBox(
                                                    width: w / 3,
                                                    child: Column(
                                                      children: [
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
                                                                  color: Colors
                                                                      .white,
                                                                  // color: Constants.textColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 12),
                                                            ),
                                                            Text(
                                                              "0",
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      Constants
                                                                          .popins,
                                                                  color: Colors
                                                                      .white,
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
                                                              "Deviation",
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      Constants
                                                                          .popins,
                                                                  color: Colors
                                                                      .white,
                                                                  // color: Constants.textColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 12),
                                                            ),
                                                            Text(
                                                              "0.00 %",
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      Constants
                                                                          .popins,
                                                                  color: Colors
                                                                      .white,
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
                                              ],
                                            )
                                          ],
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
                                                        submachinedata[sindex][
                                                            'uitility_categories_id'])
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
                                                            color: Colors.white,
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
                                                                            'uilitysubc_name']
                                                                        .toString(),
                                                                    style: TextStyle(
                                                                        fontFamily: Constants.popins,
                                                                        color: Colors.black,
                                                                        // fontWeight: FontWeight.w600,
                                                                        fontSize: 20),
                                                                  ),
                                                                ],
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  SizedBox(
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
                                                                        ],
                                                                      )),
                                                                  Container(
                                                                    color: Constants
                                                                        .secondaryColor
                                                                        .withOpacity(
                                                                            0.2),
                                                                    width: 1,
                                                                    height:
                                                                        h / 15,
                                                                  ),
                                                                  SizedBox(
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
                                                                                    color: Colors.black,
                                                                                    decoration: TextDecoration.underline,
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
                                                                                "Deviation",
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
                                                                                    color: Colors.black,
                                                                                    decoration: TextDecoration.underline,
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
                                                      )
                                                    : Container();
                                              }),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
