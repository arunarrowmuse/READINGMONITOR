import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../constants.dart';

class ViewSteamBoiler extends StatefulWidget {
  const ViewSteamBoiler({Key? key}) : super(key: key);

  @override
  State<ViewSteamBoiler> createState() => _ViewSteamBoilerState();
}

class _ViewSteamBoilerState extends State<ViewSteamBoiler>
    with AutomaticKeepAliveClientMixin<ViewSteamBoiler> {
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
        FetchSteamReport();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    FetchSteamReport();
  }

  void FetchSteamReport() async {
    setState(() {
      isLoad = true;
    });
    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    final response = await http.get(
      Uri.parse(
          '${Constants.weblink}ViewReportSteamBoilerDateSearchNew/${selectedDate
              .toString().split(" ")[0]}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      print("View data------------------------------");
      print(response.body);
      data = jsonDecode(response.body);
      print(data);
      setState(() {
        isLoad = false;
      });
    } else {
      print("error is here");
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
                return Future(() => FetchSteamReport());
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
                            Text(" BFW :",
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
                                child: Text(data[0]['bfw'].toString(),
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
                            Text(" BFW Temperature :",
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
                                    data[0]['bfw_temperature'].toString(),
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
                                child: Text(data[0]['coal_1'].toString(),
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
                                child: Text(data[0]['coal_2'].toString(),
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
                            Text(" Steam Cost :",
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
                                    num.parse((data[0]['sc'] ?? 0).toString())
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
                            Text(" BFW % :",
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
                                    (data[0]["bfwper"] ?? 0).toString()) <
                                    num.parse(data[0][
                                    "bfw_percentageold"]) &&
                                    num.parse(
                                        (data[0]["bfwper"] ?? 0).toString()) >
                                        num.parse(data[0][
                                        "bfw_percentageold"]) *
                                            -1)
                                    ? Text(num.parse(
                                    (data[0]['bfwper'] ?? 0).toString())
                                    .toStringAsFixed(2) + " %",
                                    style: TextStyle(
                                      // color: Colors.grey,
                                        fontFamily: Constants.popins,
                                        fontSize: 14)) : Text(num.parse(
                                    (data[0]['bfwper'] ?? 0).toString())
                                    .toStringAsFixed(2) + " %",
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w600,
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
                            Text(" BFW Temperature % :",
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
                                    (data[0]["tempper"] ?? 0).toString()) <
                                    num.parse(data[0][
                                    "bfw_temperature_percentageold"]) &&
                                    num.parse(
                                        (data[0]["tempper"] ?? 0).toString()) >
                                        num.parse(data[0][
                                        "bfw_temperature_percentageold"]) *
                                            -1)
                                    ? Text(num.parse(
                                    (data[0]['tempper'] ?? 0).toString())
                                    .toStringAsFixed(2) + " %",
                                    style: TextStyle(
                                      // color: Colors.grey,
                                        fontFamily: Constants.popins,
                                        fontSize: 14)) : Text(num.parse(
                                    (data[0]['tempper'] ?? 0).toString())
                                    .toStringAsFixed(2) + " %",
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontFamily: Constants.popins,
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
                                    (data[0]["coal_1per"] ?? 0).toString()) <
                                    num.parse(data[0][
                                    "coal_deviation_1"]) &&
                                    num.parse((data[0]["coal_1per"] ?? 0)
                                        .toString()) >
                                        num.parse(data[0][
                                        "coal_deviation_1"]) *
                                            -1)
                                    ? Text(num.parse(
                                    (data[0]['coal_1per'] ?? 0).toString())
                                    .toStringAsFixed(2) + " %",
                                    style: TextStyle(
                                      // color: Colors.grey,
                                        fontFamily: Constants.popins,
                                        fontSize: 14)) : Text(num.parse(
                                    (data[0]['coal_1per'] ?? 0).toString())
                                    .toStringAsFixed(2) + " %",
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontFamily: Constants.popins,
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
                                    (data[0]["coal_2per"] ?? 0).toString()) <
                                    num.parse(data[0][
                                    "coal_deviation_2"]) &&
                                    num.parse((data[0]["coal_2per"] ?? 0)
                                        .toString()) >
                                        num.parse(data[0][
                                        "coal_deviation_2"]) *
                                            -1)
                                    ? Text(num.parse(
                                    (data[0]['coal_2per'] ?? 0).toString())
                                    .toStringAsFixed(2) + " %",
                                    style: TextStyle(
                                      // color: Colors.grey,
                                        fontFamily: Constants.popins,
                                        fontSize: 14)) : Text(num.parse(
                                    (data[0]['coal_2per'] ?? 0).toString())
                                    .toStringAsFixed(2) + " %",
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w600,
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
                            Text(" Steam Cost % :",
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
                                    (data[0]["scper"] ?? 0).toString()) <
                                    num.parse(data[0][
                                    "steam_cost_percentage"]) &&
                                    num.parse(
                                        (data[0]["scper"] ?? 0).toString()) >
                                        num.parse(data[0][
                                        "steam_cost_percentage"]) *
                                            -1)
                                    ? Text(num.parse(
                                    (data[0]['scper'] ?? 0).toString())
                                    .toStringAsFixed(2) + " %",
                                    style: TextStyle(
                                      // color: Colors.grey,
                                        fontFamily: Constants.popins,
                                        fontSize: 14)) : Text(num.parse(
                                    (data[0]['scper'] ?? 0).toString())
                                    .toStringAsFixed(2) + " %",
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: Constants.popins,
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
                            Text(" BFW :",
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
                                child: Text("0",
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
                            Text(" BFW Temperature :",
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
                                child: Text("0",
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
                                child: Text("0",
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
                                child: Text("0",
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
                            Text(" Steam Cost :",
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
                                child: Text("0",
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
                            Text(" BFW % :",
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
                            Text(" BFW Temperature % :",
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
                            Text(" Steam Cost % :",
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
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
