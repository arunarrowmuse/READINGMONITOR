import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';

class UploadManoMeter extends StatefulWidget {
  const UploadManoMeter({Key? key}) : super(key: key);

  @override
  State<UploadManoMeter> createState() => _UploadManoMeterState();
}

class _UploadManoMeterState extends State<UploadManoMeter> {
  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // const SizedBox(height: 10),
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
                            UploadManoSteam(),
                            UploadManoThermo(),
                          ]))
                    ])),
          ],
        ),
      ),
    );
  }
}

class UploadManoSteam extends StatefulWidget {
  const UploadManoSteam({Key? key}) : super(key: key);

  @override
  State<UploadManoSteam> createState() => _UploadManoSteamState();
}

class _UploadManoSteamState extends State<UploadManoSteam>
    with AutomaticKeepAliveClientMixin<UploadManoSteam> {
  List<TextEditingController> ValueControllers = [];
  List<TextEditingController> TempControllers = [];
  List<TextEditingController> IDControllers = [];
  TextEditingController idfan = TextEditingController();
  TextEditingController fdfan = TextEditingController();
  TextEditingController coalused = TextEditingController();
  TextEditingController aphvalue = TextEditingController();
  TextEditingController aphtemp = TextEditingController();
  DateTime selectedDate = DateTime.now();
  bool isLoad = false;
  var uploaddata;
  var listdata;
  late SharedPreferences prefs;
  String? tokenvalue;

  // var listener;
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
        ValueControllers.clear();
        TempControllers.clear();
        IDControllers.clear();
        idfan.clear();
        fdfan.clear();
        coalused.clear();
        aphvalue.clear();
        aphtemp.clear();
        FetchManoSteamList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    FetchManoSteamList();
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

  void FetchManoSteamList() async {
    ValueControllers.clear();
    TempControllers.clear();
    IDControllers.clear();
    idfan.clear();
    fdfan.clear();
    coalused.clear();
    aphvalue.clear();
    aphtemp.clear();
    setState(() {
      isLoad = true;
    });
    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    final response = await http.get(
      Uri.parse(
          '${Constants.weblink}ManoMeterSteamBoilerLisiting/${selectedDate.toString().split(" ")[0]}'),
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
            '${Constants.weblink}ManoMeterSteamBoilerReportUploadSharch/${selectedDate.toString().split(" ")[0]}'),
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
            ValueControllers.add(flowController);
            TempControllers.add(unitController);
            IDControllers.add(idController);
          }
        } else {
          for (int i = 0; i < listdata.length; i++) {
            var flowController = TextEditingController(text: "");
            var unitController = TextEditingController(text: "");
            var idController = TextEditingController(text: "0");
            for (int j = 0; j < uploaddata.length; j++) {
              if (listdata[i]['id'] == uploaddata[j]['machine_id']) {
                idController =
                    TextEditingController(text: uploaddata[j]['id'].toString());
                flowController = TextEditingController(
                    text: uploaddata[j]['value'].toString());
                unitController = TextEditingController(
                    text: uploaddata[j]['temperature'].toString());
              }
            }
            ValueControllers.add(flowController);
            TempControllers.add(unitController);
            IDControllers.add(idController);
            idfan.text = uploaddata[0]['id_fan'].toString();
            fdfan.text = uploaddata[0]['fd_fan'].toString();
            coalused.text = uploaddata[0]['coal_used'].toString();
            aphvalue.text = uploaddata[0]['aph_value'].toString();
            aphtemp.text = uploaddata[0]['aph_temperature'].toString();
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
      }
    } else {
      print("erro here2");
      Constants.showtoast("Error Fetching Data.");
    }
  }

  void AddManoSteamList() async {
    Utils(context).startLoading();
    for (int i = 0; i < listdata.length; i++) {
      String value = "0";
      String temp = "0";
      String idf = "0";
      String fd = "0";
      String coal = "0";
      String aphvaluee = "0";
      String aphtempp = "0";
      if (ValueControllers[i].text != "") {
        value = ValueControllers[i].text;
      }
      if (TempControllers[i].text != "") {
        temp = TempControllers[i].text;
      }
      if (idfan.text != "") {
        idf = idfan.text;
      }
      if (fdfan.text != "") {
        fd = fdfan.text;
      }
      if (coalused.text != "") {
        coal = coalused.text;
      }
      if (aphvalue.text != "") {
        aphvaluee = aphvalue.text;
      }
      if (aphtemp.text != "") {
        aphtempp = aphtemp.text;
      }
      final response = await http.post(
        Uri.parse('${Constants.weblink}ManoMeterSteamBoilerReportUploadAdd'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $tokenvalue',
        },
        body: jsonEncode(<String, String>{
          "date": selectedDate.toString().split(" ")[0],
          "machine_id": listdata[i]["id"].toString(),
          "id_fan": idf,
          "fd_fan": fd,
          "coal_used": coal,
          "aph_value": aphvaluee,
          "aph_temperature": aphtempp,
          "value": value,
          "temperature": temp
        }),
      );
      if (response.statusCode == 200) {
        // data = jsonDecode(response.body);
        if (i == listdata.length - 1) {
          Constants.showtoast("Report Added!");
        }
        // Constants.showtoast("Report Updated!");
      } else {
        print(response.statusCode);
        print(response.body);
        Constants.showtoast("Error Updating Data.");
        // Utils(context).stopLoading();
      }
    }
    Utils(context).stopLoading();
    FetchManoSteamList();
  }

  void UpdateManoSteamList() async {
    Utils(context).startLoading();
    for (int i = 0; i < listdata.length; i++) {
      String value = "0";
      String temp = "0";
      String idf = "0";
      String fd = "0";
      String coal = "0";
      String aphvaluee = "0";
      String aphtempp = "0";
      if (ValueControllers[i].text != "") {
        value = ValueControllers[i].text;
      }
      if (TempControllers[i].text != "") {
        temp = TempControllers[i].text;
      }
      if (idfan.text != "") {
        idf = idfan.text;
      }
      if (fdfan.text != "") {
        fd = fdfan.text;
      }
      if (coalused.text != "") {
        coal = coalused.text;
      }
      if (aphvalue.text != "") {
        aphvaluee = aphvalue.text;
      }
      if (aphtemp.text != "") {
        aphtempp = aphtemp.text;
      }
      final response = await http.put(
        Uri.parse(
            '${Constants.weblink}ManoMeterSteamBoilerReportUploadUpdate/${uploaddata[i]["id"].toString()}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $tokenvalue',
        },
        body: jsonEncode(<String, String>{
          "id_fan": idf,
          "fd_fan": fd,
          "coal_used": coal,
          "aph_value": aphvaluee,
          "aph_temperature": aphtempp,
          "value": value,
          "temperature": temp
        }),
      );
      if (response.statusCode == 200) {
        if (i == listdata.length - 1) {
          Constants.showtoast("Report Updated!");
        }
      } else {
        print(response.statusCode);
        print(response.body);
        Constants.showtoast("Error Updating Data.");
        // Utils(context).stopLoading();
      }
    }
    Utils(context).stopLoading();
    FetchManoSteamList();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    var formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
    final GlobalKey<FormState> _key = GlobalKey<FormState>();
    return RefreshIndicator(
      onRefresh: () {
        return Future(() => FetchManoSteamList());
      },
      child: Scaffold(
          body: Form(
        key: _key,
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
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
                            if (_key.currentState!.validate()) {
                              _key.currentState!.save();
                              print("reached here");
                              var backupbody;
                              var backuplink;

                              setState(() => isAlertSet = false);
                              isDeviceConnected =
                                  await InternetConnectionChecker()
                                      .hasConnection;
                              if (!isDeviceConnected) {
                                print("offline");
                                for (int i = 0; i < listdata.length; i++) {
                                  String value = "0";
                                  String temp = "0";
                                  String idf = "0";
                                  String fd = "0";
                                  String coal = "0";
                                  String aphvaluee = "0";
                                  String aphtempp = "0";
                                  if (ValueControllers[i].text != "") {
                                    value = ValueControllers[i].text;
                                  }
                                  if (TempControllers[i].text != "") {
                                    temp = TempControllers[i].text;
                                  }
                                  if (idfan.text != "") {
                                    idf = idfan.text;
                                  }
                                  if (fdfan.text != "") {
                                    fd = fdfan.text;
                                  }
                                  if (coalused.text != "") {
                                    coal = coalused.text;
                                  }
                                  if (aphvalue.text != "") {
                                    aphvaluee = aphvalue.text;
                                  }
                                  if (aphtemp.text != "") {
                                    aphtempp = aphtemp.text;
                                  }
                                  Constants.showtoast(
                                      "No internet, Saving data offline.");
                                  // setState(() => isAlertSet = true);
                                  if (IDControllers[i].text == "0") {
                                    // print('add backup');
                                    backupbody = <String, String>{
                                      "date":
                                          selectedDate.toString().split(" ")[0],
                                      "machine_id":
                                          listdata[i]["id"].toString(),
                                      "id_fan": idf,
                                      "fd_fan": fd,
                                      "coal_used": coal,
                                      "aph_value": aphvaluee,
                                      "aph_temperature": aphtempp,
                                      "value": value,
                                      "temperature": temp,
                                    };
                                    backuplink =
                                        "${Constants.weblink}ManoMeterSteamBoilerReportUploadAdd";
                                  } else {
                                    // print('update backup');
                                    backupbody = <String, String>{
                                      '_method': "PUT",
                                      "id_fan": idf,
                                      "fd_fan": fd,
                                      "coal_used": coal,
                                      "aph_value": aphvaluee,
                                      "aph_temperature": aphtempp,
                                      "value": value,
                                      "temperature": temp
                                    };
                                    backuplink =
                                        "${Constants.weblink}ManoMeterSteamBoilerReportUploadUpdate/${uploaddata[i]["id"]}";
                                  }
                                  prefs.getString("backuplinklist");
                                  if (prefs.getString("backuplinklist") ==
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
                                    String? data =
                                        prefs.getString("backuplinklist");
                                    List DecodeUser = jsonDecode(data!);
                                    DecodeUser.add({
                                      "backuplink": backuplink,
                                      "backupbody": backupbody
                                    });
                                    prefs.setString("backuplinklist",
                                        jsonEncode(DecodeUser));
                                  }
                                  print(json.decode(
                                      prefs.getString("backuplinklist")!));
                                }
                              }
                              else {
                                print("online");
                                if (uploaddata.length == 0) {
                                  AddManoSteamList();
                                } else {
                                  UpdateManoSteamList();
                                }
                              }
                            }
                          },
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Constants.primaryColor)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(" Submit  ",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: Constants.popins,
                                      fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                  width: w / 1.1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "ID FAN(Hz)",
                            style: TextStyle(
                                fontFamily: Constants.popins,
                                // color: Constants.textColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12),
                          ),
                          const SizedBox(width: 5),
                          SizedBox(
                            height: 35,
                            width: w * 0.15,
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              controller: idfan,
                              style: TextStyle(
                                fontFamily: Constants.popins,
                                // color: Constants.textColor,
                              ),
                              decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.only(
                                      bottom: 10.0, left: 10.0),
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 1.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Constants.primaryColor,
                                        width: 2.0),
                                    borderRadius: BorderRadius.circular(8.0),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "FD Fan(HZ)",
                            style: TextStyle(
                                fontFamily: Constants.popins,
                                // color: Constants.textColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12),
                          ),
                          const SizedBox(width: 5),
                          SizedBox(
                            height: 35,
                            width: w * 0.15,
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              controller: fdfan,
                              style: TextStyle(
                                fontFamily: Constants.popins,
                                // color: Constants.textColor,
                              ),
                              decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.only(
                                      bottom: 10.0, left: 10.0),
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 1.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Constants.primaryColor,
                                        width: 2.0),
                                    borderRadius: BorderRadius.circular(8.0),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text(
                                "Coal",
                                style: TextStyle(
                                    fontFamily: Constants.popins,
                                    // color: Constants.textColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12),
                              ),
                              Text(
                                "Used",
                                style: TextStyle(
                                    fontFamily: Constants.popins,
                                    // color: Constants.textColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(width: 5),
                          SizedBox(
                            height: 35,
                            width: w * 0.15,
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              controller: coalused,
                              style: TextStyle(
                                fontFamily: Constants.popins,
                                // color: Constants.textColor,
                              ),
                              decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.only(
                                      bottom: 10.0, left: 10.0),
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 1.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Constants.primaryColor,
                                        width: 2.0),
                                    borderRadius: BorderRadius.circular(8.0),
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
                  )),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 3,
                        offset:
                            const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "APH TO FURNANCE",
                            style: TextStyle(
                                fontFamily: Constants.popins,
                                color: Constants.textColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 15),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Container(
                          width: w / 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Value",
                                    style: TextStyle(
                                        fontFamily: Constants.popins,
                                        // color: Constants.textColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12),
                                  ),
                                  const SizedBox(width: 10),
                                  SizedBox(
                                    height: 35,
                                    width: w * 0.25,
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      controller: aphvalue,
                                      style: TextStyle(
                                        fontFamily: Constants.popins,
                                        // color: Constants.textColor,
                                      ),
                                      decoration: InputDecoration(
                                          contentPadding: const EdgeInsets.only(
                                              bottom: 10.0, left: 10.0),
                                          isDense: true,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            borderSide: BorderSide(
                                                color: Colors.grey.shade300,
                                                width: 1.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Constants.primaryColor,
                                                width: 2.0),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Temp",
                                    style: TextStyle(
                                        fontFamily: Constants.popins,
                                        // color: Constants.textColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12),
                                  ),
                                  const SizedBox(width: 10),
                                  SizedBox(
                                    height: 35,
                                    width: w * 0.25,
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      controller: aphtemp,
                                      style: TextStyle(
                                        fontFamily: Constants.popins,
                                        // color: Constants.textColor,
                                      ),
                                      decoration: InputDecoration(
                                          contentPadding: const EdgeInsets.only(
                                              bottom: 10.0, left: 10.0),
                                          isDense: true,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            borderSide: BorderSide(
                                                color: Colors.grey.shade300,
                                                width: 1.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Constants.primaryColor,
                                                width: 2.0),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
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
                          ))
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
                  : (listdata.length == 0)
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
                            itemCount: listdata.length,
                            itemBuilder: (BuildContext context, int index) {
                              // print(ValueControllers[index]);
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
                                            listdata[index]['steam_boiler']
                                                .toString(),
                                            style: TextStyle(
                                                fontFamily: Constants.popins,
                                                color: Constants.textColor,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15),
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
                                                    "Value",
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
                                                          TextInputType.number,
                                                      controller:
                                                          ValueControllers[
                                                              index],
                                                      style: TextStyle(
                                                        fontFamily:
                                                            Constants.popins,
                                                        // color: Constants.textColor,
                                                      ),
                                                      decoration:
                                                          InputDecoration(
                                                              contentPadding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      bottom:
                                                                          10.0,
                                                                      left:
                                                                          10.0),
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
                                                                borderSide: BorderSide(
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
                                                              hintStyle:
                                                                  TextStyle(
                                                                color: Colors
                                                                    .grey[400],
                                                                fontFamily:
                                                                    Constants
                                                                        .popins,
                                                              ),
                                                              // hintText: "first name",
                                                              fillColor: Colors
                                                                  .white70),
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
                                                    "Temp",
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
                                                          TextInputType.number,
                                                      controller:
                                                          TempControllers[
                                                              index],
                                                      style: TextStyle(
                                                        fontFamily:
                                                            Constants.popins,
                                                        // color: Constants.textColor,
                                                      ),
                                                      decoration:
                                                          InputDecoration(
                                                              contentPadding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      bottom:
                                                                          10.0,
                                                                      left:
                                                                          10.0),
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
                                                                borderSide: BorderSide(
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
                                                              hintStyle:
                                                                  TextStyle(
                                                                color: Colors
                                                                    .grey[400],
                                                                fontFamily:
                                                                    Constants
                                                                        .popins,
                                                              ),
                                                              // hintText: "first name",
                                                              fillColor: Colors
                                                                  .white70),
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
      )),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class UploadManoThermo extends StatefulWidget {
  const UploadManoThermo({Key? key}) : super(key: key);

  @override
  State<UploadManoThermo> createState() => _UploadManoThermoState();
}

class _UploadManoThermoState extends State<UploadManoThermo>
    with AutomaticKeepAliveClientMixin<UploadManoThermo> {
  List<TextEditingController> ValueControllers = [];
  List<TextEditingController> TempControllers = [];
  List<TextEditingController> IDControllers = [];
  TextEditingController idfan = TextEditingController();
  TextEditingController fdfan = TextEditingController();
  TextEditingController coalused = TextEditingController();
  TextEditingController aphvalue = TextEditingController();
  TextEditingController aphtemp = TextEditingController();
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
        ValueControllers.clear();
        TempControllers.clear();
        IDControllers.clear();
        idfan.clear();
        fdfan.clear();
        coalused.clear();
        aphvalue.clear();
        aphtemp.clear();
        FetchManoThermoList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    FetchManoThermoList();
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
  void FetchManoThermoList() async {
    ValueControllers.clear();
    TempControllers.clear();
    IDControllers.clear();
    idfan.clear();
    fdfan.clear();
    coalused.clear();
    aphvalue.clear();
    aphtemp.clear();
    setState(() {
      isLoad = true;
    });
    prefs = await SharedPreferences.getInstance();
    tokenvalue = prefs.getString("token");
    final response = await http.get(
      Uri.parse(
          '${Constants.weblink}ManoMeterThermopackLisiting/${selectedDate.toString().split(" ")[0]}'),
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
            '${Constants.weblink}ManoMeterThermopackReportUploadSharch/${selectedDate.toString().split(" ")[0]}'),
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
            ValueControllers.add(flowController);
            TempControllers.add(unitController);
            IDControllers.add(idController);
          }
        } else {
          for (int i = 0; i < listdata.length; i++) {
            var valueController = TextEditingController(text: "");
            var tempController = TextEditingController(text: "");
            var idController = TextEditingController(text: "0");
            for (int j = 0; j < uploaddata.length; j++) {
              if (listdata[i]['id'] == uploaddata[j]['machine_id']) {
                idController =
                    TextEditingController(text: uploaddata[j]['id'].toString());
                valueController = TextEditingController(
                    text: uploaddata[j]['value'].toString());
                tempController = TextEditingController(
                    text: uploaddata[j]['temperature'].toString());
              }
            }
            IDControllers.add(idController);
            ValueControllers.add(valueController);
            TempControllers.add(tempController);
            idfan.text = uploaddata[0]['id_fan'].toString();
            fdfan.text = uploaddata[0]['fd_fan'].toString();
            coalused.text = uploaddata[0]['coal_used'].toString();
            aphvalue.text = uploaddata[0]['aph_value'].toString();
            aphtemp.text = uploaddata[0]['aph_temperature'].toString();
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

  void AddManoThermoList() async {
    Utils(context).startLoading();
    for (int i = 0; i < listdata.length; i++) {
      String value = "0";
      String temp = "0";
      String idf = "0";
      String fd = "0";
      String coal = "0";
      String aphvaluee = "0";
      String aphtempp = "0";
      if (ValueControllers[i].text != "") {
        value = ValueControllers[i].text;
      }
      if (TempControllers[i].text != "") {
        temp = TempControllers[i].text;
      }
      if (idfan.text != "") {
        idf = idfan.text;
      }
      if (fdfan.text != "") {
        fd = fdfan.text;
      }
      if (coalused.text != "") {
        coal = coalused.text;
      }
      if (aphvalue.text != "") {
        aphvaluee = aphvalue.text;
      }
      if (aphtemp.text != "") {
        aphtempp = aphtemp.text;
      }
      final response = await http.post(
        Uri.parse('${Constants.weblink}ManoMeterThermopackReportUploadAdd'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $tokenvalue',
        },
        body: jsonEncode(<String, String>{
          "date": selectedDate.toString().split(" ")[0],
          "machine_id": listdata[i]["id"].toString(),
          "id_fan": idf,
          "fd_fan": fd,
          "coal_used": coal,
          "aph_value": aphvaluee,
          "aph_temperature": aphtempp,
          "value": value,
          "temperature": temp,
        }),
      );
      if (response.statusCode == 200) {
        if (i == listdata.length - 1) {
          Constants.showtoast("Report Added!");
        }
      } else {
        print(response.statusCode);
        print(response.body);
        Constants.showtoast("Error Updating Data.");
        // Utils(context).stopLoading();
      }
    }
    Utils(context).stopLoading();
    FetchManoThermoList();
  }

  void UpdateManoThermoList() async {
    Utils(context).startLoading();
    for (int i = 0; i < listdata.length; i++) {
      String value = "0";
      String temp = "0";
      String idf = "0";
      String fd = "0";
      String coal = "0";
      String aphvaluee = "0";
      String aphtempp = "0";
      if (ValueControllers[i].text != "") {
        value = ValueControllers[i].text;
      }
      if (TempControllers[i].text != "") {
        temp = TempControllers[i].text;
      }
      if (idfan.text != "") {
        idf = idfan.text;
      }
      if (fdfan.text != "") {
        fd = fdfan.text;
      }
      if (coalused.text != "") {
        coal = coalused.text;
      }
      if (aphvalue.text != "") {
        aphvaluee = aphvalue.text;
      }
      if (aphtemp.text != "") {
        aphtempp = aphtemp.text;
      }
      final response = await http.put(
        Uri.parse(
            '${Constants.weblink}ManoMeterThermopackReportUploadUpdate/${uploaddata[i]["id"].toString()},'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $tokenvalue',
        },
        body: jsonEncode(<String, String>{
          "id_fan": idf,
          "fd_fan": fd,
          "coal_used": coal,
          "aph_value": aphvaluee,
          "aph_temperature": aphtempp,
          "value": value,
          "temperature": temp
        }),
      );
      if (response.statusCode == 200) {
        if (i == listdata.length - 1) {
          Constants.showtoast("Report Updated!");
          // Utils(context).stopLoading();
        }
      } else {
        print(response.statusCode);
        print(response.body);
        Constants.showtoast("Error Updating Data.");
      }
    }
    Utils(context).stopLoading();
    FetchManoThermoList();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    var formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
    final GlobalKey<FormState> _key = GlobalKey<FormState>();
    return RefreshIndicator(
      onRefresh: () {
        return Future(() => FetchManoThermoList());
      },
      child: Scaffold(
          body: Form(
        key: _key,
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
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
                            if (_key.currentState!.validate()) {
                              _key.currentState!.save();
                              print("reached here");
                              var backupbody;
                              var backuplink;

                              setState(() => isAlertSet = false);
                              isDeviceConnected =
                                  await InternetConnectionChecker()
                                  .hasConnection;
                              if (!isDeviceConnected) {
                                print("offline");
                                for (int i = 0; i < listdata.length; i++) {
                                  String value = "0";
                                  String temp = "0";
                                  String idf = "0";
                                  String fd = "0";
                                  String coal = "0";
                                  String aphvaluee = "0";
                                  String aphtempp = "0";
                                  if (ValueControllers[i].text != "") {
                                    value = ValueControllers[i].text;
                                  }
                                  if (TempControllers[i].text != "") {
                                    temp = TempControllers[i].text;
                                  }
                                  if (idfan.text != "") {
                                    idf = idfan.text;
                                  }
                                  if (fdfan.text != "") {
                                    fd = fdfan.text;
                                  }
                                  if (coalused.text != "") {
                                    coal = coalused.text;
                                  }
                                  if (aphvalue.text != "") {
                                    aphvaluee = aphvalue.text;
                                  }
                                  if (aphtemp.text != "") {
                                    aphtempp = aphtemp.text;
                                  }
                                  Constants.showtoast(
                                      "No internet, Saving data offline.");
                                  // setState(() => isAlertSet = true);
                                  if (IDControllers[i].text == "0") {
                                    // print('add backup');
                                    backupbody = <String, String>{
                                      "date":
                                      selectedDate.toString().split(" ")[0],
                                      "machine_id":
                                      listdata[i]["id"].toString(),
                                      "id_fan": idf,
                                      "fd_fan": fd,
                                      "coal_used": coal,
                                      "aph_value": aphvaluee,
                                      "aph_temperature": aphtempp,
                                      "value": value,
                                      "temperature": temp,
                                    };
                                    backuplink =
                                    "${Constants.weblink}ManoMeterThermopackReportUploadAdd";
                                  } else {
                                    // print('update backup');
                                    backupbody = <String, String>{
                                      '_method': "PUT",
                                      "id_fan": idf,
                                      "fd_fan": fd,
                                      "coal_used": coal,
                                      "aph_value": aphvaluee,
                                      "aph_temperature": aphtempp,
                                      "value": value,
                                      "temperature": temp
                                    };
                                    backuplink =
                                    "${Constants.weblink}ManoMeterThermopackReportUploadUpdate/${uploaddata[i]["id"].toString()}";
                                  }
                                  prefs.getString("backuplinklist");
                                  if (prefs.getString("backuplinklist") ==
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
                                    String? data =
                                    prefs.getString("backuplinklist");
                                    List DecodeUser = jsonDecode(data!);
                                    DecodeUser.add({
                                      "backuplink": backuplink,
                                      "backupbody": backupbody
                                    });
                                    prefs.setString("backuplinklist",
                                        jsonEncode(DecodeUser));
                                  }
                                  print(json.decode(
                                      prefs.getString("backuplinklist")!));
                                }
                              }
    else {
                                print("online");
                                if (uploaddata.length == 0) {
                                  AddManoThermoList();
                                } else {
                                  UpdateManoThermoList();
                                }
                              }
                            }
                          },
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Constants.primaryColor)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(" Submit  ",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: Constants.popins,
                                      fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                  width: w / 1.1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "ID FAN(Hz)",
                            style: TextStyle(
                                fontFamily: Constants.popins,
                                // color: Constants.textColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12),
                          ),
                          const SizedBox(width: 5),
                          SizedBox(
                            height: 35,
                            width: w * 0.15,
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              controller: idfan,
                              style: TextStyle(
                                fontFamily: Constants.popins,
                                // color: Constants.textColor,
                              ),
                              decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.only(
                                      bottom: 10.0, left: 10.0),
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 1.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Constants.primaryColor,
                                        width: 2.0),
                                    borderRadius: BorderRadius.circular(8.0),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "FD Fan(HZ)",
                            style: TextStyle(
                                fontFamily: Constants.popins,
                                // color: Constants.textColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12),
                          ),
                          const SizedBox(width: 5),
                          SizedBox(
                            height: 35,
                            width: w * 0.15,
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              controller: fdfan,
                              style: TextStyle(
                                fontFamily: Constants.popins,
                                // color: Constants.textColor,
                              ),
                              decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.only(
                                      bottom: 10.0, left: 10.0),
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 1.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Constants.primaryColor,
                                        width: 2.0),
                                    borderRadius: BorderRadius.circular(8.0),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text(
                                "Coal",
                                style: TextStyle(
                                    fontFamily: Constants.popins,
                                    // color: Constants.textColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12),
                              ),
                              Text(
                                "Used",
                                style: TextStyle(
                                    fontFamily: Constants.popins,
                                    // color: Constants.textColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(width: 5),
                          SizedBox(
                            height: 35,
                            width: w * 0.15,
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              controller: coalused,
                              style: TextStyle(
                                fontFamily: Constants.popins,
                                // color: Constants.textColor,
                              ),
                              decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.only(
                                      bottom: 10.0, left: 10.0),
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 1.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Constants.primaryColor,
                                        width: 2.0),
                                    borderRadius: BorderRadius.circular(8.0),
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
                  )),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 3,
                        offset:
                            const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "APH TO FURNANCE",
                            style: TextStyle(
                                fontFamily: Constants.popins,
                                color: Constants.textColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 15),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Container(
                          width: w / 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Value",
                                    style: TextStyle(
                                        fontFamily: Constants.popins,
                                        // color: Constants.textColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12),
                                  ),
                                  const SizedBox(width: 10),
                                  SizedBox(
                                    height: 35,
                                    width: w * 0.25,
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      controller: aphvalue,
                                      style: TextStyle(
                                        fontFamily: Constants.popins,
                                        // color: Constants.textColor,
                                      ),
                                      decoration: InputDecoration(
                                          contentPadding: const EdgeInsets.only(
                                              bottom: 10.0, left: 10.0),
                                          isDense: true,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            borderSide: BorderSide(
                                                color: Colors.grey.shade300,
                                                width: 1.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Constants.primaryColor,
                                                width: 2.0),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Temp",
                                    style: TextStyle(
                                        fontFamily: Constants.popins,
                                        // color: Constants.textColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12),
                                  ),
                                  const SizedBox(width: 10),
                                  SizedBox(
                                    height: 35,
                                    width: w * 0.25,
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      controller: aphtemp,
                                      style: TextStyle(
                                        fontFamily: Constants.popins,
                                        // color: Constants.textColor,
                                      ),
                                      decoration: InputDecoration(
                                          contentPadding: const EdgeInsets.only(
                                              bottom: 10.0, left: 10.0),
                                          isDense: true,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            borderSide: BorderSide(
                                                color: Colors.grey.shade300,
                                                width: 1.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Constants.primaryColor,
                                                width: 2.0),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
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
                          ))
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
                  : (listdata.length == 0)
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
                            itemCount: listdata.length,
                            itemBuilder: (BuildContext context, int index) {
                              print(ValueControllers[index]);
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
                                            listdata[index]['thermopack']
                                                .toString(),
                                            style: TextStyle(
                                                fontFamily: Constants.popins,
                                                color: Constants.textColor,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15),
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
                                                    "Value",
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
                                                          TextInputType.number,
                                                      controller:
                                                          ValueControllers[
                                                              index],
                                                      style: TextStyle(
                                                        fontFamily:
                                                            Constants.popins,
                                                        // color: Constants.textColor,
                                                      ),
                                                      decoration:
                                                          InputDecoration(
                                                              contentPadding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      bottom:
                                                                          10.0,
                                                                      left:
                                                                          10.0),
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
                                                                borderSide: BorderSide(
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
                                                              hintStyle:
                                                                  TextStyle(
                                                                color: Colors
                                                                    .grey[400],
                                                                fontFamily:
                                                                    Constants
                                                                        .popins,
                                                              ),
                                                              // hintText: "first name",
                                                              fillColor: Colors
                                                                  .white70),
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
                                                    "Temp",
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
                                                          TextInputType.number,
                                                      controller:
                                                          TempControllers[
                                                              index],
                                                      style: TextStyle(
                                                        fontFamily:
                                                            Constants.popins,
                                                        // color: Constants.textColor,
                                                      ),
                                                      decoration:
                                                          InputDecoration(
                                                              contentPadding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      bottom:
                                                                          10.0,
                                                                      left:
                                                                          10.0),
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
                                                                borderSide: BorderSide(
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
                                                              hintStyle:
                                                                  TextStyle(
                                                                color: Colors
                                                                    .grey[400],
                                                                fontFamily:
                                                                    Constants
                                                                        .popins,
                                                              ),
                                                              // hintText: "first name",
                                                              fillColor: Colors
                                                                  .white70),
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
      )),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
