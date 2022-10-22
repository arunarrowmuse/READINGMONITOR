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
          '${Constants.weblink}ViewReportGebDateSearch/${selectedDate.toString().split(" ")[0]}'),
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
                              backgroundColor: MaterialStateProperty.all<Color>(
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
                              backgroundColor: MaterialStateProperty.all<Color>(
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
                  return Future(() => FetchGEBReport());
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
                                    Text(" KWH :",
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
                                            num.parse((data[0]['kwhtotal']??0).toString()).toStringAsFixed(2),
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
                                    Text(" PF :",
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
                                            num.parse((data[0]['pf']??0).toString()).toStringAsFixed(2),
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
                                    Text(" KVARH :",
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
                                        child: Text(num.parse((data[0]['kvarh']??0).toString()).toStringAsFixed(2),
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
                                    Text(" MD :",
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
                                            num.parse((data[0]['mdTotal']??0).toString()).toStringAsFixed(2),
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
                                    Text(" KVAH :",
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
                                            num.parse((data[0]['kevah']).toString()).toStringAsFixed(2),
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
                                    Text(" Turbine :",
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
                                            num.parse((data[0]['turbine']??0).toString())
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
                                    Text("KWH Deviation :",
                                        style: TextStyle(
                                            // color: Colors.white,
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
                                        child: ((num.parse((data[0]["kwhtotalper"] ?? 0).toString()) <
                                                    num.parse((data[0]["kwm_deviation"]??0).toString()) &&
                                            num.parse((data[0]["kwhtotalper"] ?? 0).toString()) >
                                                num.parse((data[0]["kwm_deviation"]??0).toString()) *
                                                        -1))
                                            ? Text(
                                            num.parse((data[0]['kwhtotalper'] ?? 0).toString())
                                                        .toStringAsFixed(2) +
                                                    " %",
                                                style: TextStyle(
                                                    // color: Colors.grey,
                                                    fontFamily:
                                                        Constants.popins,
                                                    fontSize: 14))
                                            : Text(
                                                num.parse((data[0]['kwhtotalper'] ?? 0).toString())
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
                                    Text(" PF Deviation :",
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
                                        child: ((num.parse((data[0]["pfper"] ?? 0).toString()) <
                                                    num.parse((data[0]["pf_deviation"]??0).toString()) &&
                                            num.parse((data[0]["pfper"] ?? 0).toString()) >
                                                    num.parse((data[0]["pf_deviation"]??0).toString()) *
                                                        -1))
                                            ? Text(
                                            num.parse((data[0]['pfper'] ?? 0).toString())
                                                        .toStringAsFixed(2) +
                                                    " %",
                                                style: TextStyle(
                                                    // color: Colors.grey,
                                                    fontFamily:
                                                        Constants.popins,
                                                    fontSize: 14))
                                            : Text(
                                                num.parse((data[0]['pfper'] ?? 0).toString())
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
                                    Text(" KVARH Deviation :",
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
                                        child: ((num.parse((data[0]["kvarhper"] ?? 0).toString()) <
                                                    num.parse((data[0]
                                                        ["kvarsh_deviation"]??0).toString()) &&
                                            num.parse((data[0]["kvarhper"] ?? 0).toString()) >
                                                num.parse((data[0]
                                                ["kvarsh_deviation"]??0).toString()) *
                                                        -1))
                                            ? Text(
                                            num.parse((data[0]['kvarhper'] ?? 0).toString())
                                                        .toStringAsFixed(2) +
                                                    " %",
                                                style: TextStyle(
                                                    // color: Colors.grey,
                                                    fontFamily:
                                                        Constants.popins,
                                                    fontSize: 14))
                                            : Text(
                                                num.parse((data[0]['kvarhper'] ?? 0).toString())
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
                                    Text(" MD Deviation :",
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
                                        child: ((num.parse((data[0]["mdper"] ?? 0).toString()) <
                                            num.parse((data[0]["md_deviation"]??0).toString()) &&
                                            num.parse((data[0]["mdper"] ?? 0).toString()) >
                                                    num.parse((data[0]["md_deviation"]??0).toString()) *
                                                        -1))
                                            ? Text(
                                            num.parse((data[0]['mdper'] ?? 0).toString())
                                                        .toStringAsFixed(2) +
                                                    " %",
                                                style: TextStyle(
                                                    // color: Colors.grey,
                                                    fontFamily:
                                                        Constants.popins,
                                                    fontSize: 14))
                                            : Text(
                                                num.parse((data[0]['mdper'] ?? 0).toString())
                                                        .toStringAsFixed(2) +
                                                    " %",
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    fontWeight: FontWeight.w600,
                                                    fontFamily:
                                                        Constants.popins,
                                                    fontSize: 14)),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(" KVAH Deviation :",
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
                                        child: ((num.parse((data[0]["kvahper"] ?? 0).toString()) <
                                                    num.parse((data[0]
                                                        ["kevah_deviation"]??0).toString()) &&
                                            num.parse((data[0]["kvahper"] ?? 0).toString()) >
                                                num.parse((data[0]
                                                ["kevah_deviation"]??0).toString()) *
                                                        -1))
                                            ? Text(
                                            num.parse((data[0]['kvahper'] ?? 0).toString())
                                                        .toStringAsFixed(2) +
                                                    " %",
                                                style: TextStyle(
                                                    // color: Colors.grey,
                                                    fontFamily:
                                                        Constants.popins,
                                                    fontSize: 14))
                                            : Text(
                                                num.parse((data[0]['kvahper'] ?? 0).toString())
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
                                    Text(" Turbine Deviation :",
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
                                        child: ((num.parse((data[0]["turbineper"] ?? 0).toString()) <
                                                    num.parse((data[0]["turbine_deviation"] ??
                                                        0).toString()) &&
                                            num.parse((data[0]["turbineper"] ?? 0).toString()) >
                                                    num.parse((data[0]["turbine_deviation"] ??
                                                        0).toString()) *
                                                        -1))
                                            ? Text(
                                                num.parse((data[0]['turbineper'] ?? 0).toString())
                                                        .toStringAsFixed(2) +
                                                    " %",
                                                style: TextStyle(
                                                    // color: Colors.grey,
                                                    fontFamily:
                                                        Constants.popins,
                                                    fontSize: 14))
                                            : Text(
                                                num.parse((data[0]['turbineper'] ?? 0).toString())
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
                                    Text(" KWH :",
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
                                    Text(" PF :",
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
                                    Text(" KVARH :",
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
                                    Text(" MD :",
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
                                    Text(" KVAH :",
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
                                    Text(" Turbine :",
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
                                    Text("KWH Deviation :",
                                        style: TextStyle(
                                            // color: Colors.white,
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
                                    Text(" PF Deviation :",
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
                                    Text(" KVARH Deviation :",
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
                                    Text(" MD Deviation :",
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
                                    Text(" KVAH Deviation :",
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
                                    Text(" Turbine Deviation :",
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
  bool get wantKeepAlive => true;
}
