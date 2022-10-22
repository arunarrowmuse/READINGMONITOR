import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../constants.dart';

class ViewSupplyPump extends StatefulWidget {
  const ViewSupplyPump({Key? key}) : super(key: key);

  @override
  State<ViewSupplyPump> createState() => _ViewSupplyPumpState();
}

class _ViewSupplyPumpState extends State<ViewSupplyPump> with AutomaticKeepAliveClientMixin<ViewSupplyPump> {
  bool isLoad = false;
  var data;
  var machinedata;
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
        FetchSupplyPumpReport();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    FetchSupplyPumpReport();
  }

  void FetchSupplyPumpReport() async {
    setState(() {
      isLoad = true;
    });
    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    final response = await http.get(
      Uri.parse(
          '${Constants.weblink}ViewReportSupplyPumpDateSearch/${selectedDate.toString().split(" ")[0]}'),
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
        FetchSupplyMachineList();
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

  void FetchSupplyMachineList() async {
    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    final response = await http.get(
      Uri.parse('${Constants.weblink}GetSupplyPumpListing/${selectedDate.toString().split(" ")[0]}'),
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
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    DateTime now = DateTime.now();
    var formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
    return RefreshIndicator(
      onRefresh: (){
        return Future(() => FetchSupplyPumpReport());
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
                                          data[index]['CategoryName'],
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
                                                      "Flow",
                                                      style: TextStyle(
                                                          fontFamily:
                                                              Constants.popins,
                                                          // color: Constants.textColor,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 12),
                                                    ),
                                                    Text(
                                                      data[index]['flow']
                                                          .toString(),
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
                                                      "Units",
                                                      style: TextStyle(
                                                          fontFamily:
                                                              Constants.popins,
                                                          // color: Constants.textColor,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 12),
                                                    ),
                                                    Text(
                                                      data[index]['unit']
                                                          .toString(),
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
                                          height: h / 15,
                                        ),
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
                                                      "Average",
                                                      style: TextStyle(
                                                          fontFamily:
                                                              Constants.popins,
                                                          // color: Constants.textColor,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 12),
                                                    ),
                                                    Text(
                                                      num.parse((data[index]['average']??0).toString())
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
                                                      "Deviation",
                                                      style: TextStyle(
                                                          fontFamily:
                                                              Constants.popins,
                                                          // color: Constants.textColor,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 12),
                                                    ),
                                                    (num.parse((data[index]["dev"]??0).toString()) <
                                                                num.parse((data[index][
                                                                    "deviation"]).toString()) &&
                                                        num.parse((data[index]["dev"]??0).toString()) >
                                                            num.parse((data[index][
                                                            "deviation"]).toString()) *
                                                                    -1)
                                                        ? Text(
                                                      num.parse((data[index]['dev']??0).toString())
                                                                .toStringAsFixed(
                                                                    2) + " %",
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
                                                            num.parse((data[index]['dev']??0).toString())
                                                                .toStringAsFixed(
                                                                    2) + " %",
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    Constants
                                                                        .popins,
                                                                color: Colors.red,
                                                                decoration:
                                                                    TextDecoration
                                                                        .underline,
                                                                // color: Constants.textColor,
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
                                              machinedata[index]['name']
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
                                                          "Flow",
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
                                                          "Units",
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
                                                          "Average",
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
                                                          "Deviation",
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
    );
  }

  @override
  bool get wantKeepAlive => true;
}
