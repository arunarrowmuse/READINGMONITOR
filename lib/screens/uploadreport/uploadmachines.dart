import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';

class UploadMachines extends StatefulWidget {
  const UploadMachines({Key? key}) : super(key: key);

  @override
  State<UploadMachines> createState() => _UploadMachinesState();
}

class _UploadMachinesState extends State<UploadMachines>
    with AutomaticKeepAliveClientMixin<UploadMachines> {
  List<TextEditingController> EMControllers = [];
  List<TextEditingController> HMControllers = [];
  List<TextEditingController> WaterControllers = [];
  List<TextEditingController> BatchControllers = [];
  List<TextEditingController> IDControllers = [];
  bool isLoad = false;
  var uploaddata;
  var subcatdata;
  var maindata;
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
        EMControllers.clear();
        HMControllers.clear();
        WaterControllers.clear();
        BatchControllers.clear();
        FetchMachinesList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    FetchMachinesList();
  }

  void FetchMachinesList() async {
    EMControllers.clear();
    HMControllers.clear();
    WaterControllers.clear();
    BatchControllers.clear();
    IDControllers.clear();
    setState(() {
      isLoad = true;
    });
    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    final responsed = await http.get(
      Uri.parse(
          '${Constants.weblink}GetMachineCategoriesListing/${selectedDate.toString().split(" ")[0]}'),
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
            '${Constants.weblink}GetMachineSubCategoriesListing/${selectedDate.toString().split(" ")[0]}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $tokenvalue',
        },
      );
      if (response.statusCode == 200) {
        subcatdata = jsonDecode(response.body);
        print("sub machine name");
        print(subcatdata.length);
        print(subcatdata);
        final responses = await http.get(
          Uri.parse(
              '${Constants.weblink}GetMachineReportUploadQuery/${selectedDate.toString().split(" ")[0]}'),
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
              var waterController = TextEditingController(text: "");
              var batchController = TextEditingController(text: "");
              var idController = TextEditingController(text: "0");
              EMControllers.add(emController);
              HMControllers.add(hmController);
              WaterControllers.add(waterController);
              BatchControllers.add(batchController);
              IDControllers.add(idController);
            }
          } else {
            for (int i = 0; i < subcatdata.length; i++) {
              var emController = TextEditingController(text: "");
              var hmController = TextEditingController(text: "");
              var waterController = TextEditingController(text: "");
              var batchController = TextEditingController(text: "");
              var idController = TextEditingController(text: "0");
              for (int j = 0; j < uploaddata.length; j++) {
                if (subcatdata[i]['id'] == uploaddata[j]['sub_categories_id']) {
                  emController = TextEditingController(
                      text: uploaddata[j]['em'].toString());
                  hmController = TextEditingController(
                      text: uploaddata[j]['hm'].toString());
                  waterController = TextEditingController(
                      text: uploaddata[j]['water'].toString());
                  batchController = TextEditingController(
                      text: uploaddata[j]['batch'].toString());
                  idController = TextEditingController(
                      text: uploaddata[j]['id'].toString());
                }
              }
              EMControllers.add(emController);
              HMControllers.add(hmController);
              WaterControllers.add(waterController);
              BatchControllers.add(batchController);
              IDControllers.add(idController);

              ///////////////////HANDLING NULL (NOT POSSIBLE RN)///////////////////
              //  if (uploaddata[i]['em'].toString() == "null") {
              //     var emController = TextEditingController(text: "");
              //     EMControllers.add(emController);
              //   } else {
              //   var emController = TextEditingController(
              //         text: uploaddata[i]['em'].toString());
              //     EMControllers.add(emController);
              //    }
              ////////////////////////////////////////////////////
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
    } else {
      print(responsed.statusCode);
      print(responsed.body);
      setState(() {
        isLoad = false;
      });
      Constants.showtoast("Error Fetching Data.");
    }
  }

  void AddMachinesList(int i) async {
    Utils(context).startLoading();
    String emvalue = "0";
    String hmvalue = "0";
    String water = "0";
    String batch = "0";
    if (EMControllers[i].text != "") {
      emvalue = EMControllers[i].text;
    }
    if (HMControllers[i].text != "") {
      hmvalue = HMControllers[i].text;
    }
    if (WaterControllers[i].text != "") {
      water = WaterControllers[i].text;
    }
    if (BatchControllers[i].text != "") {
      batch = BatchControllers[i].text;
    }
    final response = await http.post(
      Uri.parse('${Constants.weblink}MachineReportUpload'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
      body: jsonEncode(<String, String>{
        "categories_id": subcatdata[i]['categories_id'].toString(),
        "sub_categories_id": subcatdata[i]['id'].toString(),
        "date": selectedDate.toString().split(" ")[0],
        "water": water,
        "batch": batch,
        "em": emvalue,
        "hm": hmvalue,
      }),
    );
    if (response.statusCode == 200) {
      Constants.showtoast("Report Added!");
      Utils(context).stopLoading();
    } else {
      Utils(context).stopLoading();
      Constants.showtoast("Error Adding Data.");
    }
    FetchMachinesList();
  }

  void UpdateMachinesList(int i, String id) async {
    Utils(context).startLoading();
    String emvalue = "0";
    String hmvalue = "0";
    String water = "0";
    String batch = "0";
    if (EMControllers[i].text != "") {
      emvalue = EMControllers[i].text;
    }
    if (HMControllers[i].text != "") {
      hmvalue = HMControllers[i].text;
    }
    if (WaterControllers[i].text != "") {
      water = WaterControllers[i].text;
    }
    if (BatchControllers[i].text != "") {
      batch = BatchControllers[i].text;
    }
    final response = await http.put(
      Uri.parse('${Constants.weblink}MachineReportUploadUpdated/$id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $tokenvalue',
      },
      body: jsonEncode(<String, String>{
        "water": water,
        "batch": batch,
        "em": emvalue,
        "hm": hmvalue,
      }),
    );
    if (response.statusCode == 200) {
      Constants.showtoast("Report Updated!");
      Utils(context).stopLoading();
    } else {
      print(response.statusCode);
      print(response.body);
      Utils(context).stopLoading();
      Constants.showtoast("Error Updating Data.");
    }
    FetchMachinesList();
  }

  void AddUpdateMachinesList() async {
    Utils(context).startLoading();
    for (int i = 0; i < IDControllers.length; i++) {
      if (IDControllers[i].text.toString() == "0") {
        if (EMControllers[i].text != "" ||
            HMControllers[i].text != "" ||
            WaterControllers[i].text != "" ||
            BatchControllers[i].text != "") {
          print("added");
          String emvalue = "0";
          String hmvalue = "0";
          String water = "0";
          String batch = "0";
          if (EMControllers[i].text != "") {
            emvalue = EMControllers[i].text;
          }
          if (HMControllers[i].text != "") {
            hmvalue = HMControllers[i].text;
          }
          if (WaterControllers[i].text != "") {
            water = WaterControllers[i].text;
          }
          if (BatchControllers[i].text != "") {
            batch = BatchControllers[i].text;
          }
          final response = await http.post(
            Uri.parse('${Constants.weblink}MachineReportUpload'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $tokenvalue',
            },
            body: jsonEncode(<String, String>{
              "categories_id": subcatdata[i]['categories_id'].toString(),
              "sub_categories_id": subcatdata[i]['id'].toString(),
              "date": selectedDate.toString().split(" ")[0],
              "water": water,
              "batch": batch,
              "em": emvalue,
              "hm": hmvalue,
            }),
          );
          if (response.statusCode == 200) {
            // Constants.showtoast("Report Added!");
            // Utils(context).stopLoading();
          } else {
            // Utils(context).stopLoading();
            Constants.showtoast("Error Adding Data.");
          }
        } else {
          print("skipped");
        }
      }
      else {
        print("update data");
        String emvalue = "0";
        String hmvalue = "0";
        String water = "0";
        String batch = "0";
        if (EMControllers[i].text != "") {
          emvalue = EMControllers[i].text;
        }
        if (HMControllers[i].text != "") {
          hmvalue = HMControllers[i].text;
        }
        if (WaterControllers[i].text != "") {
          water = WaterControllers[i].text;
        }
        if (BatchControllers[i].text != "") {
          batch = BatchControllers[i].text;
        }
        final response = await http.put(
          Uri.parse('${Constants.weblink}MachineReportUploadUpdated/${IDControllers[i].text}'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $tokenvalue',
          },
          body: jsonEncode(<String, String>{
            "water": water,
            "batch": batch,
            "em": emvalue,
            "hm": hmvalue,
          }),
        );
        if (response.statusCode == 200) {
          // Constants.showtoast("Report Updated!");
          // Utils(context).stopLoading();
        } else {
          print(response.statusCode);
          print(response.body);
          // Utils(context).stopLoading();
          Constants.showtoast("Error Updating Data.");
        }
      }

    }
    Constants.showtoast("All Report Updated!");
    Utils(context).stopLoading();
    FetchMachinesList();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    var formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
    return RefreshIndicator(
      onRefresh: () {
        return Future(() => FetchMachinesList());
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
                    // Icon(Icons.calendar_month, color: Colors.white,),
                    Row(
                      children: [
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
                      ],
                    ),
                    Container(
                      height: 30,
                      padding: const EdgeInsets.only(right: 15.0),
                      // width: 100,
                      child: ElevatedButton(
                        onPressed: () {
                          // Utils(context).startLoading();
                          // if (uploaddata.length == 0) {
                          //   AddUtilityList();
                          // } else {
                          //   UpdateUtilityList();
                          // }
                          AddUpdateMachinesList();
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
                    // Icon(Icons.l, color: Colors.white,),
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
                                                  subcatdata[index]
                                                          ['categories_id']
                                                      .toString())
                                              ? Text(
                                                  item['categories']
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
                                          subcatdata[index]['sub_name']
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
                                        onPressed: () {
                                          // Utils(context).startLoading();
                                          if (IDControllers[index].text ==
                                              "0") {
                                            AddMachinesList(index);
                                          } else {
                                            UpdateMachinesList(index,
                                                IDControllers[index].text);
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
                                            Text(" Sumbit  ",
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
                                          MainAxisAlignment.spaceBetween,
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
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.number,
                                                controller:
                                                    EMControllers[index],
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
                                              "Water",
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
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.number,
                                                controller:
                                                    WaterControllers[index],
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
                                      ],
                                    )),
                                SizedBox(
                                    width: w / 1,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
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
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.number,
                                                controller:
                                                    HMControllers[index],
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
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Batch",
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
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.number,
                                                controller:
                                                    BatchControllers[index],
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
                                    )),
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
