import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';

class UploadUtility extends StatefulWidget {
  const UploadUtility({Key? key}) : super(key: key);

  @override
  State<UploadUtility> createState() => _UploadUtilityState();
}

class _UploadUtilityState extends State<UploadUtility>
    with AutomaticKeepAliveClientMixin<UploadUtility> {
  List<TextEditingController> EMControllers = [];
  List<TextEditingController> HMControllers = [];
  List<TextEditingController> IDControllers = [];
  bool isLoad = false;
  var uploaddata;
  var subcatdata;
  var maindata;
  late SharedPreferences prefs;
  String? tokenvalue;
  DateTime selectedDate = DateTime.now();

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
        EMControllers.clear();
        HMControllers.clear();
        FetchUtilityList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    FetchUtilityList();
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

  void FetchUtilityList() async {
    EMControllers.clear();
    HMControllers.clear();
    IDControllers.clear();
    print("the seleced date is  ${selectedDate.toString()}");
    setState(() {
      isLoad = true;
    });
    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    final responsed = await http.get(
      Uri.parse(
          '${Constants.weblink}GetUtilityLisiting/${selectedDate.toString().split(" ")[0]}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
    );
    if (responsed.statusCode == 200) {
      maindata = jsonDecode(responsed.body);
      print("machine name");
      print(maindata);
      final response = await http.get(
        Uri.parse(
            '${Constants.weblink}GetUtiltiSubCategoriesList/${selectedDate.toString().split(" ")[0]}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $tokenvalue',
        },
      );
      if (response.statusCode == 200) {
        subcatdata = jsonDecode(response.body);
        print(" sub machine list");
        print(subcatdata.length);
        print(subcatdata);
        final responses = await http.get(
          Uri.parse(
              '${Constants.weblink}GetUtiltiReportUploadQuery/${selectedDate.toString().split(" ")[0]}'),
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
            for (int i = 0; i < subcatdata.length; i++) {
              var emController = TextEditingController(text: "");
              var hmController = TextEditingController(text: "");
              var idController = TextEditingController(text: "0");
              EMControllers.add(emController);
              HMControllers.add(hmController);
              IDControllers.add(idController);
            }
          } else {
            for (int i = 0; i < subcatdata.length; i++) {
              var emController = TextEditingController(text: "");
              var hmController = TextEditingController(text: "");
              var idController = TextEditingController(text: "0");
              for (int j = 0; j < uploaddata.length; j++) {
                if (subcatdata[i]['id'] ==
                    uploaddata[j]['uitility_subcategories_id']) {
                  emController =
                      TextEditingController(text: uploaddata[j]['em']);
                  hmController =
                      TextEditingController(text: uploaddata[j]['hm']);
                  idController = TextEditingController(
                      text: uploaddata[j]['id'].toString());
                }
              }
              EMControllers.add(emController);
              HMControllers.add(hmController);
              IDControllers.add(idController);
            }
          }
          setState(() {
            isLoad = false;
          });
        } else {
          setState(() {
            isLoad = false;
          });
          Constants.showtoast("Error Fetching Data.");
        }
      } else {
        Constants.showtoast("Error Fetching Data.");
      }
    } else {
      setState(() {
        isLoad = false;
      });
      Constants.showtoast("Error Fetching Data.");
    }
  }

  void AddUtilityList(int i) async {
    Utils(context).startLoading();
    String emvalue;
    String hmvalue;
    if (EMControllers[i].text == "") {
      emvalue = "0";
    } else {
      emvalue = EMControllers[i].text;
    }
    if (HMControllers[i].text == "") {
      hmvalue = "0";
    } else {
      hmvalue = HMControllers[i].text;
    }
    final response = await http.post(
      Uri.parse('${Constants.weblink}GetUtiltiReportUploadQueryAdd'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
      body: jsonEncode(<String, String>{
        "uitility_categories_id":
            subcatdata[i]["uitility_categories_id"].toString(),
        "uitility_subcategories_id": subcatdata[i]["id"].toString(),
        "date": selectedDate.toString().split(" ")[0],
        "em": emvalue,
        "hm": hmvalue
      }),
    );
    if (response.statusCode == 200) {
      Constants.showtoast("Report Added!");
      Utils(context).stopLoading();
    } else {
      print(response.statusCode);
      print(response.body);
      Constants.showtoast("Error Updating Data.");
      Utils(context).stopLoading();
    }
    FetchUtilityList();
  }

  void UpdateUtilityList(int i, String id) async {
    Utils(context).startLoading();
    String emvalue;
    String hmvalue;
    if (EMControllers[i].text == "") {
      emvalue = "0";
    } else {
      emvalue = EMControllers[i].text;
    }
    if (HMControllers[i].text == "") {
      hmvalue = "0";
    } else {
      hmvalue = HMControllers[i].text;
    }
    final response = await http.put(
      Uri.parse('${Constants.weblink}GetUtiltiReportUploadQueryUpdated/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
      body: jsonEncode(<String, String>{"em": emvalue, "hm": hmvalue}),
    );
    if (response.statusCode == 200) {
      Constants.showtoast("Report Updated!");
      Utils(context).stopLoading();
    } else {
      print(response.statusCode);
      print(response.body);
      Constants.showtoast("Error Updating Data.");
      Utils(context).stopLoading();
    }
    FetchUtilityList();
  }

  void AddUpdateUtilityList() async {
    Utils(context).startLoading();
    for (int i = 0; i < IDControllers.length; i++) {
      if (IDControllers[i].text.toString() == "0") {
        if (EMControllers[i].text != "" || HMControllers[i].text != "") {
          print('Added');
          String emvalue;
          String hmvalue;
          if (EMControllers[i].text == "") {
            emvalue = "0";
          } else {
            emvalue = EMControllers[i].text;
          }
          if (HMControllers[i].text == "") {
            hmvalue = "0";
          } else {
            hmvalue = HMControllers[i].text;
          }
          final response = await http.post(
            Uri.parse('${Constants.weblink}GetUtiltiReportUploadQueryAdd'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $tokenvalue',
            },
            body: jsonEncode(<String, String>{
              "uitility_categories_id":
                  subcatdata[i]["uitility_categories_id"].toString(),
              "uitility_subcategories_id": subcatdata[i]["id"].toString(),
              "date": selectedDate.toString().split(" ")[0],
              "em": emvalue,
              "hm": hmvalue
            }),
          );
          if (response.statusCode == 200) {
            // Constants.showtoast("Report Added!");
            // Utils(context).stopLoading();
          } else {
            // print(response.statusCode);
            // print(response.body);
            Constants.showtoast("Error Updating Data.");
            // Utils(context).stopLoading();
          }
        } else {
          print("skipped");
        }
      } else {
        print("update data");
        String emvalue;
        String hmvalue;
        if (EMControllers[i].text == "") {
          emvalue = "0";
        } else {
          emvalue = EMControllers[i].text;
        }
        if (HMControllers[i].text == "") {
          hmvalue = "0";
        } else {
          hmvalue = HMControllers[i].text;
        }
        final response = await http.put(
          Uri.parse(
              '${Constants.weblink}GetUtiltiReportUploadQueryUpdated/${IDControllers[i].text}'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $tokenvalue',
          },
          body: jsonEncode(<String, String>{"em": emvalue, "hm": hmvalue}),
        );
        if (response.statusCode == 200) {
          // Constants.showtoast("Report Updated!");
          // Utils(context).stopLoading();
        } else {
          // print(response.statusCode);
          // print(response.body);
          Constants.showtoast("Error Updating Data.");
        }
      }
    }
    Constants.showtoast("All Report Updated!");
    Utils(context).stopLoading();
    FetchUtilityList();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    var formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
    return RefreshIndicator(
      onRefresh: () {
        return Future(() => FetchUtilityList());
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
                            AddUpdateUtilityList();
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
            // const SizedBox(height: 20),
            (isLoad == true)
                ? SizedBox(
                    height: 500,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Constants.primaryColor,
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: subcatdata.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(15.0)),
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
                                  children: [
                                    Row(
                                      // mainAxisAlignment:
                                      //     MainAxisAlignment.spaceBetween,
                                      // crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        for (var item in maindata)
                                          (item['id'].toString() ==
                                                  subcatdata[index][
                                                          'uitility_categories_id']
                                                      .toString())
                                              ? Text(
                                                  item['uitility_categories']
                                                          .toString() +
                                                      "  : ",
                                                  style: TextStyle(
                                                      fontFamily:
                                                          Constants.popins,
                                                      color:
                                                          Constants.textColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15),
                                                )
                                              : Container(),
                                        Text(
                                          subcatdata[index]['uilitysubc_name']
                                              .toString(),
                                          style: TextStyle(
                                              fontFamily: Constants.popins,
                                              color: Constants.textColor,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: 30,
                                      padding:
                                          const EdgeInsets.only(right: 15.0),
                                      // width: 100,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          // Utils(context).startLoading();
                                          var backupbody;
                                          var backuplink;
                                          setState(() => isAlertSet = false);
                                          isDeviceConnected =
                                              await InternetConnectionChecker()
                                                  .hasConnection;
                                          if (!isDeviceConnected) {
                                            // print("offline");
                                            Constants.showtoast(
                                                "No internet, Saving data offline.");
                                            // setState(() => isAlertSet = false);
                                            String emvalue;
                                            String hmvalue;
                                            if (EMControllers[index].text ==
                                                "") {
                                              emvalue = "0";
                                            } else {
                                              emvalue =
                                                  EMControllers[index].text;
                                            }
                                            if (HMControllers[index].text ==
                                                "") {
                                              hmvalue = "0";
                                            } else {
                                              hmvalue =
                                                  HMControllers[index].text;
                                            }
                                            if (IDControllers[index].text ==
                                                "0") {
                                              // print('add backup');
                                              backupbody = <String, String>{
                                                "uitility_categories_id":
                                                    subcatdata[index][
                                                            "uitility_categories_id"]
                                                        .toString(),
                                                "uitility_subcategories_id":
                                                    subcatdata[index]["id"]
                                                        .toString(),
                                                "date": selectedDate
                                                    .toString()
                                                    .split(" ")[0],
                                                "em": emvalue,
                                                "hm": hmvalue
                                              };
                                              backuplink =
                                                  "${Constants.weblink}GetUtiltiReportUploadQueryAdd";
                                            } else {
                                              // print('update backup');
                                              backupbody = <String, String>{
                                                '_method': "PUT",
                                                "em": emvalue,
                                                "hm": hmvalue
                                              };
                                              backuplink =
                                                  "${Constants.weblink}GetUtiltiReportUploadQueryUpdated/${IDControllers[index].text}";
                                            }
                                            prefs.getString("backuplinklist");
                                            if (prefs.getString(
                                                    "backuplinklist") ==
                                                null) {
                                              // print("called");
                                              prefs.setString(
                                                  "backuplinklist",
                                                  jsonEncode([
                                                    {
                                                      "backuplink": backuplink,
                                                      "backupbody": backupbody
                                                    }
                                                  ]));
                                            } else {
                                              // print("adder");
                                              String? data = prefs
                                                  .getString("backuplinklist");
                                              List DecodeUser =
                                                  jsonDecode(data!);
                                              DecodeUser.add({
                                                "backuplink": backuplink,
                                                "backupbody": backupbody
                                              });
                                              prefs.setString("backuplinklist",
                                                  jsonEncode(DecodeUser));
                                            }
                                            print(json.decode(prefs
                                                .getString("backuplinklist")!));
                                          } else {
                                            print("online");
                                            if (IDControllers[index].text ==
                                                "0") {
                                              AddUtilityList(index);
                                            } else {
                                              UpdateUtilityList(index,
                                                  IDControllers[index].text);
                                            }
                                          }
                                        },
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                        Color>(
                                                    Constants.primaryColor)),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(" Submit  ",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily:
                                                        Constants.popins,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12)),
                                            // Image.asset(
                                            //   "assets/icons/Edit.png",
                                            //   height: 16,
                                            // )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                    width: w / 1,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "EM",
                                              style: TextStyle(
                                                  fontFamily: Constants.popins,
                                                  // color: Constants.textColor,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                            const SizedBox(width: 5),
                                            SizedBox(
                                              height: 35,
                                              width: w * 0.25,
                                              child: TextField(
                                                controller:
                                                    EMControllers[index],
                                                keyboardType:
                                                    TextInputType.number,
                                                style: TextStyle(
                                                    fontFamily:
                                                        Constants.popins,
                                                    fontSize: 14
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
                                                          color: Colors
                                                              .grey.shade300,
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
                                                      fontFamily:
                                                          Constants.popins,
                                                    ),
                                                    // hintText: "first name",
                                                    fillColor: Colors.white70),
                                              ),
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
                                                  // color: Constants.textColor,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12),
                                            ),
                                            const SizedBox(width: 5),
                                            SizedBox(
                                              height: 35,
                                              width: w * 0.25,
                                              child: TextField(
                                                controller:
                                                    HMControllers[index],
                                                keyboardType:
                                                    TextInputType.number,
                                                style: TextStyle(
                                                  fontSize: 14,
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
                                                          color: Colors
                                                              .grey.shade300,
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
                                                      fontFamily:
                                                          Constants.popins,
                                                    ),
                                                    // hintText: "first name",
                                                    fillColor: Colors.white70),
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
