import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';

class UploadSupplyPump extends StatefulWidget {
  const UploadSupplyPump({Key? key}) : super(key: key);

  @override
  State<UploadSupplyPump> createState() => _UploadSupplyPumpState();
}

class _UploadSupplyPumpState extends State<UploadSupplyPump>
    with AutomaticKeepAliveClientMixin<UploadSupplyPump> {
  List<TextEditingController> FlowControllers = [];
  List<TextEditingController> UnitControllers = [];
  List<TextEditingController> IDControllers = [];
  DateTime selectedDate = DateTime.now();
  bool isLoad = false;
  var uploaddata;
  var listdata;
  late SharedPreferences prefs;
  String? tokenvalue;

  late StreamSubscription subscription;
  var isDeviceConnected = false;
  bool isAlertSet = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2050, 1));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        print(selectedDate.toString().split(" ")[0]);
        FlowControllers.clear();
        UnitControllers.clear();
        FetchSupplyList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    FetchSupplyList();
    getconnectivity();
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  getconnectivity() => subscription = Connectivity()
          .onConnectivityChanged
          .listen((ConnectivityResult result) async {
        isDeviceConnected = await InternetConnectionChecker().hasConnection;
        if (!isDeviceConnected && isAlertSet == false) {
          Constants.showtoast("No internet Connection");
          print("You are Offline!");
          setState(() {
            isAlertSet = true;
          });
        } else {
          print("You are Online!");
          tokenvalue = prefs.getString("token");
          String? data = prefs.getString("backuplinklist");
          Utils(context).backuptoserver(tokenvalue!, data!);
          prefs.setString("backuplinklist", jsonEncode([]));
          print("prefs.getString");
          print(prefs.getString("backuplinklist"));
        }
      });

  void FetchSupplyList() async {
    FlowControllers.clear();
    UnitControllers.clear();
    IDControllers.clear();
    setState(() {
      isLoad = true;
    });
    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    final response = await http.get(
      Uri.parse(
          '${Constants.weblink}GetSupplyPumpListing/${selectedDate.toString().split(" ")[0]}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
    );
    if (response.statusCode == 200) {
      listdata = jsonDecode(response.body);
      print("machine list");
      print(listdata.length);
      print(listdata);
      final responses = await http.get(
        Uri.parse(
            '${Constants.weblink}GetSupplyPumpReportUploadDateSerch/${selectedDate.toString().split(" ")[0]}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $tokenvalue',
        },
      );
      if (responses.statusCode == 200) {
        uploaddata = jsonDecode(responses.body);
        print(" upload data");
        print(uploaddata.length);
        print(uploaddata);
        if (uploaddata.length == 0) {
          for (int i = 0; i < listdata.length; i++) {
            var flowController = TextEditingController(text: "");
            var unitController = TextEditingController(text: "");
            var idController = TextEditingController(text: "0");
            FlowControllers.add(flowController);
            UnitControllers.add(unitController);
            IDControllers.add(idController);
          }
        } else {
          for (int i = 0; i < listdata.length; i++) {
            var flowController = TextEditingController(text: "");
            var unitController = TextEditingController(text: "");
            var idController = TextEditingController(text: "0");
            for (int j = 0; j < uploaddata.length; j++) {
              if (listdata[i]['id'] == uploaddata[j]['supplyp_name_id']) {
                idController =
                    TextEditingController(text: uploaddata[j]['id'].toString());
                flowController = TextEditingController(
                    text: uploaddata[j]['flow'].toString());
                unitController = TextEditingController(
                    text: uploaddata[j]['unit'].toString());
              }
            }
            IDControllers.add(idController);
            FlowControllers.add(flowController);
            UnitControllers.add(unitController);
          }
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

  void AddSupplyList(int i) async {
    Utils(context).startLoading();
    // for (int i = 0; i < listdata.length; i++) {
    String flow = "0";
    String unit = "0";
    if (FlowControllers[i].text != "") {
      flow = FlowControllers[i].text;
    }
    if (UnitControllers[i].text != "") {
      unit = UnitControllers[i].text;
    }
    final response = await http.post(
      Uri.parse('${Constants.weblink}GetSupplyPumpReportUploadAdd'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
      body: jsonEncode(<String, String>{
        "date": selectedDate.toString().split(" ")[0],
        "supplyp_name_id": listdata[i]["id"].toString(),
        "flow": flow,
        "unit": unit
      }),
    );
    if (response.statusCode == 200) {
      // data = jsonDecode(response.body);
      // if (i == listdata.length - 1) {
      Constants.showtoast("Report Added!");
      Utils(context).stopLoading();
      // }
      // Constants.showtoast("Report Updated!");
    } else {
      // print(response.statusCode);
      // print(response.body);
      Utils(context).stopLoading();
      Constants.showtoast("Error Updating Data.");
    }
    // }
    FetchSupplyList();
  }

  void UpdateSupplyList(int i, String id) async {
    Utils(context).startLoading();
    // for (int i = 0; i < listdata.length; i++) {
    String flow = "0";
    String unit = "0";
    if (FlowControllers[i].text != "") {
      flow = FlowControllers[i].text;
    }
    if (UnitControllers[i].text != "") {
      unit = UnitControllers[i].text;
    }
    final response = await http.put(
      Uri.parse('${Constants.weblink}SupplyPumpReportUploadUpdated/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
      body: jsonEncode(<String, String>{"flow": flow, "unit": unit}),
    );
    if (response.statusCode == 200) {
      // data = jsonDecode(response.body);
      // if (i == listdata.length - 1) {
      Constants.showtoast("Report Updated!");
      Utils(context).stopLoading();
      // }
      // Constants.showtoast("Report Updated!");
    } else {
      print(response.statusCode);
      print(response.body);
      Utils(context).stopLoading();
      Constants.showtoast("Error Updating Data.");
    }
    // }
    FetchSupplyList();
  }

  void AddUpdateSupplyList() async {
    Utils(context).startLoading();
    for (int i = 0; i < IDControllers.length; i++) {
      if (IDControllers[i].text.toString() == "0") {
        if (FlowControllers[i].text != "" || UnitControllers[i].text != "") {
          print('added');
          String flow = "0";
          String unit = "0";
          if (FlowControllers[i].text != "") {
            flow = FlowControllers[i].text;
          }
          if (UnitControllers[i].text != "") {
            unit = UnitControllers[i].text;
          }
          final response = await http.post(
            Uri.parse('${Constants.weblink}GetSupplyPumpReportUploadAdd'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $tokenvalue',
            },
            body: jsonEncode(<String, String>{
              "date": selectedDate.toString().split(" ")[0],
              "supplyp_name_id": listdata[i]["id"].toString(),
              "flow": flow,
              "unit": unit
            }),
          );
          if (response.statusCode == 200) {
            // Utils(context).stopLoading();
          } else {
            // Utils(context).stopLoading();
            Constants.showtoast("Error Updating Data.");
          }
        } else {
          print('skipped');
        }
      } else {
        print('update');
        String flow = "0";
        String unit = "0";
        if (FlowControllers[i].text != "") {
          flow = FlowControllers[i].text;
        }
        if (UnitControllers[i].text != "") {
          unit = UnitControllers[i].text;
        }
        final response = await http.put(
          Uri.parse(
              '${Constants.weblink}SupplyPumpReportUploadUpdated/${IDControllers[i].text}'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $tokenvalue',
          },
          body: jsonEncode(<String, String>{"flow": flow, "unit": unit}),
        );
        if (response.statusCode == 200) {
          // Constants.showtoast("Report Updated!");
        } else {
          print(response.statusCode);
          print(response.body);

          Constants.showtoast("Error Updating Data.");
        }
      }
    }
    Constants.showtoast("All Report Updated!");
    Utils(context).stopLoading();
    FetchSupplyList();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    DateTime now = DateTime.now();
    var formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
    return RefreshIndicator(
      onRefresh: () {
        return Future(() => FetchSupplyList());
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
                        onPressed: () async {
                          setState(() => isAlertSet = false);
                          isDeviceConnected =
                              await InternetConnectionChecker().hasConnection;
                          if (!isDeviceConnected) {
                            print("offline");
                            Utils(context).Youareoffline(context);
                          } else {
                            print("online");
                            AddUpdateSupplyList();
                          }

                        },
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Constants.primaryColor)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(" Submit All    ",
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
            SizedBox(height: 20),
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
                    ? Container(
                        height: 300,
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
                                          listdata[index]['name'].toString(),
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
                                            onPressed: () async {
                                              var backupbody;
                                              var backuplink;
                                              String flow = "0";
                                              String unit = "0";
                                              if (FlowControllers[index].text !=
                                                  "") {
                                                flow =
                                                    FlowControllers[index].text;
                                              }
                                              if (UnitControllers[index].text !=
                                                  "") {
                                                unit =
                                                    UnitControllers[index].text;
                                              }
                                              setState(
                                                  () => isAlertSet = false);
                                              isDeviceConnected =
                                                  await InternetConnectionChecker()
                                                      .hasConnection;
                                              if (!isDeviceConnected) {
                                                // print("offline");
                                                Constants.showtoast(
                                                    "No internet, Saving data offline.");
                                                // setState(
                                                //     () => isAlertSet = true);
                                                if (IDControllers[index].text ==
                                                    "0") {
                                                  // print('add backup');
                                                  backupbody = <String, String>{
                                                    "date": selectedDate
                                                        .toString()
                                                        .split(" ")[0],
                                                    "supplyp_name_id":
                                                        listdata[index]["id"]
                                                            .toString(),
                                                    "flow": flow,
                                                    "unit": unit
                                                  };
                                                  backuplink =
                                                      "${Constants.weblink}GetSupplyPumpReportUploadAdd";
                                                } else {
                                                  // print('update backup');
                                                  backupbody = <String, String>{
                                                    '_method': "PUT",
                                                    "flow": flow,
                                                    "unit": unit
                                                  };
                                                  backuplink =
                                                      "${Constants.weblink}SupplyPumpReportUploadUpdated/${IDControllers[index].text}";
                                                }
                                                prefs.getString(
                                                    "backuplinklist");
                                                if (prefs.getString(
                                                        "backuplinklist") ==
                                                    null) {
                                                  // print("called");
                                                  prefs.setString(
                                                      "backuplinklist",
                                                      jsonEncode([
                                                        {
                                                          "backuplink":
                                                              backuplink,
                                                          "backupbody":
                                                              backupbody
                                                        }
                                                      ]));
                                                } else {
                                                  // print("adder");
                                                  String? data =
                                                      prefs.getString(
                                                          "backuplinklist");
                                                  List DecodeUser =
                                                      jsonDecode(data!);
                                                  DecodeUser.add({
                                                    "backuplink": backuplink,
                                                    "backupbody": backupbody
                                                  });
                                                  prefs.setString(
                                                      "backuplinklist",
                                                      jsonEncode(DecodeUser));
                                                }
                                                print(json.decode(
                                                    prefs.getString(
                                                        "backuplinklist")!));
                                              } else {
                                                print("online");
                                                if (IDControllers[index].text ==
                                                    "0") {
                                                  AddSupplyList(index);
                                                } else {
                                                  UpdateSupplyList(
                                                      index,
                                                      IDControllers[index]
                                                          .text);
                                                }
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
                                                Text(" Submit  ",
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
                                    SizedBox(height: 10),
                                    Container(
                                        width: w / 1,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
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
                                                const SizedBox(width: 10),
                                                SizedBox(
                                                  height: 35,
                                                  width: w * 0.25,
                                                  child: TextFormField(
                                                    keyboardType:
                                                        TextInputType.numberWithOptions(decimal: true),
                                                    controller:
                                                        FlowControllers[index],
                                                    style: TextStyle(
                                                      fontFamily:
                                                          Constants.popins,
                                                      // color: Constants.textColor,
                                                    ),
                                                    decoration: InputDecoration(
                                                        contentPadding:
                                                            const EdgeInsets
                                                                    .only(
                                                                bottom: 10.0,
                                                                left: 10.0),
                                                        isDense: true,
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300,
                                                                  width: 1.0),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Constants
                                                                  .primaryColor,
                                                              width: 2.0),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        filled: true,
                                                        hintStyle: TextStyle(
                                                          color:
                                                              Colors.grey[400],
                                                          fontFamily:
                                                              Constants.popins,
                                                        ),
                                                        // hintText: "first name",
                                                        fillColor:
                                                            Colors.white70),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "Unit",
                                                  style: TextStyle(
                                                      fontFamily:
                                                          Constants.popins,
                                                      // color: Constants.textColor,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 12),
                                                ),
                                                const SizedBox(width: 10),
                                                SizedBox(
                                                  height: 35,
                                                  width: w * 0.25,
                                                  child: TextFormField(
                                                    keyboardType:
                                                        TextInputType.numberWithOptions(decimal: true),
                                                    controller:
                                                        UnitControllers[index],
                                                    style: TextStyle(
                                                      fontFamily:
                                                          Constants.popins,
                                                      // color: Constants.textColor,
                                                    ),
                                                    decoration: InputDecoration(
                                                        contentPadding:
                                                            const EdgeInsets
                                                                    .only(
                                                                bottom: 10.0,
                                                                left: 10.0),
                                                        isDense: true,
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300,
                                                                  width: 1.0),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Constants
                                                                  .primaryColor,
                                                              width: 2.0),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        filled: true,
                                                        hintStyle: TextStyle(
                                                          color:
                                                              Colors.grey[400],
                                                          fontFamily:
                                                              Constants.popins,
                                                        ),
                                                        // hintText: "first name",
                                                        fillColor:
                                                            Colors.white70),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ))
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
