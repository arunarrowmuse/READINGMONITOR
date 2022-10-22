import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../constants.dart';

class ViewThermoPack extends StatefulWidget {
  const ViewThermoPack({Key? key}) : super(key: key);

  @override
  State<ViewThermoPack> createState() => _ViewThermoPackState();
}

class _ViewThermoPackState extends State<ViewThermoPack>
    with AutomaticKeepAliveClientMixin<ViewThermoPack> {
  DateTime selectedDate = DateTime.now();
  bool isLoad = false;
  var data;
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
        FetchThermoPackReport();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    FetchThermoPackReport();
  }

  void FetchThermoPackReport() async {
    setState(() {
      isLoad = true;
    });
    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    final response = await http.get(
      Uri.parse(
          '${Constants.weblink}ViewReportThermopackDateSearchNew/${selectedDate
              .toString().split(" ")[0]}'),
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
    return Scaffold(
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
                : RefreshIndicator(
              onRefresh: () {
                return Future(() => FetchThermoPackReport());
              },
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: (data.length != 0)
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(" Chamber :",
                                style: TextStyle(
                                  // color: Colors.grey,
                                    fontFamily: Constants.popins,
                                    fontSize: 14)),
                            const SizedBox(height: 5),
                            Container(
                              height: 40,
                              width: 140,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8))),
                              child: Center(
                                child: Text(
                                    data[0]['chamber'].toString(),
                                    style: TextStyle(
                                      // color: Colors.grey,
                                        fontFamily: Constants.popins,
                                        fontSize: 14)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(" Pump Pressure % :",
                                style: TextStyle(
                                  // color: Colors.grey,
                                    fontFamily: Constants.popins,
                                    // fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            const SizedBox(height: 5),
                            Container(
                              height: 40,
                              width: 140,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8))),
                              child: Center(
                                child: Text(
                                    data[0]['pump_presure'].toString(),
                                    style: TextStyle(
                                      // color: Colors.grey,
                                        fontFamily: Constants.popins,
                                        fontSize: 14)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(" Coal 1 :",
                                style: TextStyle(
                                  // color: Colors.grey,
                                    fontFamily: Constants.popins,
                                    // fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            const SizedBox(height: 5),
                            Container(
                              height: 40,
                              width: 140,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8))),
                              child: Center(
                                child: Text(data[0]['col1'].toString(),
                                    style: TextStyle(
                                      // color: Colors.grey,
                                        fontFamily: Constants.popins,
                                        fontSize: 14)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(" Coal 2 :",
                                style: TextStyle(
                                  // color: Colors.grey,
                                    fontFamily: Constants.popins,
                                    // fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            const SizedBox(height: 5),
                            Container(
                              height: 40,
                              width: 140,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8))),
                              child: Center(
                                child: Text(data[0]['col2'].toString(),
                                    style: TextStyle(
                                      // color: Colors.grey,
                                        fontFamily: Constants.popins,
                                        fontSize: 14)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(" Delta T :",
                                style: TextStyle(
                                  // color: Colors.grey,
                                    fontFamily: Constants.popins,
                                    // fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            const SizedBox(height: 5),
                            Container(
                              height: 40,
                              width: 140,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8))),
                              child: Center(
                                child: Text(data[0]['dt'].toString(),
                                    style: TextStyle(
                                      // color: Colors.grey,
                                        fontFamily: Constants.popins,
                                        fontSize: 14)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(" Chamber   Cost :",
                                style: TextStyle(
                                  // color: Colors.grey,
                                    fontFamily: Constants.popins,
                                    // fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            const SizedBox(height: 5),
                            Container(
                              height: 40,
                              width: 140,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8))),
                              child: Center(
                                child: Text(
                                    (data[0]['cc'] ?? 0)
                                        .toStringAsFixed(2),
                                    style: TextStyle(
                                      // color: Colors.grey,
                                        fontFamily: Constants.popins,
                                        fontSize: 14)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: Constants.popins,
                                    fontSize: 14)),
                            const SizedBox(height: 5),
                            Container(
                              height: 40,
                              width: 140,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8))),
                              child: Center(
                                child: Text("",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontFamily: Constants.popins,
                                        fontSize: 14)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(" Circuit Pressure :",
                                style: TextStyle(
                                  // color: Colors.grey,
                                    fontFamily: Constants.popins,
                                    // fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            const SizedBox(height: 5),
                            Container(
                              height: 40,
                              width: 140,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8))),
                              child: Center(
                                child: Text(
                                    (data[0]['circuit_presure'] ?? 0)
                                        .toString(),
                                    style: TextStyle(
                                      // color: Colors.grey,
                                        fontFamily: Constants.popins,
                                        fontSize: 14)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(" Coal 1 Deviation :",
                                style: TextStyle(
                                  // color: Colors.grey,
                                    fontFamily: Constants.popins,
                                    // fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            const SizedBox(height: 5),
                            Container(
                              height: 40,
                              width: 140,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8))),
                              child: Center(
                                child: (num.parse(
                                    (data[0]["coal_1"] ?? 0).toString()) <
                                    num.parse(data[0]
                                    ['coal_deviation1'].toString()) &&
                                    num.parse(
                                        (data[0]["coal_1"] ?? 0).toString()) >
                                        num.parse(data[0]['coal_deviation1'].toString()) *
                                            -1)
                                    ? Text(
                                    num.parse((data[0]['coal_1'] ?? 0).toString())
                                        .toStringAsFixed(2) +
                                        " %",
                                    style: TextStyle(
                                      // color: Colors.grey,
                                        fontFamily:
                                        Constants.popins,
                                        fontSize: 14))
                                    : Text(
                                    num.parse((data[0]['coal_1'] ?? 0).toString())
                                        .toStringAsFixed(2) +
                                        " %",
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontFamily:
                                        Constants.popins,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(" Coal 2 Deviation :",
                                style: TextStyle(
                                  // color: Colors.grey,
                                    fontFamily: Constants.popins,
                                    // fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            const SizedBox(height: 5),
                            Container(
                              height: 40,
                              width: 140,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8))),
                              child: Center(
                                child: (num.parse(
                                    (data[0]["coal_2"] ?? 0).toString()) <
                                    num.parse((data[0]
                                    ['coal_deviation2']).toString())) &&
                                    (num.parse(
                                        (data[0]["coal_2"] ?? 0).toString()) >
                                        num.parse((data[0]['coal_deviation2'])
                                            .toString()) *
                                            -1)
                                    ? Text(
                                    num.parse((data[0]['coal_2'] ?? 0).toString())
                                        .toStringAsFixed(2) +
                                        " %",
                                    style: TextStyle(
                                      // color: Colors.grey,
                                        fontFamily:
                                        Constants.popins,
                                        fontSize: 14))
                                    : Text(
                                    num.parse((data[0]['coal_2'] ?? 0).toString())
                                        .toStringAsFixed(2) +
                                        " %",
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontFamily:
                                        Constants.popins,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(" Delta T % :",
                                style: TextStyle(
                                  // color: Colors.grey,
                                    fontFamily: Constants.popins,
                                    // fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            const SizedBox(height: 5),
                            Container(
                              height: 40,
                              width: 140,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8))),
                              child: Center(
                                child: (num.parse(
                                    (data[0]["dtper"] ?? 0).toString()) <
                                    num.parse(
                                        (data[0]['delta_t']).toString()) &&
                                    num.parse(
                                        (data[0]["dtper"] ?? 0).toString()) >
                                        num.parse(
                                            (data[0]['delta_t']).toString()) *
                                            -1)
                                    ? Text(
                                    num.parse((data[0]['dtper'] ?? 0).toString())
                                        .toStringAsFixed(2) +
                                        " %",
                                    style: TextStyle(
                                      // color: Colors.red,
                                        fontFamily:
                                        Constants.popins,
                                        // fontWeight: FontWeight.w600,
                                        fontSize: 14))
                                    : Text(
                                    num.parse((data[0]['dtper'] ?? 0).toString())
                                        .toStringAsFixed(2) +
                                        " %",
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontFamily:
                                        Constants.popins,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(" Chamber Cost % :",
                                style: TextStyle(
                                  // color: Colors.grey,
                                    fontFamily: Constants.popins,
                                    // fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            const SizedBox(height: 5),
                            Container(
                              height: 40,
                              width: 140,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8))),
                              child: Center(
                                child: (num.parse(
                                    (data[0]["ccper"] ?? 0).toString()) <
                                    num.parse((data[0][
                                    'chamber_cost_percentage']).toString()) &&
                                    num.parse(
                                        (data[0]["ccper"] ?? 0).toString()) >
                                        num.parse((data[0][
                                        'chamber_cost_percentage'])
                                            .toString()) *
                                            -1)
                                    ? Text(
                                    num.parse(
                                        (data[0]['ccper'] ?? 0).toString())
                                        .toStringAsFixed(2) +
                                        " %",
                                    style: TextStyle(
                                      // color: Colors.grey,
                                        fontFamily:
                                        Constants.popins,
                                        fontSize: 14))
                                    : Text(
                                    num.parse(
                                        (data[0]['ccper'] ?? 0).toString())
                                        .toStringAsFixed(2) +
                                        " %",
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontFamily:
                                        Constants.popins,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(" Chamber :",
                                style: TextStyle(
                                  // color: Colors.grey,
                                    fontFamily: Constants.popins,
                                    fontSize: 14)),
                            const SizedBox(height: 5),
                            Container(
                              height: 40,
                              width: 140,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8))),
                              child: Center(
                                child: Text("0.00",
                                    style: TextStyle(
                                      // color: Colors.grey,
                                        fontFamily: Constants.popins,
                                        fontSize: 14)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(" Pump Pressure",
                                style: TextStyle(
                                  // color: Colors.grey,
                                    fontFamily: Constants.popins,
                                    // fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            const SizedBox(height: 5),
                            Container(
                              height: 40,
                              width: 140,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8))),
                              child: Center(
                                child: Text("0.00",
                                    style: TextStyle(
                                      // color: Colors.grey,
                                        fontFamily: Constants.popins,
                                        fontSize: 14)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(" Coal 1 :",
                                style: TextStyle(
                                  // color: Colors.grey,
                                    fontFamily: Constants.popins,
                                    // fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            const SizedBox(height: 5),
                            Container(
                              height: 40,
                              width: 140,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8))),
                              child: Center(
                                child: Text("0.00",
                                    style: TextStyle(
                                      // color: Colors.grey,
                                        fontFamily: Constants.popins,
                                        fontSize: 14)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(" Coal 2 :",
                                style: TextStyle(
                                  // color: Colors.grey,
                                    fontFamily: Constants.popins,
                                    // fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            const SizedBox(height: 5),
                            Container(
                              height: 40,
                              width: 140,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8))),
                              child: Center(
                                child: Text("0.00",
                                    style: TextStyle(
                                      // color: Colors.grey,
                                        fontFamily: Constants.popins,
                                        fontSize: 14)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(" Delta T :",
                                style: TextStyle(
                                  // color: Colors.grey,
                                    fontFamily: Constants.popins,
                                    // fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            const SizedBox(height: 5),
                            Container(
                              height: 40,
                              width: 140,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8))),
                              child: Center(
                                child: Text("0.00",
                                    style: TextStyle(
                                      // color: Colors.grey,
                                        fontFamily: Constants.popins,
                                        fontSize: 14)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(" Chamber   Cost :",
                                style: TextStyle(
                                  // color: Colors.grey,
                                    fontFamily: Constants.popins,
                                    // fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            const SizedBox(height: 5),
                            Container(
                              height: 40,
                              width: 140,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8))),
                              child: Center(
                                child: Text("0.00",
                                    style: TextStyle(
                                      // color: Colors.grey,
                                        fontFamily: Constants.popins,
                                        fontSize: 14)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: Constants.popins,
                                    fontSize: 14)),
                            const SizedBox(height: 5),
                            Container(
                              height: 40,
                              width: 140,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8))),
                              child: Center(
                                child: Text("",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontFamily: Constants.popins,
                                        fontSize: 14)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(" Circuit Pressure :",
                                style: TextStyle(
                                  // color: Colors.grey,
                                    fontFamily: Constants.popins,
                                    // fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            const SizedBox(height: 5),
                            Container(
                              height: 40,
                              width: 140,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8))),
                              child: Center(
                                child: Text("0.00",
                                    style: TextStyle(
                                      // color: Colors.grey,
                                        fontFamily: Constants.popins,
                                        fontSize: 14)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(" Coal 1 Deviation :",
                                style: TextStyle(
                                  // color: Colors.grey,
                                    fontFamily: Constants.popins,
                                    // fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            const SizedBox(height: 5),
                            Container(
                              height: 40,
                              width: 140,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8))),
                              child: Center(
                                child: Text("0.00 %",
                                    style: TextStyle(
                                      // color: Colors.grey,
                                        fontFamily: Constants.popins,
                                        fontSize: 14)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(" Coal 2 Deviation :",
                                style: TextStyle(
                                  // color: Colors.grey,
                                    fontFamily: Constants.popins,
                                    // fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            const SizedBox(height: 5),
                            Container(
                              height: 40,
                              width: 140,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8))),
                              child: Center(
                                child: Text("0.00 %",
                                    style: TextStyle(
                                      // color: Colors.grey,
                                        fontFamily: Constants.popins,
                                        fontSize: 14)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(" Delta T % :",
                                style: TextStyle(
                                  // color: Colors.grey,
                                    fontFamily: Constants.popins,
                                    // fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            const SizedBox(height: 5),
                            Container(
                              height: 40,
                              width: 140,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8))),
                              child: Center(
                                child: Text("0.00 %",
                                    style: TextStyle(
                                      // color: Colors.grey,
                                        fontFamily: Constants.popins,
                                        fontSize: 14)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(" Chamber Cost % :",
                                style: TextStyle(
                                  // color: Colors.grey,
                                    fontFamily: Constants.popins,
                                    // fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            const SizedBox(height: 5),
                            Container(
                              height: 40,
                              width: 140,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8))),
                              child: Center(
                                child: Text("0.00 %",
                                    style: TextStyle(
                                      // color: Colors.grey,
                                        fontFamily: Constants.popins,
                                        fontSize: 14)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
