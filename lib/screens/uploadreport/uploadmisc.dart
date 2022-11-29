import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';

class UploadMisc extends StatefulWidget {
  const UploadMisc({Key? key}) : super(key: key);

  @override
  State<UploadMisc> createState() => _UploadMiscState();
}

class _UploadMiscState extends State<UploadMisc>
    with AutomaticKeepAliveClientMixin<UploadMisc> {
  List<TextEditingController> ValueControllers = [];
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
        ValueControllers.clear();
        IDControllers.clear();
        FetchMiscList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    FetchMiscList();
  }

  void FetchMiscList() async {
    ValueControllers.clear();
    IDControllers.clear();
    setState(() {
      isLoad = true;
    });
    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    final response = await http.get(
      Uri.parse(
          '${Constants.weblink}MiscLisiting/${selectedDate.toString().split(" ")[0]}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
    );
    if (response.statusCode == 200) {
      print(response.statusCode);
      print(response.body);
      listdata = jsonDecode(response.body);
      print("machine List");
      print(listdata);
      final responses = await http.get(
        Uri.parse(
            '${Constants.weblink}MiscReportUploadSharch/${selectedDate.toString().split(" ")[0]}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $tokenvalue',
        },
      );
      if (responses.statusCode == 200) {
        uploaddata = jsonDecode(responses.body);
        print(" upload data");
        print(uploaddata);
        if (uploaddata.length == 0) {
          for (int i = 0; i < listdata.length; i++) {
            var unitsController = TextEditingController(text: "");
            var idController = TextEditingController(text: "0");
            ValueControllers.add(unitsController);
            IDControllers.add(idController);
          }
        } else {
          for (int i = 0; i < listdata.length; i++) {
            var unitsController = TextEditingController(text: "");
            var idController = TextEditingController(text: "0");
            for (int j = 0; j < uploaddata.length; j++) {
              if (listdata[i]['id'].toString() ==
                  uploaddata[j]['machin_id'].toString()) {
                idController =
                    TextEditingController(text: uploaddata[j]['id'].toString());
                unitsController = TextEditingController(
                    text: uploaddata[j]['unit'].toString());
              }
            }
            ValueControllers.add(unitsController);
            IDControllers.add(idController);
          }
          print(ValueControllers.length);
          print(IDControllers.length);
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

  void AddMiscList(int i) async {
    Utils(context).startLoading();
    // print("ValueUnit.length");
    // print(ValueUnit.length);
    // for (int i = 0; i < listdata.length; i++) {
    String value = "0";
    if (ValueControllers[i].text != "") {
      value = ValueControllers[i].text;
    }
    final response = await http.post(
      Uri.parse('${Constants.weblink}MiscReportUploadAdd'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
      body: jsonEncode(<String, String>{
        "date": selectedDate.toString().split(" ")[0],
        "machine_id": listdata[i]["id"].toString(),
        "machine_name": listdata[i]["machine_name"].toString(),
        "unit": value,
      }),
    );
    if (response.statusCode == 200) {
      // if (i == listdata.length - 1) {
      Constants.showtoast("Report Added!");
      Utils(context).stopLoading();
      // }
    } else {
      print(response.statusCode);
      print(response.body);
      Constants.showtoast("Error Updating Data.");
      Utils(context).stopLoading();
    }
    // }
    FetchMiscList();
  }

  void UpdateMiscList(int i, String id) async {
    Utils(context).startLoading();
    // for (int i = 0; i < listdata.length; i++) {
    String value = "0";
    if (ValueControllers[i].text != "") {
      value = ValueControllers[i].text;
    }
    final response = await http.put(
      Uri.parse('${Constants.weblink}MiscReportUploadUpdate/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
      body: jsonEncode(<String, String>{
        "unit": value,
      }),
    );
    if (response.statusCode == 200) {
      // data = jsonDecode(response.body);
      // ValueUnit[i].clear();
      // if (i == listdata.length - 1) {
      // Constants.showtoast("Report Updated!");
      Utils(context).stopLoading();
      // }
      // Constants.showtoast("Report Updated!");
    } else {
      print(response.statusCode);
      print(response.body);
      Constants.showtoast("Error Updating Data.");
      Utils(context).stopLoading();
    }
    Utils(context).stopLoading();
    FetchMiscList();
  }


  void AddUpdateMiscList() async {
    Utils(context).startLoading();
    for (int i = 0; i < IDControllers.length; i++) {
      if (IDControllers[i].text.toString() == "0") {
        if (ValueControllers[i].text != ""){
          print("added");
          String value = "0";
          if (ValueControllers[i].text != "") {
            value = ValueControllers[i].text;
          }
          final response = await http.post(
            Uri.parse('${Constants.weblink}MiscReportUploadAdd'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $tokenvalue',
            },
            body: jsonEncode(<String, String>{
              "date": selectedDate.toString().split(" ")[0],
              "machine_id": listdata[i]["id"].toString(),
              "machine_name": listdata[i]["machine_name"].toString(),
              "unit": value,
            }),
          );
          if (response.statusCode == 200) {
          } else {
            Constants.showtoast("Error Updating Data.");
          }
        }else{
          print("skipped");
        }
      } else {
        print("update");
        String value = "0";
        if (ValueControllers[i].text != "") {
          value = ValueControllers[i].text;
        }
        final response = await http.put(
          Uri.parse('${Constants.weblink}MiscReportUploadUpdate/${IDControllers[i].text}'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $tokenvalue',
          },
          body: jsonEncode(<String, String>{
            "unit": value,
          }),
        );
        if (response.statusCode == 200) {
          // Constants.showtoast("Report Updated!");

        } else {
          // print(response.statusCode);
          // print(response.body);
          Constants.showtoast("Error Updating Data.");
          // Utils(context).stopLoading();
        }
      }
    }

    Constants.showtoast("All Report Updated!");
    Utils(context).stopLoading();
    FetchMiscList();
  }

  @override
  Widget build(BuildContext context) {
    // final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    // DateTime now = DateTime.now();
    var formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
    return RefreshIndicator(
      onRefresh: () {
        return Future(() => FetchMiscList());
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
                          AddUpdateMiscList();
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
                : (listdata.length == 0)
                    ? Expanded(
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
                                                AddMiscList(index);
                                              } else {
                                                UpdateMiscList(index,
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
                                                        fontSize: 14)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      // mainAxisAlignment:
                                      // MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Value",
                                          style: TextStyle(
                                              fontFamily: Constants.popins,
                                              // color: Constants.textColor,
                                              // fontWeight: FontWeight.w600,
                                              fontSize: 12),
                                        ),
                                        const SizedBox(width: 10),
                                        SizedBox(
                                          height: 35,
                                          width: w * 0.35,
                                          child: TextFormField(
                                            keyboardType: TextInputType.number,
                                            controller: ValueControllers[index],
                                            style: TextStyle(
                                              fontFamily: Constants.popins,
                                              // color: Constants.textColor,
                                            ),
                                            decoration: InputDecoration(
                                                contentPadding:
                                                    const EdgeInsets.only(
                                                        bottom: 10.0,
                                                        left: 10.0),
                                                isDense: true,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  borderSide: BorderSide(
                                                      color:
                                                          Colors.grey.shade300,
                                                      width: 1.0),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Constants
                                                          .primaryColor,
                                                      width: 2.0),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                filled: true,
                                                hintStyle: TextStyle(
                                                  color: Colors.grey[400],
                                                  fontFamily: Constants.popins,
                                                ),
                                                // hintText: "first name",
                                                fillColor: Colors.white70),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
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
                                                AddMiscList(index);
                                              } else {
                                                UpdateMiscList(index,
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
                                                        fontSize: 14)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      // mainAxisAlignment:
                                      //     MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Value",
                                          style: TextStyle(
                                              fontFamily: Constants.popins,
                                              // color: Constants.textColor,
                                              // fontWeight: FontWeight.w600,
                                              fontSize: 12),
                                        ),
                                        const SizedBox(width: 10),
                                        SizedBox(
                                          height: 35,
                                          width: w * 0.35,
                                          child: TextFormField(
                                            keyboardType: TextInputType.number,
                                            controller: ValueControllers[index],
                                            style: TextStyle(
                                              fontFamily: Constants.popins,
                                              // color: Constants.textColor,
                                            ),
                                            decoration: InputDecoration(
                                                contentPadding:
                                                    const EdgeInsets.only(
                                                        bottom: 10.0,
                                                        left: 10.0),
                                                isDense: true,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  borderSide: BorderSide(
                                                      color:
                                                          Colors.grey.shade300,
                                                      width: 1.0),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Constants
                                                          .primaryColor,
                                                      width: 2.0),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                filled: true,
                                                hintStyle: TextStyle(
                                                  color: Colors.grey[400],
                                                  fontFamily: Constants.popins,
                                                ),
                                                // hintText: "first name",
                                                fillColor: Colors.white70),
                                          ),
                                        ),
                                      ],
                                    ),
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
