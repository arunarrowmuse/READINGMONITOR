import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';
import 'package:http/http.dart' as http;

class ViewManoMeter extends StatefulWidget {
  const ViewManoMeter({Key? key}) : super(key: key);

  @override
  State<ViewManoMeter> createState() => _ViewManoMeterState();
}

class _ViewManoMeterState extends State<ViewManoMeter> {
  DateTime selectedDate = DateTime.now();
  bool isLoad = false;
  var data;
  late SharedPreferences prefs;
  String? tokenvalue;

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Column(
        children: [
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
                        height: h / 1.5, //height of TabBarView
                        decoration: BoxDecoration(
                            border: Border(
                                top: BorderSide(
                                    color: Colors.grey, width: 0.5))),
                        child: TabBarView(children: <Widget>[
                          ViewManoSteam(),
                          ViewManoThermo(),
                        ]))
                  ])),
        ],
      ),
    );
  }
}

class ViewManoSteam extends StatefulWidget {
  const ViewManoSteam({Key? key}) : super(key: key);

  @override
  State<ViewManoSteam> createState() => _ViewManoSteamState();
}

class _ViewManoSteamState extends State<ViewManoSteam> with AutomaticKeepAliveClientMixin<ViewManoSteam> {
  DateTime selectedDate = DateTime.now();
  bool isLoad = false;
  var data;
  var machinedata;
  late SharedPreferences prefs;
  String? tokenvalue;
  String idfan = "0";
  String fdfan = "0";
  String coal = "0";
  String aphv = "0";
  String apht = "0";

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2050, 1));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        FetchManoSteamReport();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    FetchManoSteamReport();
  }

  void FetchManoSteamReport() async {
    setState(() {
      isLoad = true;
    });
    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    final response = await http.get(
      Uri.parse(
          '${Constants.weblink}ViewReportMenoMeterSteambolierDateSearch/${selectedDate.toString().split(" ")[0]}'),
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
      if (data.length != 0) {
        idfan = data[0]['id_fan'];
        fdfan = data[0]['fd_fan'];
        coal = data[0]['coal_used'];
        aphv = data[0]['aph_value'];
        apht = data[0]['aph_temperature'];
        setState(() {
          isLoad = false;
        });
      } else {
        FetchManoSteamMachineList();
      }

    } else {
      setState(() {
        isLoad = false;
      });

      Constants.showtoast("Error Fetching Data.");
    }
  }

  void FetchManoSteamMachineList() async {

    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    final response = await http.get(
      Uri.parse('${Constants.weblink}ManoMeterSteamBoilerLisiting/${selectedDate.toString().split(" ")[0]}'),
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
    return (isLoad == true)
        ? SizedBox(
            height: 500,
            child: Center(
              child: CircularProgressIndicator(
                color: Constants.primaryColor,
              ),
            ),
          )
        : RefreshIndicator(
      onRefresh: (){
        return Future(() => FetchManoSteamReport());
      },
          child: (data.length != 0)?Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
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
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        height: 30,
                        width: w / 3.2,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            border: Border.all(color: Colors.grey)),
                        child: Center(
                          child: Text(
                            "ID FAN(Hz)",
                            style: TextStyle(
                              // color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              fontFamily: Constants.popins,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 30,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            border: Border.all(color: Colors.grey)),
                        width: w / 3.2,
                        child: Center(
                          child: Text(
                            "FD FAN(Hz)",
                            style: TextStyle(
                              // color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              fontFamily: Constants.popins,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 30,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            border: Border.all(color: Colors.grey)),
                        width: w / 3.2,
                        child: Center(
                          child: Text(
                            "COAL USED",
                            style: TextStyle(
                              // color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              fontFamily: Constants.popins,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        height: 30,
                        width: w / 3.2,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            border: Border.all(color: Colors.grey)),
                        child: Center(
                          child: Text(
                            idfan.toString(),
                            style: TextStyle(
                              // color: Colors.white,
                              fontSize: 14,
                              fontFamily: Constants.popins,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 30,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            border: Border.all(color: Colors.grey)),
                        width: w / 3.2,
                        child: Center(
                          child: Text(
                            fdfan.toString(),
                            style: TextStyle(
                              // color: Colors.white,
                              fontSize: 14,
                              fontFamily: Constants.popins,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 30,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            border: Border.all(color: Colors.grey)),
                        width: w / 3.2,
                        child: Center(
                          child: Text(
                            coal.toString(),
                            style: TextStyle(
                              // color: Colors.white,
                              fontSize: 14,
                              fontFamily: Constants.popins,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        height: 60,
                        width: w / 2,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            border: Border.all(color: Colors.grey)),
                        child: Center(
                          child: Text(
                            "APH TO FURNANCE",
                            style: TextStyle(
                              // color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              fontFamily: Constants.popins,
                            ),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Container(
                            height: 30,
                            decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                border: Border.all(color: Colors.grey)),
                            width: w / 5,
                            child: Center(
                              child: Text(
                                "Value",
                                style: TextStyle(
                                  // color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  fontFamily: Constants.popins,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 30,
                            decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                border: Border.all(color: Colors.grey)),
                            width: w / 5,
                            child: Center(
                              child: Text(
                                aphv.toString(),
                                style: TextStyle(
                                  // color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: Constants.popins,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            height: 30,
                            decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                border: Border.all(color: Colors.grey)),
                            width: w / 4.2,
                            child: Center(
                              child: Text(
                                "Temperature",
                                style: TextStyle(
                                  // color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  fontFamily: Constants.popins,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 30,
                            decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                border: Border.all(color: Colors.grey)),
                            width: w / 4.2,
                            child: Center(
                              child: Text(
                                apht.toString(),
                                style: TextStyle(
                                  // color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: Constants.popins,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 15.0, right: 15.0),
                                child: Column(
                                  children: [
                                    SizedBox(height: 25),
                                    Container(
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
                                          vertical: 5, horizontal: 10),
                                      child: Column(
                                        children: [
                                          Text(
                                            data[index]['steam_boiler'].toString(),
                                            style: TextStyle(
                                                fontFamily: Constants.popins,
                                                color: Constants.textColor,
                                                // fontWeight: FontWeight.w600,
                                                fontSize: 20),
                                          ),
                                          // SizedBox(height: 10),
                                          // Container(color: Colors.blue,width: w,height: 1,),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text("Value"),
                                              Container(
                                                height: 35,
                                                width: 80,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(12)),
                                                    color: Colors.grey.shade200,
                                                    border: Border.all(
                                                        color: Constants
                                                            .primaryColor)),
                                                child: Center(
                                                  child: Text(num.parse((data[index]['value']??0).toString()).toStringAsFixed(2)),
                                                ),
                                              ),
                                              Container(
                                                color: Constants.secondaryColor
                                                    .withOpacity(0.2),
                                                width: 1,
                                                height: h / 15,
                                              ),
                                              Text("Temp"),
                                              Container(
                                                height: 35,
                                                width: 80,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(12)),
                                                    color: Colors.grey.shade200,
                                                    border: Border.all(
                                                        color: Constants
                                                            .primaryColor)),
                                                child: Center(
                                                  child: Text(num.parse((data[index]['temperature']??0).toString()).toStringAsFixed(2)),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }),
                  ),
                ],
              ),
            ):Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
          children: [
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
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  height: 30,
                  width: w / 3.2,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      border: Border.all(color: Colors.grey)),
                  child: Center(
                    child: Text(
                      "ID FAN(Hz)",
                      style: TextStyle(
                        // color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        fontFamily: Constants.popins,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 30,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      border: Border.all(color: Colors.grey)),
                  width: w / 3.2,
                  child: Center(
                    child: Text(
                      "FD FAN(Hz)",
                      style: TextStyle(
                        // color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        fontFamily: Constants.popins,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 30,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      border: Border.all(color: Colors.grey)),
                  width: w / 3.2,
                  child: Center(
                    child: Text(
                      "COAL USED",
                      style: TextStyle(
                        // color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        fontFamily: Constants.popins,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  height: 30,
                  width: w / 3.2,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      border: Border.all(color: Colors.grey)),
                  child: Center(
                    child: Text(
                      idfan.toString(),
                      style: TextStyle(
                        // color: Colors.white,
                        fontSize: 14,
                        fontFamily: Constants.popins,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 30,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      border: Border.all(color: Colors.grey)),
                  width: w / 3.2,
                  child: Center(
                    child: Text(
                      fdfan.toString(),
                      style: TextStyle(
                        // color: Colors.white,
                        fontSize: 14,
                        fontFamily: Constants.popins,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 30,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      border: Border.all(color: Colors.grey)),
                  width: w / 3.2,
                  child: Center(
                    child: Text(
                      coal.toString(),
                      style: TextStyle(
                        // color: Colors.white,
                        fontSize: 14,
                        fontFamily: Constants.popins,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  height: 60,
                  width: w / 2,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      border: Border.all(color: Colors.grey)),
                  child: Center(
                    child: Text(
                      "APH TO FURNANCE",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        // color: Colors.white,
                        fontSize: 14,
                        fontFamily: Constants.popins,
                      ),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Container(
                      height: 30,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          border: Border.all(color: Colors.grey)),
                      width: w / 5,
                      child: Center(
                        child: Text(
                          "Value",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            // color: Colors.white,
                            fontSize: 14,
                            fontFamily: Constants.popins,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 30,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          border: Border.all(color: Colors.grey)),
                      width: w / 5,
                      child: Center(
                        child: Text(
                          aphv.toString(),
                          style: TextStyle(
                            // color: Colors.white,
                            fontSize: 14,
                            fontFamily: Constants.popins,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Container(
                      height: 30,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          border: Border.all(color: Colors.grey)),
                      width: w / 4.2,
                      child: Center(
                        child: Text(
                          "Temperature",
                          style: TextStyle(
                            // color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            fontFamily: Constants.popins,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 30,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          border: Border.all(color: Colors.grey)),
                      width: w / 4.2,
                      child: Center(
                        child: Text(
                          apht.toString(),
                          style: TextStyle(
                            // color: Colors.white,
                            fontSize: 14,
                            fontFamily: Constants.popins,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            (machinedata.length == 0)
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
                :Expanded(
              child: ListView.builder(
                  itemCount: machinedata.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Stack(
                      children: [
                        // Transform.rotate(
                        //   child: Center(
                        //     child: Text(
                        //       "<<",
                        //       style: TextStyle(fontSize: 40),
                        //     ),
                        //   ),
                        //   angle: -math.pi/2,
                        // ),
                        // Center(
                        //   child: Container(
                        //     width: 5,
                        //     height: 60,
                        //     color: Constants.secondaryColor, //Text
                        //   ),
                        // ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 15.0, right: 15.0),
                          child: Column(
                            children: [
                              SizedBox(height: 25),
                              Container(
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
                                    vertical: 5, horizontal: 10),
                                child: Column(
                                  children: [
                                    Text(
                                      machinedata[index]['steam_boiler'],
                                      style: TextStyle(
                                          fontFamily: Constants.popins,
                                          color: Constants.textColor,
                                          // fontWeight: FontWeight.w600,
                                          fontSize: 20),
                                    ),
                                    // SizedBox(height: 10),
                                    // Container(color: Colors.blue,width: w,height: 1,),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Value"),
                                        Container(
                                          height: 35,
                                          width: 80,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.all(
                                                  Radius.circular(12)),
                                              color: Colors.grey.shade200,
                                              border: Border.all(
                                                  color: Constants
                                                      .primaryColor)),
                                          child: Center(
                                            child: Text("0"),
                                          ),
                                        ),
                                        Container(
                                          color: Constants.secondaryColor
                                              .withOpacity(0.2),
                                          width: 1,
                                          height: h / 15,
                                        ),
                                        Text("Temp"),
                                        Container(
                                          height: 35,
                                          width: 80,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.all(
                                                  Radius.circular(12)),
                                              color: Colors.grey.shade200,
                                              border: Border.all(
                                                  color: Constants
                                                      .primaryColor)),
                                          child: Center(
                                            child: Text("0"),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

class ViewManoThermo extends StatefulWidget {
  const ViewManoThermo({Key? key}) : super(key: key);

  @override
  State<ViewManoThermo> createState() => _ViewManoThermoState();
}

class _ViewManoThermoState extends State<ViewManoThermo> with AutomaticKeepAliveClientMixin<ViewManoThermo>{
  DateTime selectedDate = DateTime.now();
  bool isLoad = false;
  var data;
  var machinedata;
  late SharedPreferences prefs;
  String? tokenvalue;
  String idfan = "0";
  String fdfan = "0";
  String coal = "0";
  String aphv = "0";
  String apht = "0";

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2050, 1));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        FetchManoThermoReport();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    FetchManoThermoReport();
  }

  void FetchManoThermoReport() async {
    setState(() {
      isLoad = true;
    });
    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    final response = await http.get(
      Uri.parse(
          '${Constants.weblink}ViewReportMenoMeterDateSearch/${selectedDate.toString().split(" ")[0]}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      print("Machine Data");
      // print(response.body);
      data = jsonDecode(response.body);
      print(data);
      if (data.length != 0) {
        idfan = data[0]['id_fan'];
        fdfan = data[0]['fd_fan'];
        coal = data[0]['coal_used'];
        aphv = data[0]['aph_value'];
        apht = data[0]['aph_temperature'];
        setState(() {
          isLoad = false;
        });
      } else {
        FetchManoThermoMachineList();
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

  void FetchManoThermoMachineList() async {
    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    final response = await http.get(
      Uri.parse('${Constants.weblink}ManoMeterThermopackLisiting/${selectedDate.toString().split(" ")[0]}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
    );
    if (response.statusCode == 200) {
      // print(response.statusCode);
      print("data");
      machinedata = jsonDecode(response.body);
      print(machinedata);
      print(machinedata.length);
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
    return (isLoad == true)
        ? SizedBox(
      height: 500,
      child: Center(
        child: CircularProgressIndicator(
          color: Constants.primaryColor,
        ),
      ),
    )
        : RefreshIndicator(
      onRefresh: (){
        return Future(() => FetchManoThermoReport());
      },
          child: (data.length != 0)?Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
          children: [
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
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  height: 30,
                  width: w / 3.2,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      border: Border.all(color: Colors.grey)),
                  child: Center(
                    child: Text(
                      "ID FAN(Hz)",
                      style: TextStyle(
                        // color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        fontFamily: Constants.popins,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 30,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      border: Border.all(color: Colors.grey)),
                  width: w / 3.2,
                  child: Center(
                    child: Text(
                      "FD FAN(Hz)",
                      style: TextStyle(
                        // color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        fontFamily: Constants.popins,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 30,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      border: Border.all(color: Colors.grey)),
                  width: w / 3.2,
                  child: Center(
                    child: Text(
                      "COAL USED",
                      style: TextStyle(
                        // color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        fontFamily: Constants.popins,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  height: 30,
                  width: w / 3.2,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      border: Border.all(color: Colors.grey)),
                  child: Center(
                    child: Text(
                      idfan.toString(),
                      style: TextStyle(
                        // color: Colors.white,
                        fontSize: 14,
                        fontFamily: Constants.popins,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 30,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      border: Border.all(color: Colors.grey)),
                  width: w / 3.2,
                  child: Center(
                    child: Text(
                      fdfan.toString(),
                      style: TextStyle(
                        // color: Colors.white,
                        fontSize: 14,
                        fontFamily: Constants.popins,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 30,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      border: Border.all(color: Colors.grey)),
                  width: w / 3.2,
                  child: Center(
                    child: Text(
                      coal.toString(),
                      style: TextStyle(
                        // color: Colors.white,
                        fontSize: 14,
                        fontFamily: Constants.popins,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  height: 60,
                  width: w / 2,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      border: Border.all(color: Colors.grey)),
                  child: Center(
                    child: Text(
                      "APH TO FURNANCE",
                      style: TextStyle(
                        // color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        fontFamily: Constants.popins,
                      ),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Container(
                      height: 30,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          border: Border.all(color: Colors.grey)),
                      width: w / 5,
                      child: Center(
                        child: Text(
                          "Value",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            // color: Colors.white,
                            fontSize: 14,
                            fontFamily: Constants.popins,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 30,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          border: Border.all(color: Colors.grey)),
                      width: w / 5,
                      child: Center(
                        child: Text(
                          aphv.toString(),
                          style: TextStyle(
                            // color: Colors.white,
                            fontSize: 14,
                            fontFamily: Constants.popins,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Container(
                      height: 30,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          border: Border.all(color: Colors.grey)),
                      width: w / 4.2,
                      child: Center(
                        child: Text(
                          "Temperature",
                          style: TextStyle(
                            // color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            fontFamily: Constants.popins,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 30,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          border: Border.all(color: Colors.grey)),
                      width: w / 4.2,
                      child: Center(
                        child: Text(
                          apht.toString(),
                          style: TextStyle(
                            // color: Colors.white,
                            fontSize: 14,
                            fontFamily: Constants.popins,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 15.0, right: 15.0),
                          child: Column(
                            children: [
                              SizedBox(height: 25),
                              Container(
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
                                    vertical: 5, horizontal: 10),
                                child: Column(
                                  children: [
                                    Text(
                                      data[index]['thermopack'].toString(),
                                      style: TextStyle(
                                          fontFamily: Constants.popins,
                                          color: Constants.textColor,
                                          // fontWeight: FontWeight.w600,
                                          fontSize: 20),
                                    ),
                                    // SizedBox(height: 10),
                                    // Container(color: Colors.blue,width: w,height: 1,),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Value"),
                                        Container(
                                          height: 35,
                                          width: 80,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.all(
                                                  Radius.circular(12)),
                                              color: Colors.grey.shade200,
                                              border: Border.all(
                                                  color: Constants
                                                      .primaryColor)),
                                          child: Center(
                                            child: Text(num.parse((data[index]['value']??0).toString()).toStringAsFixed(2)),
                                          ),
                                        ),
                                        Container(
                                          color: Constants.secondaryColor
                                              .withOpacity(0.2),
                                          width: 1,
                                          height: h / 15,
                                        ),
                                        Text("Temp"),
                                        Container(
                                          height: 35,
                                          width: 80,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.all(
                                                  Radius.circular(12)),
                                              color: Colors.grey.shade200,
                                              border: Border.all(
                                                  color: Constants
                                                      .primaryColor)),
                                          child: Center(
                                            child: Text(num.parse((data[index]['temperature']??0).toString()).toStringAsFixed(2)),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
            ),
          ],
      ),
    ):Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
          children: [
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
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  height: 30,
                  width: w / 3.2,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      border: Border.all(color: Colors.grey)),
                  child: Center(
                    child: Text(
                      "ID FAN(Hz)",
                      style: TextStyle(
                        // color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        fontFamily: Constants.popins,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 30,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      border: Border.all(color: Colors.grey)),
                  width: w / 3.2,
                  child: Center(
                    child: Text(
                      "FD FAN(Hz)",
                      style: TextStyle(
                        // color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        fontFamily: Constants.popins,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 30,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      border: Border.all(color: Colors.grey)),
                  width: w / 3.2,
                  child: Center(
                    child: Text(
                      "COAL USED",
                      style: TextStyle(
                        // color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        fontFamily: Constants.popins,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  height: 30,
                  width: w / 3.2,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      border: Border.all(color: Colors.grey)),
                  child: Center(
                    child: Text(
                      idfan.toString(),
                      style: TextStyle(
                        // color: Colors.white,
                        fontSize: 14,
                        fontFamily: Constants.popins,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 30,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      border: Border.all(color: Colors.grey)),
                  width: w / 3.2,
                  child: Center(
                    child: Text(
                      fdfan.toString(),
                      style: TextStyle(
                        // color: Colors.white,
                        fontSize: 14,
                        fontFamily: Constants.popins,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 30,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      border: Border.all(color: Colors.grey)),
                  width: w / 3.2,
                  child: Center(
                    child: Text(
                      coal.toString(),
                      style: TextStyle(
                        // color: Colors.white,
                        fontSize: 14,
                        fontFamily: Constants.popins,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  height: 60,
                  width: w / 2,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      border: Border.all(color: Colors.grey)),
                  child: Center(
                    child: Text(
                      "APH TO FURNANCE",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        // color: Colors.white,
                        fontSize: 14,
                        fontFamily: Constants.popins,
                      ),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Container(
                      height: 30,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          border: Border.all(color: Colors.grey)),
                      width: w / 5,
                      child: Center(
                        child: Text(
                          "Value",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            // color: Colors.white,
                            fontSize: 14,
                            fontFamily: Constants.popins,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 30,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          border: Border.all(color: Colors.grey)),
                      width: w / 5,
                      child: Center(
                        child: Text(
                          aphv.toString(),
                          style: TextStyle(
                            // color: Colors.white,
                            fontSize: 14,
                            fontFamily: Constants.popins,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Container(
                      height: 30,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          border: Border.all(color: Colors.grey)),
                      width: w / 4.2,
                      child: Center(
                        child: Text(
                         "Temperature",
                          style: TextStyle(
                            // color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            fontFamily: Constants.popins,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 30,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          border: Border.all(color: Colors.grey)),
                      width: w / 4.2,
                      child: Center(
                        child: Text(
                          apht.toString(),
                          style: TextStyle(
                            // color: Colors.white,
                            fontSize: 14,
                            fontFamily: Constants.popins,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),

            (machinedata.length == 0)
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
                  itemBuilder: (BuildContext context, int index) {
                    return Stack(
                      children: [
                        // Transform.rotate(
                        //   child: Center(
                        //     child: Text(
                        //       "<<",
                        //       style: TextStyle(fontSize: 40),
                        //     ),
                        //   ),
                        //   angle: -math.pi/2,
                        // ),
                        // Center(
                        //   child: Container(
                        //     width: 5,
                        //     height: 60,
                        //     color: Constants.secondaryColor, //Text
                        //   ),
                        // ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 15.0, right: 15.0),
                          child: Column(
                            children: [
                              SizedBox(height: 25),
                              Container(
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
                                    vertical: 5, horizontal: 10),
                                child: Column(
                                  children: [
                                    Text(
                                      machinedata[index]['thermopack'].toString(),
                                      style: TextStyle(
                                          fontFamily: Constants.popins,
                                          color: Constants.textColor,
                                          // fontWeight: FontWeight.w600,
                                          fontSize: 20),
                                    ),
                                    // SizedBox(height: 10),
                                    // Container(color: Colors.blue,width: w,height: 1,),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Value"),
                                        Container(
                                          height: 35,
                                          width: 80,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.all(
                                                  Radius.circular(12)),
                                              color: Colors.grey.shade200,
                                              border: Border.all(
                                                  color: Constants
                                                      .primaryColor)),
                                          child: Center(
                                            child: Text("0"),
                                          ),
                                        ),
                                        Container(
                                          color: Constants.secondaryColor
                                              .withOpacity(0.2),
                                          width: 1,
                                          height: h / 15,
                                        ),
                                        Text("Temp"),
                                        Container(
                                          height: 35,
                                          width: 80,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.all(
                                                  Radius.circular(12)),
                                              color: Colors.grey.shade200,
                                              border: Border.all(
                                                  color: Constants
                                                      .primaryColor)),
                                          child: Center(
                                            child: Text("0"),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
