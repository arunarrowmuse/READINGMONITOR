import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../constants.dart';

class ViewFlueGas extends StatefulWidget {
  const ViewFlueGas({Key? key}) : super(key: key);

  @override
  State<ViewFlueGas> createState() => _ViewFlueGasState();
}

class _ViewFlueGasState extends State<ViewFlueGas> {
  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    DateTime now = DateTime.now();

    return Scaffold(
      body: Column(
        children: [
          // const SizedBox(height: 20),
          DefaultTabController(
              length: 2, // length of tabs
              initialIndex: 0,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      color: Constants.primaryColor,
                      child: TabBar(
                        indicatorColor: Colors.red,
                        // labelColor: Colors.green,
                        // unselectedLabelColor: Colors.black,
                        tabs: [
                          Tab(
                            child: Text(
                              "Steam Boiler",
                              style: TextStyle(
                                  fontFamily: Constants.popins,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15),
                            ),
                          ),
                          Tab(
                            child: Text(
                              "Thermopack",
                              style: TextStyle(
                                  fontFamily: Constants.popins,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                        height: h / 1.6, //height of TabBarView
                        decoration: const BoxDecoration(
                            border: Border(
                                top: BorderSide(
                                    color: Colors.grey, width: 0.5))),
                        child: const TabBarView(children: <Widget>[
                          ViewFlueSteamBoiler(),
                          ViewFlueThermoPack(),
                        ]))
                  ])),
        ],
      ),
    );
  }
}

class ViewFlueSteamBoiler extends StatefulWidget {
  const ViewFlueSteamBoiler({Key? key}) : super(key: key);

  @override
  State<ViewFlueSteamBoiler> createState() => _ViewFlueSteamBoilerState();
}

class _ViewFlueSteamBoilerState extends State<ViewFlueSteamBoiler>
    with AutomaticKeepAliveClientMixin<ViewFlueSteamBoiler> {
  DateTime selectedDate = DateTime.now();
  bool isLoad = false;
  var data;
  var machinedata;
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
        FetchFlueSteamReport();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    FetchFlueSteamReport();
  }

  void FetchFlueSteamReport() async {
    setState(() {
      isLoad = true;
    });
    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    final response = await http.get(
      Uri.parse(
          '${Constants.weblink}ViewReportFlueGasSteamBolierDateSearch/${selectedDate.toString().split(" ")[0]}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      print("data------------------------------");
      // print(response.body);
      data = jsonDecode(response.body);
      print(data);
      if (data.length == 0) {
        fetchSteamMachineList();
      } else {
        setState(() {
          isLoad = false;
        });
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

  void fetchSteamMachineList() async {
    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    final response = await http.get(
      Uri.parse('${Constants.weblink}GetFlueGasSteamBolierListingData/${selectedDate.toString().split(" ")[0]}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
    );
    if (response.statusCode == 200) {
      machinedata = jsonDecode(response.body);
      print(machinedata);
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
    var formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return RefreshIndicator(
      onRefresh: () {
        return Future(() => FetchFlueSteamReport());
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(left: 18.0, right: 18),
          child: Column(
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
                      height: 300,
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
                                            data[index]['CategoryName']
                                                .toString(),
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
                                                        "Value",
                                                        style: TextStyle(
                                                            fontFamily:
                                                                Constants
                                                                    .popins,
                                                            // color: Constants.textColor,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 12),
                                                      ),
                                                      Text(
                                                        (data[index]['value'] ??
                                                                0)
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontFamily:
                                                                Constants
                                                                    .popins,
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
                                                        "Temp",
                                                        style: TextStyle(
                                                            fontFamily:
                                                                Constants
                                                                    .popins,
                                                            // color: Constants.textColor,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 12),
                                                      ),
                                                      Text(
                                                        (data[index][
                                                                    'temperature'] ??
                                                                0)
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontFamily:
                                                                Constants
                                                                    .popins,
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
                                                        "Value %",
                                                        style: TextStyle(
                                                            fontFamily:
                                                                Constants
                                                                    .popins,
                                                            // color: Constants.textColor,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 12),
                                                      ),
                                                      (num.parse((data[index][
                                                                          "value_pr"] ??
                                                                      0).toString()) <
                                                                  num.parse((data[index][
                                                                      "deviation"]).toString()) &&
                                                              num.parse((data[index]
                                                                          [
                                                                          "value_pr"] ??
                                                                      0).toString()) >
                                                                  num.parse((data[index][
                                                                  "deviation"]).toString()) *
                                                                      -1)
                                                          ? Text(
                                                              num.parse((data[index]['value_pr'] ??
                                                                          0).toString())
                                                                      .toStringAsFixed(
                                                                          2) +
                                                                  " %",
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      Constants
                                                                          .popins,
                                                                  decoration:
                                                                      TextDecoration
                                                                          .underline,
                                                                  // color: Constants.textColor,
                                                                  // fontWeight: FontWeight.w600,
                                                                  fontSize: 12),
                                                            )
                                                          : Text(
                                                              num.parse((data[index]
                                                                              [
                                                                              'value_pr'] ??
                                                                          0).toString())
                                                                      .toStringAsFixed(
                                                                          2) +
                                                                  " %",
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      Constants
                                                                          .popins,
                                                                  decoration:
                                                                      TextDecoration
                                                                          .underline,
                                                                  color: Colors
                                                                      .red,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
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
                                                        "Temp %",
                                                        style: TextStyle(
                                                            fontFamily:
                                                                Constants
                                                                    .popins,
                                                            // color: Constants.textColor,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 12),
                                                      ),
                                                      (num.parse((data[index][
                                                                          "temperature_pr"] ??
                                                                      0).toString()) <
                                                                  num.parse((data[index][
                                                                      "temperature_deviation"]).toString()) &&
                                                              num.parse((data[index]
                                                                          [
                                                                          "temperature_pr"] ??
                                                                      0).toString()) >
                                                                  num.parse((data[index][
                                                                  "temperature_deviation"]).toString()) *
                                                                      -1)
                                                          ? Text(
                                                              num.parse((data[index]
                                                                              [
                                                                              'temperature_pr'] ??
                                                                          0).toString())
                                                                      .toStringAsFixed(
                                                                          2) +
                                                                  " %",
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      Constants
                                                                          .popins,
                                                                  decoration:
                                                                      TextDecoration
                                                                          .underline,
                                                                  // color: Constants.textColor,
                                                                  // fontWeight: FontWeight.w600,
                                                                  fontSize: 12),
                                                            )
                                                          : Text(
                                                              num.parse((data[index]
                                                                              [
                                                                              'temperature_pr'] ??
                                                                          0).toString())
                                                                      .toStringAsFixed(
                                                                          2) +
                                                                  " %",
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      Constants
                                                                          .popins,
                                                                  decoration:
                                                                      TextDecoration
                                                                          .underline,
                                                                  color: Colors
                                                                      .red,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
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
                              );
                            },
                          ),
                        )
                      : (machinedata.length == 0)
                          ? Container(
                              height: 200,
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
                                  // final item = titles[index];
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
                                            offset: const Offset(0,
                                                3), // changes position of shadow
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
                                                machinedata[index]
                                                    ['machine_name'],
                                                style: TextStyle(
                                                    fontFamily:
                                                        Constants.popins,
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
                                                            "Value",
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    Constants
                                                                        .popins,
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
                                                            "Temp",
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    Constants
                                                                        .popins,
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
                                                            "Value %",
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    Constants
                                                                        .popins,
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
                                                            "Temp %",
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    Constants
                                                                        .popins,
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
                                    ),
                                  );
                                },
                              ),
                            )
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ViewFlueThermoPack extends StatefulWidget {
  const ViewFlueThermoPack({Key? key}) : super(key: key);

  @override
  State<ViewFlueThermoPack> createState() => _ViewFlueThermoPackState();
}

class _ViewFlueThermoPackState extends State<ViewFlueThermoPack>
    with AutomaticKeepAliveClientMixin<ViewFlueThermoPack> {
  DateTime selectedDate = DateTime.now();
  bool isLoad = false;
  var data;
  var machinedata;
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
        FetchFlueThermoReport();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    FetchFlueThermoReport();
  }

  void FetchFlueThermoReport() async {
    setState(() {
      isLoad = true;
    });
    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    final response = await http.get(
      Uri.parse(
          '${Constants.weblink}ViewReportFlueGasThermopackDateSearch/${selectedDate.toString().split(" ")[0]}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      // print(response.body);
      data = jsonDecode(response.body);
      print(data);
      if (data.length == 0) {
        fetchThermoMachineList();
      } else {
        setState(() {
          isLoad = false;
        });
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

  void fetchThermoMachineList() async {
    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    final response = await http.get(
      Uri.parse('${Constants.weblink}GetFlueGasThermoPackListingData/${selectedDate.toString().split(" ")[0]}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
    );
    if (response.statusCode == 200) {
      machinedata = jsonDecode(response.body);
      print(machinedata);
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
    var formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return RefreshIndicator(
      onRefresh: () {
        return Future(() => FetchFlueThermoReport());
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(left: 18.0, right: 18),
          child: Column(
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
                      height: 300,
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
                              // final item = titles[index];
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
                                            data[index]['CategoryName']
                                                .toString(),
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
                                                        "Value",
                                                        style: TextStyle(
                                                            fontFamily:
                                                                Constants
                                                                    .popins,
                                                            // color: Constants.textColor,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 12),
                                                      ),
                                                      Text(
                                                        data[index]['value']
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontFamily:
                                                                Constants
                                                                    .popins,
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
                                                        "Temp",
                                                        style: TextStyle(
                                                            fontFamily:
                                                                Constants
                                                                    .popins,
                                                            // color: Constants.textColor,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 12),
                                                      ),
                                                      Text(
                                                        data[index]
                                                                ['temperature']
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontFamily:
                                                                Constants
                                                                    .popins,
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
                                                        "Value %",
                                                        style: TextStyle(
                                                            fontFamily:
                                                                Constants
                                                                    .popins,
                                                            // color: Constants.textColor,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 12),
                                                      ),
                                                      (num.parse((data[index][
                                                                          "value_pr"] ??
                                                                      0).toString()) <
                                                                  num.parse((data[index][
                                                                      "deviation"]).toString()) &&
                                                              num.parse((data[index]
                                                                          [
                                                                          "value_pr"] ??
                                                                      0).toString()) >
                                                                  num.parse((data[index][
                                                                  "deviation"]).toString()) *
                                                                      -1)
                                                          ? Text(
                                                              num.parse((data[index]
                                                                              [
                                                                              'value_pr'] ??
                                                                          0).toString())
                                                                      .toStringAsFixed(
                                                                          2) +
                                                                  " %",
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      Constants
                                                                          .popins,
                                                                  decoration:
                                                                      TextDecoration
                                                                          .underline,
                                                                  // color: Constants.textColor,
                                                                  // fontWeight: FontWeight.w600,
                                                                  fontSize: 12),
                                                            )
                                                          : Text(
                                                              num.parse((data[index]
                                                                              [
                                                                              'value_pr'] ??
                                                                          0).toString())
                                                                      .toStringAsFixed(
                                                                          2) +
                                                                  " %",
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      Constants
                                                                          .popins,
                                                                  decoration:
                                                                      TextDecoration
                                                                          .underline,
                                                                  color: Colors
                                                                      .red,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
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
                                                        "Temp %",
                                                        style: TextStyle(
                                                            fontFamily:
                                                                Constants
                                                                    .popins,
                                                            // color: Constants.textColor,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 12),
                                                      ),
                                                      (num.parse((data[index][
                                                                          "temperature_pr"] ??
                                                                      0).toString()) <
                                                                  num.parse((data[index][
                                                                      "temperature_deviation"]).toString()) &&
                                                              num.parse((data[index]
                                                                          [
                                                                          "temperature_pr"] ??
                                                                      0).toString()) >
                                                                  num.parse((data[index][
                                                                  "temperature_deviation"]).toString()) *
                                                                      -1)
                                                          ? Text(
                                                              num.parse((data[index]
                                                                              [
                                                                              'temperature_pr'] ??
                                                                          0).toString())
                                                                      .toStringAsFixed(
                                                                          2) +
                                                                  " %",
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      Constants
                                                                          .popins,
                                                                  decoration:
                                                                      TextDecoration
                                                                          .underline,
                                                                  // color: Constants.textColor,
                                                                  // fontWeight: FontWeight.w600,
                                                                  fontSize: 12),
                                                            )
                                                          : Text(
                                                              num.parse((data[index]
                                                                              [
                                                                              'temperature_pr'] ??
                                                                          0).toString())
                                                                      .toStringAsFixed(
                                                                          2) +
                                                                  " %",
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      Constants
                                                                          .popins,
                                                                  decoration:
                                                                      TextDecoration
                                                                          .underline,
                                                                  color: Colors
                                                                      .red,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
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
                              );
                            },
                          ),
                        )
                      : (machinedata.length == 0)
                          ? Container(
                              height: 200,
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
                                  // final item = titles[index];
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
                                            offset: const Offset(0,
                                                3), // changes position of shadow
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
                                                machinedata[index]
                                                        ['machine_name']
                                                    .toString(),
                                                style: TextStyle(
                                                    fontFamily:
                                                        Constants.popins,
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
                                                            "Value",
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    Constants
                                                                        .popins,
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
                                                            "Temp",
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    Constants
                                                                        .popins,
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
                                                            "Value %",
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    Constants
                                                                        .popins,
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
                                                            "Temp %",
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    Constants
                                                                        .popins,
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
                                  );
                                },
                              ),
                            )
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
